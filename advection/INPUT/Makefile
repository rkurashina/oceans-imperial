include ../standard_defs.mk

all: mod_qg_input.o mod_advection_input.o move


mod_qg_input.o : mod_qg_input.f
	$(CC) -c $(LIBS) $(INCLUDES) mod_qg_input.f $(LINKS)

mod_advection_input.o : mod_advection_input.f
	$(CC) -c $(LIBS) $(INCLUDES) mod_advection_input.f $(LINKS)

move:
	mv *.o *.mod $(BUILD_DIR)

clean:
	rm *.o *.mod
