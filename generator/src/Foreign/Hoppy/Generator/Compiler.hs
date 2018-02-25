-- This file is part of Hoppy.
--
-- Copyright 2015-2019 Bryan Gardiner <bog@khumba.net>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

-- | Data types for compilers and functions for invoking them.
module Foreign.Hoppy.Generator.Compiler (
  Compiler (..),
  SomeCompiler (..),
  SimpleCompiler (..),
  prependArguments,
  appendArguments,
  CustomCompiler (..),
  -- * Standard compilers
  gccCompiler,
  gppCompiler,
  ) where

import Control.Exception (IOException, try)
import Data.Either (partitionEithers)
import qualified Data.Map as M
import Foreign.Hoppy.Generator.Common (strInterpolate)
import System.Exit (ExitCode (ExitFailure, ExitSuccess))
import System.IO (hPutStrLn, stderr)
import System.Process (createProcess_, proc, showCommandForUser, waitForProcess)

-- TODO The default compiler should use environment variables (CFLAGS, CC (is
-- there a different standard var for C++?)).  Rename gppCompiler to ccCompiler
-- or something.

-- | A compiler that exists on the system for compiling C++ code.
class Show a => Compiler a where
  -- | @compileProgram compiler infile outfile@ invokes the given compiler in
  -- the input file, to produce the output file.  If the compiler fails or can't
  -- be called for whatever reason, then an error message is printed to standard
  -- error, and false is returned.
  compileProgram :: a -> FilePath -> FilePath -> IO Bool

-- | An existential data type for 'Compiler's.
data SomeCompiler = forall a. Compiler a => SomeCompiler a

instance Show SomeCompiler where
  show (SomeCompiler c) = "<SomeCompiler " ++ show c ++ ">"

instance Compiler SomeCompiler where
  compileProgram (SomeCompiler c) = compileProgram c

-- | A compiler that can compile a source file into a binary with a single
-- program invocation.
--
-- Within the strings in this data type, including the program path, all
-- occurences of @{in}@ and @{out}@ are expanded to the input and desired output
-- files, respectively.
data SimpleCompiler = SimpleCompiler
  { scProgram :: FilePath
    -- ^ The name of the compiler program to call.
  , scArguments :: [String]
    -- ^ Arguments to pass to the compiler.  Each string is passed as a separate
    -- argument.
  }

instance Show SimpleCompiler where
  show compiler =
    "<SimpleCompiler " ++ show (scProgram compiler) ++ " " ++
    show (scArguments compiler) ++ ">"

instance Compiler SimpleCompiler where
  compileProgram compiler inPath outPath =
    runProgram compiler
               (scProgram compiler)
               (scArguments compiler)
               (M.fromList [("in", inPath), ("out", outPath)])

-- | Adds arguments to the start of a compiler's argument list.
prependArguments :: [String] -> SimpleCompiler -> SimpleCompiler
prependArguments args compiler =
  compiler { scArguments = args ++ scArguments compiler }

-- | Adds arguments to the end of a compiler's argument list.
appendArguments :: [String] -> SimpleCompiler -> SimpleCompiler
appendArguments args compiler =
  compiler { scArguments = scArguments compiler ++ args }

-- | A 'Compiler' that allows plugging arbitary logic into the compilation
-- process.
data CustomCompiler = CustomCompiler
  { ccLabel :: String
    -- ^ A label to display when the compiler is 'show'n.  The string is
    -- @"<CustomCompiler " ++ label ++ ">"@.
  , ccCompile :: FilePath -> FilePath -> IO Bool
    -- ^ Given a source file path and an output path, compiles the source file,
    -- producing a binary at the output path.  Returns true on success.  Logs to
    -- standard error and returns false on failure.
  }

instance Show CustomCompiler where
  show c = "<CustomCompiler " ++ ccLabel c ++ ">"

instance Compiler CustomCompiler where
  compileProgram = ccCompile

-- | The GNU C compiler, invoked as @gcc -o {out} {in}@.
gccCompiler =
  SimpleCompiler
  { scProgram = "gcc"
  , scArguments = ["-o", "{out}", "{in}"]
  }

-- | The GNU C++ compiler, invoked as @g++ -o {out} {in}@.
gppCompiler =
  SimpleCompiler
  { scProgram = "g++"
  , scArguments = ["-o", "{out}", "{in}"]
  }

-- | Invokes a program as part of running a compiler.  Performs argument
-- interpolation on the program and argument strings.  Returns true if the
-- program executes successfully, and false otherwise (logging to stderr).
runProgram :: Show a => a -> FilePath -> [String] -> M.Map String String -> IO Bool
runProgram compiler program arguments values = do
  let interpolationResults =
        partitionEithers $
        map (strInterpolate values) (program:arguments)
  case interpolationResults of
    (unknownKey:_, _) -> do
      hPutStrLn stderr $
        "Error: Hit unknown binding {" ++ unknownKey ++ "} when executing C++ compiler '" ++
        show compiler ++ ".  program = " ++ show program ++ ", arguments = " ++
        show arguments ++ "."
      return False
    ([], program:args) -> do
      let cmdLine = showCommandForUser program args
      forkResult <- try $ createProcess_ program $ proc program args
      case forkResult of
        Left (e :: IOException) -> do
          hPutStrLn stderr $
            "Error: Hoppy failed to invoke program (" ++ cmdLine ++ "): " ++ show e
          return False
        Right (_, _, _, procHandle) -> do
          exitCode <- waitForProcess procHandle
          case exitCode of
            ExitSuccess -> return True
            ExitFailure _ -> do
              hPutStrLn stderr $ "Error: Hoppy call to program failed (" ++ cmdLine ++ ")."
              return False
    ([], []) -> error "runProgram: Can't get here."
