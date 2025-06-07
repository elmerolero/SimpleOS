/******************************************************************************
*	kernel.ld
*	 by Ismael Salas López, originally it was from Alex Chadwick, but now it
*    is updated to work in the way I need it
*
*	A linker script for generation of raspberry pi kernel images.
******************************************************************************/

SECTIONS {

	/*
	* First and formost we need the .init section, containing the code to 
        * be run first. We allow room for the ATAGs and stack and conform to 
        * the bootloader's expectation by putting this code at 0x8000.
	*/
	.init 0x8000 : AT(0x8000) {
		*(.init)
	}

    /*
    * First table
    */
    .page_table 0xC000 : {
        _page_table_start = .;
        . = . + 0x4000;  /* 16KB for page table */
        _page_table_end = .;
    }

    /*
    * Second table
    */
    .coarse_table : AT(0x10000) {
        _coarse_table_start = .;
        . = . + 0x400;  /* 4 KB */
        _coarse_table_end = .;
    }

	.undefined_stack 0x1000 : AT(0x11000) {
        _undefined_stack_start = .;
        . = . + 0x1000;  /* 4 KB for Undefined */
        _undefined_stack_end = .;
    }
	
	.abort_stack ALIGN(4096) : AT(0x12000) {
        _abort_stack_start = .;
        . = . + 0x1000;  /* 4 KB for Data Abort */
        _abort_stack_end = .;
    }

    .irq_stack ALIGN(4096) : AT(0x13000) {
        _irq_stack_start = .;
        . = . + 0x1000;  /* 4 KB for IRQ */
        _irq_stack_end = .;
    }

    .fiq_stack ALIGN(4096) : AT(0x14000){
        _fiq_stack_start = .;
        . = . + 0x1000;  /* 4 KB for FIQ */
        _fiq_stack_end = .;
    }

    .sys_stack ALIGN(4096) : AT(0x15000) {
        _sys_stack_start = .;
        . = . + 0x1000;  /* 4 KB for SYS */
        _sys_stack_end = .;
    }

    /* 
	* Next we put the rest of the code.
	*/
	.text ALIGN(4096) : AT(0x16000) {
		*(.text)
	}

    /* 
	* Next we put the data.
	*/
	.data 0x0000 : AT(0x17000) {
		*(.data)
	}

	/*
	* Finally comes everything else. A fun trick here is to put all other 
	* sections into this section, which will be discarded by default.
	*/
	/DISCARD/ : {
		*(*)
	}
}
