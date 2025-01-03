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
	.init 0x8000 : {
		*(.init)
	}

	.undefined_stack : {
        . = ALIGN(8);
        _undefined_stack_start = .;
        . = . + 0x400;  /* 1 KB for Undefined */
        _undefined_stack_end = .;
    }
	
	.abort_stack : {
        . = ALIGN(8);
        _abort_stack_start = .;
        . = . + 0x400;  /* 1 KB for Data Abort */
        _abort_stack_end = .;
    }

    .irq_stack : {
        . = ALIGN(8);
        _irq_stack_start = .;
        . = . + 0x400;  /* 1 KB for IRQ */
        _irq_stack_end = .;
    }

    .fiq_stack : {
        . = ALIGN(8);
        _fiq_stack_start = .;
        . = . + 0x400;  /* 1 KB for FIQ */
        _fiq_stack_end = .;
    }

    .sys_stack : {
        . = ALIGN(8);
        _sys_stack_start = .;
        . = . + 0x400;  /* 1 KB for SYS */
        _sys_stack_end = .;
    }

	/* 
	* Next we put the rest of the code.
	*/
	.text : {
		*(.text)
	}
	
	/* 
	* Next we put the data.
	*/
	.data : {
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
