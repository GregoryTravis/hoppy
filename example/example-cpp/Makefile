# This file is part of Hoppy.
#
# Copyright 2015-2020 Bryan Gardiner <bog@khumba.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: all

INCS=-I/Users/gmt/JUCE/modules/

OS=$(shell ghc -e ":m +System.Info" -e "putStrLn os")

CC = g++
CFLAGS = -O2 $(INCS) -DJUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1 -DDEBUG=1 --std=c++11 -undefined dynamic_lookup

.PHONY: clean install

all: cpp/libexample.a

cpp/libexample.a: cpp/utils.o cpp/gen_utils.o cpp/gen_std.o #cpp/juce_MidiMessage.o
ifeq ($(OS),darwin)
	#$(CC) $(CFLAGS) -fPIC -o $@ $^
	ar rvs $@ $^
else
	$(CC) $(CFLAGS) -fPIC -o $@ $^
endif

%.o: %.cpp
	$(CC) $(CFLAGS) -fPIC -c -o $@ $<

# cpp/juce_MidiMessage.o: /Users/gmt/JUCE/modules/juce_audio_basics/midi/juce_MidiMessage.cpp
# 	$(CC) $(CFLAGS) -fPIC -c -o cpp/juce_MidiMessage.o  /Users/gmt/JUCE/modules/juce_audio_basics/midi/juce_MidiMessage.cpp

clean:
	rm -f cpp/utils.o cpp/gen_utils.o cpp/gen_std.o cpp/libexample.a

install:
ifeq ($(OS),darwin)
	install cpp/libexample.a "$(libdir)"
else
	install -t "$(libdir)" cpp/libexample.a
endif
