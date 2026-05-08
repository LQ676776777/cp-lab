CXX      := g++
CXXFLAGS := -std=c++17 -Wall -O2 -Iinclude

OBJS := main.o helloworld.o

helloworld: $(OBJS)
	$(CXX) $(OBJS) -o $@

%.o: %.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

main.o:       main.cc       include/helloworld.hh
helloworld.o: helloworld.cc include/helloworld.hh

.PHONY: clean
clean:
	rm -f $(OBJS) helloworld
