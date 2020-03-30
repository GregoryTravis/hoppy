#ifndef HOPPY_FLUB_HPP
#define HOPPY_FLUB_HPP

// This file is part of Hoppy.
//
// Copyright 2015-2020 Bryan Gardiner <bog@khumba.net>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

extern char flubVar;
extern const char flubVarConst;

enum FlubEnum {
    OPTION_A = 0x1,
    OPTION_B = 0x2,
    OPTION_C = 0x4,
};

class FlubClass {
public:
    int flubClassVar;
    static int flubStaticClassVar;
    static const int flubStaticConstClassVar;
};

// Break circularity C++-style.
class FlobClass;

void takesFlobValues(FlobClass*);

#endif
