/******************************************************************************
*	kernel.ld
*	 by Alex Chadwick
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

    .init_stack 0x7000 : AT(0x7000) {
        _init_stack_start = .;
        . = . + 0x1000;  /* 4 KB for init */
        _init_stack_end = .;
    }

    .main_page_table 0xC000 : {
        _page_table_start = .;
        . = . + 0x4000;  /* 16KB for first table */
        _page_table_end = .;
    }

    .secondary_page_table 0x10000 : {
        _coarse_table_start = .;
        . = . + 0x400;  /* 1KB for secondary table */
        _coarse_table_end = .;
    }

	.undefined_stack 0x11000 : AT(0x11000) {
        _undefined_stack_start = .;
        . = . + 0x1000;  /* 4KB for Undefined */
        _undefined_stack_end = .;
    }
	
	.abort_stack : {
        _abort_stack_start = .;
        . = . + 0x1000;  /* 4 KB for Data Abort */
        _abort_stack_end = .;
    }

    .irq_stack : {
        _irq_stack_start = .;
        . = . + 0x1000;  /* 4 KB for IRQ */
        _irq_stack_end = .;
    }

    .fiq_stack : {
        _fiq_stack_start = .;
        . = . + 0x1000;  /* 4 KB for FIQ */
        _fiq_stack_end = .;
    }

    .sys_stack : {
        _sys_stack_start = .;
        . = . + 0x1000;  /* 4 KB for SYS */
        _sys_stack_end = .;
    }

	/* 
	* Next we put the rest of the code.
	*/
	.text ALIGN(0x1000) : {
		*(.text)
	}
	
	/* 
	* Next we put the data.
	*/
	.data ALIGN(0x1000) : {
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
