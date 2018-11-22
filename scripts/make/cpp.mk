.PHONY: clean run

run: %.out
		./$<

%.out: %.cpp %.h $(DEPENDS)
		g++ $^ -o %.out

clean:
		rm -rf %.out
