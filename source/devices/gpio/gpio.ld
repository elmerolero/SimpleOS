/*
 * GPIO LD
 * Copyright (c) 2025 Ismael Salas López
 * Distributed under the terms described in LICENSE.
 */

SECTIONS {
    /* Driver Header */
    .module_header 0x0000 : {
        *(.module_header);
    }

    /* 
	* Next we put the rest of the code.
	*/
	.text : {
		*(.text);
	}
	
	/* 
	* Next we put the data.
	*/
	.data ALIGN(0x2000) : {
		*(.data);
	}
}
