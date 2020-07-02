# Lab 3
### Before starting lab 3:
After the previous labs, we have constructed a basic idea about virtual memory and page tables. However, there are still some untouched areas in operating system, which is very important for understanding this lab.
* GDT(global descriptor table), segment descriptor and ```lgdt```:
  
The assembly operation ```lgdt``` first shows up in lab 1, while the computer is booting and switching from real mode to kernel mode, we observe some code as below:
```
# Switch from real to protected mode, using a bootstrap GDT
# and segment translation that makes virtual addresses 
# identical to their physical addresses, so that the 
# effective memory map does not change during the switch.
lgdt    gdtdesc
movl    %cr0, %eax
orl     $CR0_PE_ON, %eax
movl    %eax, %cr0
```
With the help of a [lecture slide](http://www.ics.p.lodz.pl/~dpuchala/LowLevelProgr/Old/Lecture2.pdf), we can understand the ```movl``` and ```orl``` operations enable paging. However, the ```lgdt``` operation still seems confusing. In this lab, we are going to touch this part of our system. As a result, I will simply conclude the usage of each part one by one:
##### Segment descriptor:
The introduction of segmentation and segment descriptor can be found in the same lecture slide as above. Here, I will only show the code implementation of segment descriptor to help better understand the segment descriptor. The original code can be found in ```inc/mmu.h```:
```
// Segment Descriptors
struct Segdesc {
	unsigned sd_lim_15_0 : 16;  // Low bits of segment limit
	unsigned sd_base_15_0 : 16; // Low bits of segment base address
	unsigned sd_base_23_16 : 8; // Middle bits of segment base address
	unsigned sd_type : 4;       // Segment type (see STS_ constants)
	unsigned sd_s : 1;          // 0 = system, 1 = application
	unsigned sd_dpl : 2;        // Descriptor Privilege Level
	unsigned sd_p : 1;          // Present
	unsigned sd_lim_19_16 : 4;  // High bits of segment limit
	unsigned sd_avl : 1;        // Unused (available for software use)
	unsigned sd_rsv1 : 1;       // Reserved
	unsigned sd_db : 1;         // 0 = 16-bit segment, 1 = 32-bit segment
	unsigned sd_g : 1;          // Granularity: limit scaled by 4K when set
	unsigned sd_base_31_24 : 8; // High bits of segment base address
};
```
The corresponding segment descriptor image is present below. You should always read this picture from bottom to top, from right to left to match the implementation:

##### GDT and ```lgdt```:
The Global Descriptor Table holds an array of segment descriptors. Its address and limits are located in GDTR register which can be written with ```lgdt``` instruction. There is only one GDT. We can also find the definition of ```gdtdesc```, which is the source of ```lgdt``` operation in this chunk of code.
```
# Bootstrap GDT
.p2align 2                                # force 4 byte alignment
gdt:
  SEG_NULL				# null seg
  SEG(STA_X|STA_R, 0x0, 0xffffffff)	# code seg
  SEG(STA_W, 0x0, 0xffffffff)	        # data seg

gdtdesc:
  .word   0x17                            # sizeof(gdt) - 1
  .long   gdt                             # address gdt
```
Based on this code, we can imagine the very first GDT is something look like (you can find definition of SEG_NULL and SEG(...) in ```inc/mmu.h```):
```
+---------------------------------------+
|0000|0000|0000|0000|0000|0000|0000|0000|
|SB 31..24|GD..| LM |sd_type..|SB 23..16|
|-------------------|-------------------|    (NULL Segment descriptor)
|0000|0000|0000|0000|0000|0000|0000|0000|
|Segment base 15...0|   Limit 15...0.   |
+---------------------------------------+
+---------------------------------------+
|0000|0000|1100|1111|1001|1010|0000|0000|
|SB 31..24|GD..| LM |sd_type..|SB 23..16|
|-------------------|-------------------|    (Code Segment descriptor)
|1111|1111|1111|1111|1111|1111|1111|1111|
|Segment base 15...0|   Limit 15...0.   |
+---------------------------------------+
+---------------------------------------+
|0000|0000|1100|1111|1001|0010|0000|0000|
|SB 31..24|GD..| LM |sd_type..|SB 23..16|
|-------------------|-------------------|    (Data Segment descriptor)
|1111|1111|1111|1111|1111|1111|1111|1111|
|Segment base 15...0|   Limit 15...0.   |
+---------------------------------------+
```
  
  
### System calls, exceptions and interrupts on x86
#### Interrupt handler:
As we know, in order to process the system call or to raise an exception, programs use ```int``` instruction to generate an interrupt. As a result, once we have our ```interrupt handler```, we are able to handle not only interrupts, but also exceptions and system calls. Here, x86 system is able to deal with up to 256 different interrupts. All 256 interrupt cases are stored in IDT(interrupt descriptor table).  
  
**An operating system can use the ```iret``` instruction to return from an ```int``` instruction. It pops the saved values during the int instruction from the stack, and resumes execution at the saved %eip.**

#### To understand IDT
The main reason of using segment descriptors is to tell the kernel or the process some information about the code they are going to execute, such as the location of the code, the size or direction of it. IDT, interrupt descriptor table, is constructed by 256 different segment descriptors, and each of them tell us the destination the kernel want to reach when corresponding trap/interrupt/exception happens. What we need to do in this lab is to simply construct a small part of this table by using the imformation provided to us.
  
  
### Use of specific assembly code:
```
pushal, popal     - push/pop EAX,EBX,ECX,EDX,ESP,EBP,ESI,EDI
```
