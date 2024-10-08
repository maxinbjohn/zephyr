/*
 * Copyright (c) 2019 Intel Corporation
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr/arch/x86/multiboot.h>
#include <zephyr/devicetree.h>

/*
 * This is included by ia32/crt0.S and intel64/locore.S
 * at their 32-bit entry points to cover common ground.
 */

#ifdef CONFIG_MULTIBOOT_INFO
        /*
         * If we were loaded by a multiboot-compliant loader, then EAX
         * contains MULTIBOOT_EAX_MAGIC and EBX points to a valid 'struct
         * multiboot_info'; otherwise EBX is just junk. Check EAX early
	 * before it's clobbered and leave a sentinel (0) in EBX if invalid.
	 * The valid in EBX will be the argument to z_prep_c(), so the
	 * subsequent code must, of course, be sure to preserve it meanwhile.
	 */

	cmpl $MULTIBOOT_EAX_MAGIC, %eax

#ifndef CONFIG_DYNAMIC_BOOTARGS
	je 1f
	xorl %ebx, %ebx
1:
#else
	movl $multiboot_cmdline, %edi
	je setup_copy_cmdline
	xorl %ebx, %ebx
	jmp end_cmdline

setup_copy_cmdline:
	testl $MULTIBOOT_INFO_FLAGS_CMDLINE, __multiboot_info_t_flags_OFFSET(%ebx)
	jz end_cmdline

	movl $multiboot_cmdline + CONFIG_BOOTARGS_ARGS_BUFFER_SIZE - 1, %edx
	movl __multiboot_info_t_cmdline_OFFSET(%ebx), %esi
copy_cmdline:
	cmpl %esi, %edx
	je end_cmdline
	cmpb $0, (%esi)
	je end_cmdline

	movsb
	jmp copy_cmdline
end_cmdline:
	movb $0, (%edi)
#endif

#endif

#ifdef CONFIG_PIC_DISABLE
	/*
	 * "Disable" legacy i8259 interrupt controllers. Note that we
	 * can't actually disable them, but we mask all their interrupt
	 * sources which is effectively the same thing (almost).
	 */

	movb $0xff, %al
	outb %al, $0x21
	outb %al, $0xA1
#endif

#ifdef CONFIG_MULTIBOOT
	jmp 1f

	.align 4
	.long MULTIBOOT_HEADER_MAGIC
	.long MULTIBOOT_HEADER_FLAGS
	.long -(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)
#if DT_HAS_COMPAT_STATUS_OKAY(intel_multiboot_framebuffer)
	.fill 5,4,0							/* (unused exec layout) */
	.long 0								/* linear graphics mode */
	.long DT_PROP(DT_INST(0, intel_multiboot_framebuffer), width)	/* width */
	.long DT_PROP(DT_INST(0, intel_multiboot_framebuffer), height)	/* height */
	.long 32							/* depth */
#endif
1:
#endif
