
obj/user/buggyhello2.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 30 80 00       	mov    0x803000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 75 00 00 00       	call   8000c4 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800062:	e8 ec 00 00 00       	call   800153 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x39>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80008d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800091:	89 34 24             	mov    %esi,(%esp)
  800094:	e8 9b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800099:	e8 0a 00 00 00       	call   8000a8 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    
  8000a5:	00 00                	add    %al,(%eax)
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ae:	e8 30 05 00 00       	call   8005e3 <close_all>
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 42 00 00 00       	call   800101 <sys_env_destroy>
}
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d5:	89 c3                	mov    %eax,%ebx
  8000d7:	89 c7                	mov    %eax,%edi
  8000d9:	89 c6                	mov    %eax,%esi
  8000db:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f2:	89 d1                	mov    %edx,%ecx
  8000f4:	89 d3                	mov    %edx,%ebx
  8000f6:	89 d7                	mov    %edx,%edi
  8000f8:	89 d6                	mov    %edx,%esi
  8000fa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	57                   	push   %edi
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010f:	b8 03 00 00 00       	mov    $0x3,%eax
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	89 cb                	mov    %ecx,%ebx
  800119:	89 cf                	mov    %ecx,%edi
  80011b:	89 ce                	mov    %ecx,%esi
  80011d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80011f:	85 c0                	test   %eax,%eax
  800121:	7e 28                	jle    80014b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800123:	89 44 24 10          	mov    %eax,0x10(%esp)
  800127:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 38 1f 80 	movl   $0x801f38,0x8(%esp)
  800136:	00 
  800137:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013e:	00 
  80013f:	c7 04 24 55 1f 80 00 	movl   $0x801f55,(%esp)
  800146:	e8 29 10 00 00       	call   801174 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014b:	83 c4 2c             	add    $0x2c,%esp
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 02 00 00 00       	mov    $0x2,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <sys_yield>:

void
sys_yield(void)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800182:	89 d1                	mov    %edx,%ecx
  800184:	89 d3                	mov    %edx,%ebx
  800186:	89 d7                	mov    %edx,%edi
  800188:	89 d6                	mov    %edx,%esi
  80018a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019a:	be 00 00 00 00       	mov    $0x0,%esi
  80019f:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	89 f7                	mov    %esi,%edi
  8001af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b1:	85 c0                	test   %eax,%eax
  8001b3:	7e 28                	jle    8001dd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 08 38 1f 80 	movl   $0x801f38,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 55 1f 80 00 	movl   $0x801f55,(%esp)
  8001d8:	e8 97 0f 00 00       	call   801174 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001dd:	83 c4 2c             	add    $0x2c,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800204:	85 c0                	test   %eax,%eax
  800206:	7e 28                	jle    800230 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800208:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800213:	00 
  800214:	c7 44 24 08 38 1f 80 	movl   $0x801f38,0x8(%esp)
  80021b:	00 
  80021c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800223:	00 
  800224:	c7 04 24 55 1f 80 00 	movl   $0x801f55,(%esp)
  80022b:	e8 44 0f 00 00       	call   801174 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800230:	83 c4 2c             	add    $0x2c,%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    

00800238 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800241:	bb 00 00 00 00       	mov    $0x0,%ebx
  800246:	b8 06 00 00 00       	mov    $0x6,%eax
  80024b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	89 df                	mov    %ebx,%edi
  800253:	89 de                	mov    %ebx,%esi
  800255:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800257:	85 c0                	test   %eax,%eax
  800259:	7e 28                	jle    800283 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800266:	00 
  800267:	c7 44 24 08 38 1f 80 	movl   $0x801f38,0x8(%esp)
  80026e:	00 
  80026f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800276:	00 
  800277:	c7 04 24 55 1f 80 00 	movl   $0x801f55,(%esp)
  80027e:	e8 f1 0e 00 00       	call   801174 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800283:	83 c4 2c             	add    $0x2c,%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5f                   	pop    %edi
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800294:	bb 00 00 00 00       	mov    $0x0,%ebx
  800299:	b8 08 00 00 00       	mov    $0x8,%eax
  80029e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a4:	89 df                	mov    %ebx,%edi
  8002a6:	89 de                	mov    %ebx,%esi
  8002a8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	7e 28                	jle    8002d6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 08 38 1f 80 	movl   $0x801f38,0x8(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c9:	00 
  8002ca:	c7 04 24 55 1f 80 00 	movl   $0x801f55,(%esp)
  8002d1:	e8 9e 0e 00 00       	call   801174 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002d6:	83 c4 2c             	add    $0x2c,%esp
  8002d9:	5b                   	pop    %ebx
  8002da:	5e                   	pop    %esi
  8002db:	5f                   	pop    %edi
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ec:	b8 09 00 00 00       	mov    $0x9,%eax
  8002f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	89 df                	mov    %ebx,%edi
  8002f9:	89 de                	mov    %ebx,%esi
  8002fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	7e 28                	jle    800329 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800301:	89 44 24 10          	mov    %eax,0x10(%esp)
  800305:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80030c:	00 
  80030d:	c7 44 24 08 38 1f 80 	movl   $0x801f38,0x8(%esp)
  800314:	00 
  800315:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031c:	00 
  80031d:	c7 04 24 55 1f 80 00 	movl   $0x801f55,(%esp)
  800324:	e8 4b 0e 00 00       	call   801174 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800329:	83 c4 2c             	add    $0x2c,%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800344:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800347:	8b 55 08             	mov    0x8(%ebp),%edx
  80034a:	89 df                	mov    %ebx,%edi
  80034c:	89 de                	mov    %ebx,%esi
  80034e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800350:	85 c0                	test   %eax,%eax
  800352:	7e 28                	jle    80037c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800354:	89 44 24 10          	mov    %eax,0x10(%esp)
  800358:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80035f:	00 
  800360:	c7 44 24 08 38 1f 80 	movl   $0x801f38,0x8(%esp)
  800367:	00 
  800368:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80036f:	00 
  800370:	c7 04 24 55 1f 80 00 	movl   $0x801f55,(%esp)
  800377:	e8 f8 0d 00 00       	call   801174 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80037c:	83 c4 2c             	add    $0x2c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038a:	be 00 00 00 00       	mov    $0x0,%esi
  80038f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800394:	8b 7d 14             	mov    0x14(%ebp),%edi
  800397:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80039a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039d:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003a2:	5b                   	pop    %ebx
  8003a3:	5e                   	pop    %esi
  8003a4:	5f                   	pop    %edi
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	57                   	push   %edi
  8003ab:	56                   	push   %esi
  8003ac:	53                   	push   %ebx
  8003ad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bd:	89 cb                	mov    %ecx,%ebx
  8003bf:	89 cf                	mov    %ecx,%edi
  8003c1:	89 ce                	mov    %ecx,%esi
  8003c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	7e 28                	jle    8003f1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003cd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003d4:	00 
  8003d5:	c7 44 24 08 38 1f 80 	movl   $0x801f38,0x8(%esp)
  8003dc:	00 
  8003dd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003e4:	00 
  8003e5:	c7 04 24 55 1f 80 00 	movl   $0x801f55,(%esp)
  8003ec:	e8 83 0d 00 00       	call   801174 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003f1:	83 c4 2c             	add    $0x2c,%esp
  8003f4:	5b                   	pop    %ebx
  8003f5:	5e                   	pop    %esi
  8003f6:	5f                   	pop    %edi
  8003f7:	5d                   	pop    %ebp
  8003f8:	c3                   	ret    
  8003f9:	00 00                	add    %al,(%eax)
	...

008003fc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	05 00 00 00 30       	add    $0x30000000,%eax
  800407:	c1 e8 0c             	shr    $0xc,%eax
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800412:	8b 45 08             	mov    0x8(%ebp),%eax
  800415:	89 04 24             	mov    %eax,(%esp)
  800418:	e8 df ff ff ff       	call   8003fc <fd2num>
  80041d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800422:	c1 e0 0c             	shl    $0xc,%eax
}
  800425:	c9                   	leave  
  800426:	c3                   	ret    

00800427 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	53                   	push   %ebx
  80042b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80042e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800433:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800435:	89 c2                	mov    %eax,%edx
  800437:	c1 ea 16             	shr    $0x16,%edx
  80043a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800441:	f6 c2 01             	test   $0x1,%dl
  800444:	74 11                	je     800457 <fd_alloc+0x30>
  800446:	89 c2                	mov    %eax,%edx
  800448:	c1 ea 0c             	shr    $0xc,%edx
  80044b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800452:	f6 c2 01             	test   $0x1,%dl
  800455:	75 09                	jne    800460 <fd_alloc+0x39>
			*fd_store = fd;
  800457:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800459:	b8 00 00 00 00       	mov    $0x0,%eax
  80045e:	eb 17                	jmp    800477 <fd_alloc+0x50>
  800460:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800465:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80046a:	75 c7                	jne    800433 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80046c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800472:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800477:	5b                   	pop    %ebx
  800478:	5d                   	pop    %ebp
  800479:	c3                   	ret    

0080047a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800480:	83 f8 1f             	cmp    $0x1f,%eax
  800483:	77 36                	ja     8004bb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800485:	05 00 00 0d 00       	add    $0xd0000,%eax
  80048a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80048d:	89 c2                	mov    %eax,%edx
  80048f:	c1 ea 16             	shr    $0x16,%edx
  800492:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800499:	f6 c2 01             	test   $0x1,%dl
  80049c:	74 24                	je     8004c2 <fd_lookup+0x48>
  80049e:	89 c2                	mov    %eax,%edx
  8004a0:	c1 ea 0c             	shr    $0xc,%edx
  8004a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004aa:	f6 c2 01             	test   $0x1,%dl
  8004ad:	74 1a                	je     8004c9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b2:	89 02                	mov    %eax,(%edx)
	return 0;
  8004b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b9:	eb 13                	jmp    8004ce <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004c0:	eb 0c                	jmp    8004ce <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004c7:	eb 05                	jmp    8004ce <fd_lookup+0x54>
  8004c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    

008004d0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	53                   	push   %ebx
  8004d4:	83 ec 14             	sub    $0x14,%esp
  8004d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8004dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e2:	eb 0e                	jmp    8004f2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8004e4:	39 08                	cmp    %ecx,(%eax)
  8004e6:	75 09                	jne    8004f1 <dev_lookup+0x21>
			*dev = devtab[i];
  8004e8:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ef:	eb 33                	jmp    800524 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004f1:	42                   	inc    %edx
  8004f2:	8b 04 95 e0 1f 80 00 	mov    0x801fe0(,%edx,4),%eax
  8004f9:	85 c0                	test   %eax,%eax
  8004fb:	75 e7                	jne    8004e4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004fd:	a1 04 40 80 00       	mov    0x804004,%eax
  800502:	8b 40 48             	mov    0x48(%eax),%eax
  800505:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800509:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050d:	c7 04 24 64 1f 80 00 	movl   $0x801f64,(%esp)
  800514:	e8 53 0d 00 00       	call   80126c <cprintf>
	*dev = 0;
  800519:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80051f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800524:	83 c4 14             	add    $0x14,%esp
  800527:	5b                   	pop    %ebx
  800528:	5d                   	pop    %ebp
  800529:	c3                   	ret    

0080052a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	56                   	push   %esi
  80052e:	53                   	push   %ebx
  80052f:	83 ec 30             	sub    $0x30,%esp
  800532:	8b 75 08             	mov    0x8(%ebp),%esi
  800535:	8a 45 0c             	mov    0xc(%ebp),%al
  800538:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80053b:	89 34 24             	mov    %esi,(%esp)
  80053e:	e8 b9 fe ff ff       	call   8003fc <fd2num>
  800543:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800546:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054a:	89 04 24             	mov    %eax,(%esp)
  80054d:	e8 28 ff ff ff       	call   80047a <fd_lookup>
  800552:	89 c3                	mov    %eax,%ebx
  800554:	85 c0                	test   %eax,%eax
  800556:	78 05                	js     80055d <fd_close+0x33>
	    || fd != fd2)
  800558:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80055b:	74 0d                	je     80056a <fd_close+0x40>
		return (must_exist ? r : 0);
  80055d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800561:	75 46                	jne    8005a9 <fd_close+0x7f>
  800563:	bb 00 00 00 00       	mov    $0x0,%ebx
  800568:	eb 3f                	jmp    8005a9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80056a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80056d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800571:	8b 06                	mov    (%esi),%eax
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	e8 55 ff ff ff       	call   8004d0 <dev_lookup>
  80057b:	89 c3                	mov    %eax,%ebx
  80057d:	85 c0                	test   %eax,%eax
  80057f:	78 18                	js     800599 <fd_close+0x6f>
		if (dev->dev_close)
  800581:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800584:	8b 40 10             	mov    0x10(%eax),%eax
  800587:	85 c0                	test   %eax,%eax
  800589:	74 09                	je     800594 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80058b:	89 34 24             	mov    %esi,(%esp)
  80058e:	ff d0                	call   *%eax
  800590:	89 c3                	mov    %eax,%ebx
  800592:	eb 05                	jmp    800599 <fd_close+0x6f>
		else
			r = 0;
  800594:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800599:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005a4:	e8 8f fc ff ff       	call   800238 <sys_page_unmap>
	return r;
}
  8005a9:	89 d8                	mov    %ebx,%eax
  8005ab:	83 c4 30             	add    $0x30,%esp
  8005ae:	5b                   	pop    %ebx
  8005af:	5e                   	pop    %esi
  8005b0:	5d                   	pop    %ebp
  8005b1:	c3                   	ret    

008005b2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005b2:	55                   	push   %ebp
  8005b3:	89 e5                	mov    %esp,%ebp
  8005b5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c2:	89 04 24             	mov    %eax,(%esp)
  8005c5:	e8 b0 fe ff ff       	call   80047a <fd_lookup>
  8005ca:	85 c0                	test   %eax,%eax
  8005cc:	78 13                	js     8005e1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005ce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005d5:	00 
  8005d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005d9:	89 04 24             	mov    %eax,(%esp)
  8005dc:	e8 49 ff ff ff       	call   80052a <fd_close>
}
  8005e1:	c9                   	leave  
  8005e2:	c3                   	ret    

008005e3 <close_all>:

void
close_all(void)
{
  8005e3:	55                   	push   %ebp
  8005e4:	89 e5                	mov    %esp,%ebp
  8005e6:	53                   	push   %ebx
  8005e7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005ef:	89 1c 24             	mov    %ebx,(%esp)
  8005f2:	e8 bb ff ff ff       	call   8005b2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005f7:	43                   	inc    %ebx
  8005f8:	83 fb 20             	cmp    $0x20,%ebx
  8005fb:	75 f2                	jne    8005ef <close_all+0xc>
		close(i);
}
  8005fd:	83 c4 14             	add    $0x14,%esp
  800600:	5b                   	pop    %ebx
  800601:	5d                   	pop    %ebp
  800602:	c3                   	ret    

00800603 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800603:	55                   	push   %ebp
  800604:	89 e5                	mov    %esp,%ebp
  800606:	57                   	push   %edi
  800607:	56                   	push   %esi
  800608:	53                   	push   %ebx
  800609:	83 ec 4c             	sub    $0x4c,%esp
  80060c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80060f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800612:	89 44 24 04          	mov    %eax,0x4(%esp)
  800616:	8b 45 08             	mov    0x8(%ebp),%eax
  800619:	89 04 24             	mov    %eax,(%esp)
  80061c:	e8 59 fe ff ff       	call   80047a <fd_lookup>
  800621:	89 c3                	mov    %eax,%ebx
  800623:	85 c0                	test   %eax,%eax
  800625:	0f 88 e1 00 00 00    	js     80070c <dup+0x109>
		return r;
	close(newfdnum);
  80062b:	89 3c 24             	mov    %edi,(%esp)
  80062e:	e8 7f ff ff ff       	call   8005b2 <close>

	newfd = INDEX2FD(newfdnum);
  800633:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800639:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80063c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80063f:	89 04 24             	mov    %eax,(%esp)
  800642:	e8 c5 fd ff ff       	call   80040c <fd2data>
  800647:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800649:	89 34 24             	mov    %esi,(%esp)
  80064c:	e8 bb fd ff ff       	call   80040c <fd2data>
  800651:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800654:	89 d8                	mov    %ebx,%eax
  800656:	c1 e8 16             	shr    $0x16,%eax
  800659:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800660:	a8 01                	test   $0x1,%al
  800662:	74 46                	je     8006aa <dup+0xa7>
  800664:	89 d8                	mov    %ebx,%eax
  800666:	c1 e8 0c             	shr    $0xc,%eax
  800669:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800670:	f6 c2 01             	test   $0x1,%dl
  800673:	74 35                	je     8006aa <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800675:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80067c:	25 07 0e 00 00       	and    $0xe07,%eax
  800681:	89 44 24 10          	mov    %eax,0x10(%esp)
  800685:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800688:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800693:	00 
  800694:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800698:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80069f:	e8 41 fb ff ff       	call   8001e5 <sys_page_map>
  8006a4:	89 c3                	mov    %eax,%ebx
  8006a6:	85 c0                	test   %eax,%eax
  8006a8:	78 3b                	js     8006e5 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	c1 ea 0c             	shr    $0xc,%edx
  8006b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006b9:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006bf:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006ce:	00 
  8006cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006da:	e8 06 fb ff ff       	call   8001e5 <sys_page_map>
  8006df:	89 c3                	mov    %eax,%ebx
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	79 25                	jns    80070a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f0:	e8 43 fb ff ff       	call   800238 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800703:	e8 30 fb ff ff       	call   800238 <sys_page_unmap>
	return r;
  800708:	eb 02                	jmp    80070c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80070a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80070c:	89 d8                	mov    %ebx,%eax
  80070e:	83 c4 4c             	add    $0x4c,%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	53                   	push   %ebx
  80071a:	83 ec 24             	sub    $0x24,%esp
  80071d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800720:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800723:	89 44 24 04          	mov    %eax,0x4(%esp)
  800727:	89 1c 24             	mov    %ebx,(%esp)
  80072a:	e8 4b fd ff ff       	call   80047a <fd_lookup>
  80072f:	85 c0                	test   %eax,%eax
  800731:	78 6d                	js     8007a0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800733:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 04 24             	mov    %eax,(%esp)
  800742:	e8 89 fd ff ff       	call   8004d0 <dev_lookup>
  800747:	85 c0                	test   %eax,%eax
  800749:	78 55                	js     8007a0 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80074b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074e:	8b 50 08             	mov    0x8(%eax),%edx
  800751:	83 e2 03             	and    $0x3,%edx
  800754:	83 fa 01             	cmp    $0x1,%edx
  800757:	75 23                	jne    80077c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800759:	a1 04 40 80 00       	mov    0x804004,%eax
  80075e:	8b 40 48             	mov    0x48(%eax),%eax
  800761:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800765:	89 44 24 04          	mov    %eax,0x4(%esp)
  800769:	c7 04 24 a5 1f 80 00 	movl   $0x801fa5,(%esp)
  800770:	e8 f7 0a 00 00       	call   80126c <cprintf>
		return -E_INVAL;
  800775:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077a:	eb 24                	jmp    8007a0 <read+0x8a>
	}
	if (!dev->dev_read)
  80077c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077f:	8b 52 08             	mov    0x8(%edx),%edx
  800782:	85 d2                	test   %edx,%edx
  800784:	74 15                	je     80079b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800786:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800789:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80078d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800790:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800794:	89 04 24             	mov    %eax,(%esp)
  800797:	ff d2                	call   *%edx
  800799:	eb 05                	jmp    8007a0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80079b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007a0:	83 c4 24             	add    $0x24,%esp
  8007a3:	5b                   	pop    %ebx
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	57                   	push   %edi
  8007aa:	56                   	push   %esi
  8007ab:	53                   	push   %ebx
  8007ac:	83 ec 1c             	sub    $0x1c,%esp
  8007af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007ba:	eb 23                	jmp    8007df <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007bc:	89 f0                	mov    %esi,%eax
  8007be:	29 d8                	sub    %ebx,%eax
  8007c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c7:	01 d8                	add    %ebx,%eax
  8007c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cd:	89 3c 24             	mov    %edi,(%esp)
  8007d0:	e8 41 ff ff ff       	call   800716 <read>
		if (m < 0)
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	78 10                	js     8007e9 <readn+0x43>
			return m;
		if (m == 0)
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	74 0a                	je     8007e7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007dd:	01 c3                	add    %eax,%ebx
  8007df:	39 f3                	cmp    %esi,%ebx
  8007e1:	72 d9                	jb     8007bc <readn+0x16>
  8007e3:	89 d8                	mov    %ebx,%eax
  8007e5:	eb 02                	jmp    8007e9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8007e7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007e9:	83 c4 1c             	add    $0x1c,%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5f                   	pop    %edi
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	83 ec 24             	sub    $0x24,%esp
  8007f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800802:	89 1c 24             	mov    %ebx,(%esp)
  800805:	e8 70 fc ff ff       	call   80047a <fd_lookup>
  80080a:	85 c0                	test   %eax,%eax
  80080c:	78 68                	js     800876 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800811:	89 44 24 04          	mov    %eax,0x4(%esp)
  800815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800818:	8b 00                	mov    (%eax),%eax
  80081a:	89 04 24             	mov    %eax,(%esp)
  80081d:	e8 ae fc ff ff       	call   8004d0 <dev_lookup>
  800822:	85 c0                	test   %eax,%eax
  800824:	78 50                	js     800876 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800826:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800829:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082d:	75 23                	jne    800852 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80082f:	a1 04 40 80 00       	mov    0x804004,%eax
  800834:	8b 40 48             	mov    0x48(%eax),%eax
  800837:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80083b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083f:	c7 04 24 c1 1f 80 00 	movl   $0x801fc1,(%esp)
  800846:	e8 21 0a 00 00       	call   80126c <cprintf>
		return -E_INVAL;
  80084b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800850:	eb 24                	jmp    800876 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800852:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800855:	8b 52 0c             	mov    0xc(%edx),%edx
  800858:	85 d2                	test   %edx,%edx
  80085a:	74 15                	je     800871 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80085c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80085f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800863:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800866:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80086a:	89 04 24             	mov    %eax,(%esp)
  80086d:	ff d2                	call   *%edx
  80086f:	eb 05                	jmp    800876 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800871:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800876:	83 c4 24             	add    $0x24,%esp
  800879:	5b                   	pop    %ebx
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <seek>:

int
seek(int fdnum, off_t offset)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800882:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800885:	89 44 24 04          	mov    %eax,0x4(%esp)
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	89 04 24             	mov    %eax,(%esp)
  80088f:	e8 e6 fb ff ff       	call   80047a <fd_lookup>
  800894:	85 c0                	test   %eax,%eax
  800896:	78 0e                	js     8008a6 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800898:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	83 ec 24             	sub    $0x24,%esp
  8008af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b9:	89 1c 24             	mov    %ebx,(%esp)
  8008bc:	e8 b9 fb ff ff       	call   80047a <fd_lookup>
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	78 61                	js     800926 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008cf:	8b 00                	mov    (%eax),%eax
  8008d1:	89 04 24             	mov    %eax,(%esp)
  8008d4:	e8 f7 fb ff ff       	call   8004d0 <dev_lookup>
  8008d9:	85 c0                	test   %eax,%eax
  8008db:	78 49                	js     800926 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008e4:	75 23                	jne    800909 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008e6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008eb:	8b 40 48             	mov    0x48(%eax),%eax
  8008ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f6:	c7 04 24 84 1f 80 00 	movl   $0x801f84,(%esp)
  8008fd:	e8 6a 09 00 00       	call   80126c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800902:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800907:	eb 1d                	jmp    800926 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800909:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80090c:	8b 52 18             	mov    0x18(%edx),%edx
  80090f:	85 d2                	test   %edx,%edx
  800911:	74 0e                	je     800921 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800913:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800916:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80091a:	89 04 24             	mov    %eax,(%esp)
  80091d:	ff d2                	call   *%edx
  80091f:	eb 05                	jmp    800926 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800921:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800926:	83 c4 24             	add    $0x24,%esp
  800929:	5b                   	pop    %ebx
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	53                   	push   %ebx
  800930:	83 ec 24             	sub    $0x24,%esp
  800933:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800936:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800939:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	89 04 24             	mov    %eax,(%esp)
  800943:	e8 32 fb ff ff       	call   80047a <fd_lookup>
  800948:	85 c0                	test   %eax,%eax
  80094a:	78 52                	js     80099e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80094c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80094f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800953:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800956:	8b 00                	mov    (%eax),%eax
  800958:	89 04 24             	mov    %eax,(%esp)
  80095b:	e8 70 fb ff ff       	call   8004d0 <dev_lookup>
  800960:	85 c0                	test   %eax,%eax
  800962:	78 3a                	js     80099e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800964:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800967:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80096b:	74 2c                	je     800999 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80096d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800970:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800977:	00 00 00 
	stat->st_isdir = 0;
  80097a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800981:	00 00 00 
	stat->st_dev = dev;
  800984:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80098a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80098e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800991:	89 14 24             	mov    %edx,(%esp)
  800994:	ff 50 14             	call   *0x14(%eax)
  800997:	eb 05                	jmp    80099e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800999:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80099e:	83 c4 24             	add    $0x24,%esp
  8009a1:	5b                   	pop    %ebx
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009b3:	00 
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	89 04 24             	mov    %eax,(%esp)
  8009ba:	e8 fe 01 00 00       	call   800bbd <open>
  8009bf:	89 c3                	mov    %eax,%ebx
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 1b                	js     8009e0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cc:	89 1c 24             	mov    %ebx,(%esp)
  8009cf:	e8 58 ff ff ff       	call   80092c <fstat>
  8009d4:	89 c6                	mov    %eax,%esi
	close(fd);
  8009d6:	89 1c 24             	mov    %ebx,(%esp)
  8009d9:	e8 d4 fb ff ff       	call   8005b2 <close>
	return r;
  8009de:	89 f3                	mov    %esi,%ebx
}
  8009e0:	89 d8                	mov    %ebx,%eax
  8009e2:	83 c4 10             	add    $0x10,%esp
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    
  8009e9:	00 00                	add    %al,(%eax)
	...

008009ec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	56                   	push   %esi
  8009f0:	53                   	push   %ebx
  8009f1:	83 ec 10             	sub    $0x10,%esp
  8009f4:	89 c3                	mov    %eax,%ebx
  8009f6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8009f8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009ff:	75 11                	jne    800a12 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a01:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a08:	e8 20 12 00 00       	call   801c2d <ipc_find_env>
  800a0d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a12:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a19:	00 
  800a1a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a21:	00 
  800a22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a26:	a1 00 40 80 00       	mov    0x804000,%eax
  800a2b:	89 04 24             	mov    %eax,(%esp)
  800a2e:	e8 90 11 00 00       	call   801bc3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a3a:	00 
  800a3b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a46:	e8 11 11 00 00       	call   801b5c <ipc_recv>
}
  800a4b:	83 c4 10             	add    $0x10,%esp
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a66:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a70:	b8 02 00 00 00       	mov    $0x2,%eax
  800a75:	e8 72 ff ff ff       	call   8009ec <fsipc>
}
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
  800a85:	8b 40 0c             	mov    0xc(%eax),%eax
  800a88:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	b8 06 00 00 00       	mov    $0x6,%eax
  800a97:	e8 50 ff ff ff       	call   8009ec <fsipc>
}
  800a9c:	c9                   	leave  
  800a9d:	c3                   	ret    

00800a9e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	53                   	push   %ebx
  800aa2:	83 ec 14             	sub    $0x14,%esp
  800aa5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 40 0c             	mov    0xc(%eax),%eax
  800aae:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ab3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab8:	b8 05 00 00 00       	mov    $0x5,%eax
  800abd:	e8 2a ff ff ff       	call   8009ec <fsipc>
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	78 2b                	js     800af1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ac6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800acd:	00 
  800ace:	89 1c 24             	mov    %ebx,(%esp)
  800ad1:	e8 61 0d 00 00       	call   801837 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ad6:	a1 80 50 80 00       	mov    0x805080,%eax
  800adb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ae1:	a1 84 50 80 00       	mov    0x805084,%eax
  800ae6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af1:	83 c4 14             	add    $0x14,%esp
  800af4:	5b                   	pop    %ebx
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800afd:	c7 44 24 08 f0 1f 80 	movl   $0x801ff0,0x8(%esp)
  800b04:	00 
  800b05:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800b0c:	00 
  800b0d:	c7 04 24 0e 20 80 00 	movl   $0x80200e,(%esp)
  800b14:	e8 5b 06 00 00       	call   801174 <_panic>

00800b19 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 10             	sub    $0x10,%esp
  800b21:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b24:	8b 45 08             	mov    0x8(%ebp),%eax
  800b27:	8b 40 0c             	mov    0xc(%eax),%eax
  800b2a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b2f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3f:	e8 a8 fe ff ff       	call   8009ec <fsipc>
  800b44:	89 c3                	mov    %eax,%ebx
  800b46:	85 c0                	test   %eax,%eax
  800b48:	78 6a                	js     800bb4 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800b4a:	39 c6                	cmp    %eax,%esi
  800b4c:	73 24                	jae    800b72 <devfile_read+0x59>
  800b4e:	c7 44 24 0c 19 20 80 	movl   $0x802019,0xc(%esp)
  800b55:	00 
  800b56:	c7 44 24 08 20 20 80 	movl   $0x802020,0x8(%esp)
  800b5d:	00 
  800b5e:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b65:	00 
  800b66:	c7 04 24 0e 20 80 00 	movl   $0x80200e,(%esp)
  800b6d:	e8 02 06 00 00       	call   801174 <_panic>
	assert(r <= PGSIZE);
  800b72:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b77:	7e 24                	jle    800b9d <devfile_read+0x84>
  800b79:	c7 44 24 0c 35 20 80 	movl   $0x802035,0xc(%esp)
  800b80:	00 
  800b81:	c7 44 24 08 20 20 80 	movl   $0x802020,0x8(%esp)
  800b88:	00 
  800b89:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800b90:	00 
  800b91:	c7 04 24 0e 20 80 00 	movl   $0x80200e,(%esp)
  800b98:	e8 d7 05 00 00       	call   801174 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b9d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba1:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ba8:	00 
  800ba9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bac:	89 04 24             	mov    %eax,(%esp)
  800baf:	e8 fc 0d 00 00       	call   8019b0 <memmove>
	return r;
}
  800bb4:	89 d8                	mov    %ebx,%eax
  800bb6:	83 c4 10             	add    $0x10,%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 20             	sub    $0x20,%esp
  800bc5:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bc8:	89 34 24             	mov    %esi,(%esp)
  800bcb:	e8 34 0c 00 00       	call   801804 <strlen>
  800bd0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bd5:	7f 60                	jg     800c37 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bda:	89 04 24             	mov    %eax,(%esp)
  800bdd:	e8 45 f8 ff ff       	call   800427 <fd_alloc>
  800be2:	89 c3                	mov    %eax,%ebx
  800be4:	85 c0                	test   %eax,%eax
  800be6:	78 54                	js     800c3c <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800be8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bec:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bf3:	e8 3f 0c 00 00       	call   801837 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c00:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c03:	b8 01 00 00 00       	mov    $0x1,%eax
  800c08:	e8 df fd ff ff       	call   8009ec <fsipc>
  800c0d:	89 c3                	mov    %eax,%ebx
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	79 15                	jns    800c28 <open+0x6b>
		fd_close(fd, 0);
  800c13:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c1a:	00 
  800c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1e:	89 04 24             	mov    %eax,(%esp)
  800c21:	e8 04 f9 ff ff       	call   80052a <fd_close>
		return r;
  800c26:	eb 14                	jmp    800c3c <open+0x7f>
	}

	return fd2num(fd);
  800c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2b:	89 04 24             	mov    %eax,(%esp)
  800c2e:	e8 c9 f7 ff ff       	call   8003fc <fd2num>
  800c33:	89 c3                	mov    %eax,%ebx
  800c35:	eb 05                	jmp    800c3c <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c37:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c3c:	89 d8                	mov    %ebx,%eax
  800c3e:	83 c4 20             	add    $0x20,%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 08 00 00 00       	mov    $0x8,%eax
  800c55:	e8 92 fd ff ff       	call   8009ec <fsipc>
}
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 10             	sub    $0x10,%esp
  800c64:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	89 04 24             	mov    %eax,(%esp)
  800c6d:	e8 9a f7 ff ff       	call   80040c <fd2data>
  800c72:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800c74:	c7 44 24 04 41 20 80 	movl   $0x802041,0x4(%esp)
  800c7b:	00 
  800c7c:	89 34 24             	mov    %esi,(%esp)
  800c7f:	e8 b3 0b 00 00       	call   801837 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c84:	8b 43 04             	mov    0x4(%ebx),%eax
  800c87:	2b 03                	sub    (%ebx),%eax
  800c89:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800c8f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800c96:	00 00 00 
	stat->st_dev = &devpipe;
  800c99:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  800ca0:	30 80 00 
	return 0;
}
  800ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca8:	83 c4 10             	add    $0x10,%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 14             	sub    $0x14,%esp
  800cb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800cb9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cc4:	e8 6f f5 ff ff       	call   800238 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800cc9:	89 1c 24             	mov    %ebx,(%esp)
  800ccc:	e8 3b f7 ff ff       	call   80040c <fd2data>
  800cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cdc:	e8 57 f5 ff ff       	call   800238 <sys_page_unmap>
}
  800ce1:	83 c4 14             	add    $0x14,%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 2c             	sub    $0x2c,%esp
  800cf0:	89 c7                	mov    %eax,%edi
  800cf2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800cf5:	a1 04 40 80 00       	mov    0x804004,%eax
  800cfa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800cfd:	89 3c 24             	mov    %edi,(%esp)
  800d00:	e8 6f 0f 00 00       	call   801c74 <pageref>
  800d05:	89 c6                	mov    %eax,%esi
  800d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d0a:	89 04 24             	mov    %eax,(%esp)
  800d0d:	e8 62 0f 00 00       	call   801c74 <pageref>
  800d12:	39 c6                	cmp    %eax,%esi
  800d14:	0f 94 c0             	sete   %al
  800d17:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800d1a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d20:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800d23:	39 cb                	cmp    %ecx,%ebx
  800d25:	75 08                	jne    800d2f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800d27:	83 c4 2c             	add    $0x2c,%esp
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800d2f:	83 f8 01             	cmp    $0x1,%eax
  800d32:	75 c1                	jne    800cf5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d34:	8b 42 58             	mov    0x58(%edx),%eax
  800d37:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800d3e:	00 
  800d3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d43:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d47:	c7 04 24 48 20 80 00 	movl   $0x802048,(%esp)
  800d4e:	e8 19 05 00 00       	call   80126c <cprintf>
  800d53:	eb a0                	jmp    800cf5 <_pipeisclosed+0xe>

00800d55 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 1c             	sub    $0x1c,%esp
  800d5e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800d61:	89 34 24             	mov    %esi,(%esp)
  800d64:	e8 a3 f6 ff ff       	call   80040c <fd2data>
  800d69:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800d70:	eb 3c                	jmp    800dae <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800d72:	89 da                	mov    %ebx,%edx
  800d74:	89 f0                	mov    %esi,%eax
  800d76:	e8 6c ff ff ff       	call   800ce7 <_pipeisclosed>
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	75 38                	jne    800db7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800d7f:	e8 ee f3 ff ff       	call   800172 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d84:	8b 43 04             	mov    0x4(%ebx),%eax
  800d87:	8b 13                	mov    (%ebx),%edx
  800d89:	83 c2 20             	add    $0x20,%edx
  800d8c:	39 d0                	cmp    %edx,%eax
  800d8e:	73 e2                	jae    800d72 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d90:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d93:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800d96:	89 c2                	mov    %eax,%edx
  800d98:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800d9e:	79 05                	jns    800da5 <devpipe_write+0x50>
  800da0:	4a                   	dec    %edx
  800da1:	83 ca e0             	or     $0xffffffe0,%edx
  800da4:	42                   	inc    %edx
  800da5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800da9:	40                   	inc    %eax
  800daa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800dad:	47                   	inc    %edi
  800dae:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800db1:	75 d1                	jne    800d84 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800db3:	89 f8                	mov    %edi,%eax
  800db5:	eb 05                	jmp    800dbc <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800db7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800dbc:	83 c4 1c             	add    $0x1c,%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 1c             	sub    $0x1c,%esp
  800dcd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800dd0:	89 3c 24             	mov    %edi,(%esp)
  800dd3:	e8 34 f6 ff ff       	call   80040c <fd2data>
  800dd8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800dda:	be 00 00 00 00       	mov    $0x0,%esi
  800ddf:	eb 3a                	jmp    800e1b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800de1:	85 f6                	test   %esi,%esi
  800de3:	74 04                	je     800de9 <devpipe_read+0x25>
				return i;
  800de5:	89 f0                	mov    %esi,%eax
  800de7:	eb 40                	jmp    800e29 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800de9:	89 da                	mov    %ebx,%edx
  800deb:	89 f8                	mov    %edi,%eax
  800ded:	e8 f5 fe ff ff       	call   800ce7 <_pipeisclosed>
  800df2:	85 c0                	test   %eax,%eax
  800df4:	75 2e                	jne    800e24 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800df6:	e8 77 f3 ff ff       	call   800172 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800dfb:	8b 03                	mov    (%ebx),%eax
  800dfd:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e00:	74 df                	je     800de1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800e02:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800e07:	79 05                	jns    800e0e <devpipe_read+0x4a>
  800e09:	48                   	dec    %eax
  800e0a:	83 c8 e0             	or     $0xffffffe0,%eax
  800e0d:	40                   	inc    %eax
  800e0e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800e12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e15:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800e18:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e1a:	46                   	inc    %esi
  800e1b:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e1e:	75 db                	jne    800dfb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800e20:	89 f0                	mov    %esi,%eax
  800e22:	eb 05                	jmp    800e29 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e24:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800e29:	83 c4 1c             	add    $0x1c,%esp
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	53                   	push   %ebx
  800e37:	83 ec 3c             	sub    $0x3c,%esp
  800e3a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800e3d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e40:	89 04 24             	mov    %eax,(%esp)
  800e43:	e8 df f5 ff ff       	call   800427 <fd_alloc>
  800e48:	89 c3                	mov    %eax,%ebx
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	0f 88 45 01 00 00    	js     800f97 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e52:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e59:	00 
  800e5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e68:	e8 24 f3 ff ff       	call   800191 <sys_page_alloc>
  800e6d:	89 c3                	mov    %eax,%ebx
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	0f 88 20 01 00 00    	js     800f97 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800e77:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e7a:	89 04 24             	mov    %eax,(%esp)
  800e7d:	e8 a5 f5 ff ff       	call   800427 <fd_alloc>
  800e82:	89 c3                	mov    %eax,%ebx
  800e84:	85 c0                	test   %eax,%eax
  800e86:	0f 88 f8 00 00 00    	js     800f84 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e8c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e93:	00 
  800e94:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ea2:	e8 ea f2 ff ff       	call   800191 <sys_page_alloc>
  800ea7:	89 c3                	mov    %eax,%ebx
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	0f 88 d3 00 00 00    	js     800f84 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800eb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eb4:	89 04 24             	mov    %eax,(%esp)
  800eb7:	e8 50 f5 ff ff       	call   80040c <fd2data>
  800ebc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ebe:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ec5:	00 
  800ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ed1:	e8 bb f2 ff ff       	call   800191 <sys_page_alloc>
  800ed6:	89 c3                	mov    %eax,%ebx
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	0f 88 91 00 00 00    	js     800f71 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ee0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ee3:	89 04 24             	mov    %eax,(%esp)
  800ee6:	e8 21 f5 ff ff       	call   80040c <fd2data>
  800eeb:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800ef2:	00 
  800ef3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ef7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800efe:	00 
  800eff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f0a:	e8 d6 f2 ff ff       	call   8001e5 <sys_page_map>
  800f0f:	89 c3                	mov    %eax,%ebx
  800f11:	85 c0                	test   %eax,%eax
  800f13:	78 4c                	js     800f61 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800f15:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800f1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f1e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f23:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800f2a:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800f30:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f33:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f35:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f38:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800f3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f42:	89 04 24             	mov    %eax,(%esp)
  800f45:	e8 b2 f4 ff ff       	call   8003fc <fd2num>
  800f4a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800f4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f4f:	89 04 24             	mov    %eax,(%esp)
  800f52:	e8 a5 f4 ff ff       	call   8003fc <fd2num>
  800f57:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5f:	eb 36                	jmp    800f97 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800f61:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6c:	e8 c7 f2 ff ff       	call   800238 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  800f71:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f7f:	e8 b4 f2 ff ff       	call   800238 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  800f84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f92:	e8 a1 f2 ff ff       	call   800238 <sys_page_unmap>
    err:
	return r;
}
  800f97:	89 d8                	mov    %ebx,%eax
  800f99:	83 c4 3c             	add    $0x3c,%esp
  800f9c:	5b                   	pop    %ebx
  800f9d:	5e                   	pop    %esi
  800f9e:	5f                   	pop    %edi
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800faa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fae:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb1:	89 04 24             	mov    %eax,(%esp)
  800fb4:	e8 c1 f4 ff ff       	call   80047a <fd_lookup>
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 15                	js     800fd2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc0:	89 04 24             	mov    %eax,(%esp)
  800fc3:	e8 44 f4 ff ff       	call   80040c <fd2data>
	return _pipeisclosed(fd, p);
  800fc8:	89 c2                	mov    %eax,%edx
  800fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcd:	e8 15 fd ff ff       	call   800ce7 <_pipeisclosed>
}
  800fd2:	c9                   	leave  
  800fd3:	c3                   	ret    

00800fd4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdc:	5d                   	pop    %ebp
  800fdd:	c3                   	ret    

00800fde <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800fe4:	c7 44 24 04 60 20 80 	movl   $0x802060,0x4(%esp)
  800feb:	00 
  800fec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fef:	89 04 24             	mov    %eax,(%esp)
  800ff2:	e8 40 08 00 00       	call   801837 <strcpy>
	return 0;
}
  800ff7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffc:	c9                   	leave  
  800ffd:	c3                   	ret    

00800ffe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80100a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80100f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801015:	eb 30                	jmp    801047 <devcons_write+0x49>
		m = n - tot;
  801017:	8b 75 10             	mov    0x10(%ebp),%esi
  80101a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80101c:	83 fe 7f             	cmp    $0x7f,%esi
  80101f:	76 05                	jbe    801026 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801021:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801026:	89 74 24 08          	mov    %esi,0x8(%esp)
  80102a:	03 45 0c             	add    0xc(%ebp),%eax
  80102d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801031:	89 3c 24             	mov    %edi,(%esp)
  801034:	e8 77 09 00 00       	call   8019b0 <memmove>
		sys_cputs(buf, m);
  801039:	89 74 24 04          	mov    %esi,0x4(%esp)
  80103d:	89 3c 24             	mov    %edi,(%esp)
  801040:	e8 7f f0 ff ff       	call   8000c4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801045:	01 f3                	add    %esi,%ebx
  801047:	89 d8                	mov    %ebx,%eax
  801049:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80104c:	72 c9                	jb     801017 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80104e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801054:	5b                   	pop    %ebx
  801055:	5e                   	pop    %esi
  801056:	5f                   	pop    %edi
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80105f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801063:	75 07                	jne    80106c <devcons_read+0x13>
  801065:	eb 25                	jmp    80108c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801067:	e8 06 f1 ff ff       	call   800172 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80106c:	e8 71 f0 ff ff       	call   8000e2 <sys_cgetc>
  801071:	85 c0                	test   %eax,%eax
  801073:	74 f2                	je     801067 <devcons_read+0xe>
  801075:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801077:	85 c0                	test   %eax,%eax
  801079:	78 1d                	js     801098 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80107b:	83 f8 04             	cmp    $0x4,%eax
  80107e:	74 13                	je     801093 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801080:	8b 45 0c             	mov    0xc(%ebp),%eax
  801083:	88 10                	mov    %dl,(%eax)
	return 1;
  801085:	b8 01 00 00 00       	mov    $0x1,%eax
  80108a:	eb 0c                	jmp    801098 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80108c:	b8 00 00 00 00       	mov    $0x0,%eax
  801091:	eb 05                	jmp    801098 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801093:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8010a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8010a6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ad:	00 
  8010ae:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010b1:	89 04 24             	mov    %eax,(%esp)
  8010b4:	e8 0b f0 ff ff       	call   8000c4 <sys_cputs>
}
  8010b9:	c9                   	leave  
  8010ba:	c3                   	ret    

008010bb <getchar>:

int
getchar(void)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8010c1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010c8:	00 
  8010c9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d7:	e8 3a f6 ff ff       	call   800716 <read>
	if (r < 0)
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	78 0f                	js     8010ef <getchar+0x34>
		return r;
	if (r < 1)
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	7e 06                	jle    8010ea <getchar+0x2f>
		return -E_EOF;
	return c;
  8010e4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010e8:	eb 05                	jmp    8010ef <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8010ea:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801101:	89 04 24             	mov    %eax,(%esp)
  801104:	e8 71 f3 ff ff       	call   80047a <fd_lookup>
  801109:	85 c0                	test   %eax,%eax
  80110b:	78 11                	js     80111e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80110d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801110:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801116:	39 10                	cmp    %edx,(%eax)
  801118:	0f 94 c0             	sete   %al
  80111b:	0f b6 c0             	movzbl %al,%eax
}
  80111e:	c9                   	leave  
  80111f:	c3                   	ret    

00801120 <opencons>:

int
opencons(void)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801126:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801129:	89 04 24             	mov    %eax,(%esp)
  80112c:	e8 f6 f2 ff ff       	call   800427 <fd_alloc>
  801131:	85 c0                	test   %eax,%eax
  801133:	78 3c                	js     801171 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801135:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80113c:	00 
  80113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801140:	89 44 24 04          	mov    %eax,0x4(%esp)
  801144:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80114b:	e8 41 f0 ff ff       	call   800191 <sys_page_alloc>
  801150:	85 c0                	test   %eax,%eax
  801152:	78 1d                	js     801171 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801154:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80115a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80115f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801162:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801169:	89 04 24             	mov    %eax,(%esp)
  80116c:	e8 8b f2 ff ff       	call   8003fc <fd2num>
}
  801171:	c9                   	leave  
  801172:	c3                   	ret    
	...

00801174 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80117c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80117f:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  801185:	e8 c9 ef ff ff       	call   800153 <sys_getenvid>
  80118a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801191:	8b 55 08             	mov    0x8(%ebp),%edx
  801194:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801198:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80119c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a0:	c7 04 24 6c 20 80 00 	movl   $0x80206c,(%esp)
  8011a7:	e8 c0 00 00 00       	call   80126c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011b3:	89 04 24             	mov    %eax,(%esp)
  8011b6:	e8 50 00 00 00       	call   80120b <vcprintf>
	cprintf("\n");
  8011bb:	c7 04 24 59 20 80 00 	movl   $0x802059,(%esp)
  8011c2:	e8 a5 00 00 00       	call   80126c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011c7:	cc                   	int3   
  8011c8:	eb fd                	jmp    8011c7 <_panic+0x53>
	...

008011cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 14             	sub    $0x14,%esp
  8011d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011d6:	8b 03                	mov    (%ebx),%eax
  8011d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8011df:	40                   	inc    %eax
  8011e0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8011e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011e7:	75 19                	jne    801202 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8011e9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011f0:	00 
  8011f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8011f4:	89 04 24             	mov    %eax,(%esp)
  8011f7:	e8 c8 ee ff ff       	call   8000c4 <sys_cputs>
		b->idx = 0;
  8011fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801202:	ff 43 04             	incl   0x4(%ebx)
}
  801205:	83 c4 14             	add    $0x14,%esp
  801208:	5b                   	pop    %ebx
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801214:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80121b:	00 00 00 
	b.cnt = 0;
  80121e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801225:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801228:	8b 45 0c             	mov    0xc(%ebp),%eax
  80122b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	89 44 24 08          	mov    %eax,0x8(%esp)
  801236:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80123c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801240:	c7 04 24 cc 11 80 00 	movl   $0x8011cc,(%esp)
  801247:	e8 82 01 00 00       	call   8013ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80124c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801252:	89 44 24 04          	mov    %eax,0x4(%esp)
  801256:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80125c:	89 04 24             	mov    %eax,(%esp)
  80125f:	e8 60 ee ff ff       	call   8000c4 <sys_cputs>

	return b.cnt;
}
  801264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801275:	89 44 24 04          	mov    %eax,0x4(%esp)
  801279:	8b 45 08             	mov    0x8(%ebp),%eax
  80127c:	89 04 24             	mov    %eax,(%esp)
  80127f:	e8 87 ff ff ff       	call   80120b <vcprintf>
	va_end(ap);

	return cnt;
}
  801284:	c9                   	leave  
  801285:	c3                   	ret    
	...

00801288 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	57                   	push   %edi
  80128c:	56                   	push   %esi
  80128d:	53                   	push   %ebx
  80128e:	83 ec 3c             	sub    $0x3c,%esp
  801291:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801294:	89 d7                	mov    %edx,%edi
  801296:	8b 45 08             	mov    0x8(%ebp),%eax
  801299:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80129c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8012a5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	75 08                	jne    8012b4 <printnum+0x2c>
  8012ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012af:	39 45 10             	cmp    %eax,0x10(%ebp)
  8012b2:	77 57                	ja     80130b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012b4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012b8:	4b                   	dec    %ebx
  8012b9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8012c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8012c8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8012cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012d3:	00 
  8012d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012d7:	89 04 24             	mov    %eax,(%esp)
  8012da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e1:	e8 d2 09 00 00       	call   801cb8 <__udivdi3>
  8012e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012ee:	89 04 24             	mov    %eax,(%esp)
  8012f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012f5:	89 fa                	mov    %edi,%edx
  8012f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012fa:	e8 89 ff ff ff       	call   801288 <printnum>
  8012ff:	eb 0f                	jmp    801310 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801301:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801305:	89 34 24             	mov    %esi,(%esp)
  801308:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80130b:	4b                   	dec    %ebx
  80130c:	85 db                	test   %ebx,%ebx
  80130e:	7f f1                	jg     801301 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801310:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801314:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801318:	8b 45 10             	mov    0x10(%ebp),%eax
  80131b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80131f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801326:	00 
  801327:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80132a:	89 04 24             	mov    %eax,(%esp)
  80132d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801330:	89 44 24 04          	mov    %eax,0x4(%esp)
  801334:	e8 9f 0a 00 00       	call   801dd8 <__umoddi3>
  801339:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80133d:	0f be 80 8f 20 80 00 	movsbl 0x80208f(%eax),%eax
  801344:	89 04 24             	mov    %eax,(%esp)
  801347:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80134a:	83 c4 3c             	add    $0x3c,%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5f                   	pop    %edi
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801355:	83 fa 01             	cmp    $0x1,%edx
  801358:	7e 0e                	jle    801368 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80135a:	8b 10                	mov    (%eax),%edx
  80135c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80135f:	89 08                	mov    %ecx,(%eax)
  801361:	8b 02                	mov    (%edx),%eax
  801363:	8b 52 04             	mov    0x4(%edx),%edx
  801366:	eb 22                	jmp    80138a <getuint+0x38>
	else if (lflag)
  801368:	85 d2                	test   %edx,%edx
  80136a:	74 10                	je     80137c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80136c:	8b 10                	mov    (%eax),%edx
  80136e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801371:	89 08                	mov    %ecx,(%eax)
  801373:	8b 02                	mov    (%edx),%eax
  801375:	ba 00 00 00 00       	mov    $0x0,%edx
  80137a:	eb 0e                	jmp    80138a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80137c:	8b 10                	mov    (%eax),%edx
  80137e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801381:	89 08                	mov    %ecx,(%eax)
  801383:	8b 02                	mov    (%edx),%eax
  801385:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80138a:	5d                   	pop    %ebp
  80138b:	c3                   	ret    

0080138c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801392:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801395:	8b 10                	mov    (%eax),%edx
  801397:	3b 50 04             	cmp    0x4(%eax),%edx
  80139a:	73 08                	jae    8013a4 <sprintputch+0x18>
		*b->buf++ = ch;
  80139c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139f:	88 0a                	mov    %cl,(%edx)
  8013a1:	42                   	inc    %edx
  8013a2:	89 10                	mov    %edx,(%eax)
}
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8013ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8013b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c4:	89 04 24             	mov    %eax,(%esp)
  8013c7:	e8 02 00 00 00       	call   8013ce <vprintfmt>
	va_end(ap);
}
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 4c             	sub    $0x4c,%esp
  8013d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013da:	8b 75 10             	mov    0x10(%ebp),%esi
  8013dd:	eb 12                	jmp    8013f1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	0f 84 8b 03 00 00    	je     801772 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8013e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013eb:	89 04 24             	mov    %eax,(%esp)
  8013ee:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8013f1:	0f b6 06             	movzbl (%esi),%eax
  8013f4:	46                   	inc    %esi
  8013f5:	83 f8 25             	cmp    $0x25,%eax
  8013f8:	75 e5                	jne    8013df <vprintfmt+0x11>
  8013fa:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8013fe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801405:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80140a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801411:	b9 00 00 00 00       	mov    $0x0,%ecx
  801416:	eb 26                	jmp    80143e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801418:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80141b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80141f:	eb 1d                	jmp    80143e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801421:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801424:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801428:	eb 14                	jmp    80143e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80142a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80142d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801434:	eb 08                	jmp    80143e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801436:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801439:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80143e:	0f b6 06             	movzbl (%esi),%eax
  801441:	8d 56 01             	lea    0x1(%esi),%edx
  801444:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801447:	8a 16                	mov    (%esi),%dl
  801449:	83 ea 23             	sub    $0x23,%edx
  80144c:	80 fa 55             	cmp    $0x55,%dl
  80144f:	0f 87 01 03 00 00    	ja     801756 <vprintfmt+0x388>
  801455:	0f b6 d2             	movzbl %dl,%edx
  801458:	ff 24 95 e0 21 80 00 	jmp    *0x8021e0(,%edx,4)
  80145f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801462:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801467:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80146a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80146e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801471:	8d 50 d0             	lea    -0x30(%eax),%edx
  801474:	83 fa 09             	cmp    $0x9,%edx
  801477:	77 2a                	ja     8014a3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801479:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80147a:	eb eb                	jmp    801467 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80147c:	8b 45 14             	mov    0x14(%ebp),%eax
  80147f:	8d 50 04             	lea    0x4(%eax),%edx
  801482:	89 55 14             	mov    %edx,0x14(%ebp)
  801485:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801487:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80148a:	eb 17                	jmp    8014a3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80148c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801490:	78 98                	js     80142a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801492:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801495:	eb a7                	jmp    80143e <vprintfmt+0x70>
  801497:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80149a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8014a1:	eb 9b                	jmp    80143e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8014a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014a7:	79 95                	jns    80143e <vprintfmt+0x70>
  8014a9:	eb 8b                	jmp    801436 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8014ab:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8014af:	eb 8d                	jmp    80143e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8014b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b4:	8d 50 04             	lea    0x4(%eax),%edx
  8014b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014be:	8b 00                	mov    (%eax),%eax
  8014c0:	89 04 24             	mov    %eax,(%esp)
  8014c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8014c9:	e9 23 ff ff ff       	jmp    8013f1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8014ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d1:	8d 50 04             	lea    0x4(%eax),%edx
  8014d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d7:	8b 00                	mov    (%eax),%eax
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	79 02                	jns    8014df <vprintfmt+0x111>
  8014dd:	f7 d8                	neg    %eax
  8014df:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8014e1:	83 f8 0f             	cmp    $0xf,%eax
  8014e4:	7f 0b                	jg     8014f1 <vprintfmt+0x123>
  8014e6:	8b 04 85 40 23 80 00 	mov    0x802340(,%eax,4),%eax
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	75 23                	jne    801514 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8014f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014f5:	c7 44 24 08 a7 20 80 	movl   $0x8020a7,0x8(%esp)
  8014fc:	00 
  8014fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801501:	8b 45 08             	mov    0x8(%ebp),%eax
  801504:	89 04 24             	mov    %eax,(%esp)
  801507:	e8 9a fe ff ff       	call   8013a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80150c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80150f:	e9 dd fe ff ff       	jmp    8013f1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801514:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801518:	c7 44 24 08 32 20 80 	movl   $0x802032,0x8(%esp)
  80151f:	00 
  801520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801524:	8b 55 08             	mov    0x8(%ebp),%edx
  801527:	89 14 24             	mov    %edx,(%esp)
  80152a:	e8 77 fe ff ff       	call   8013a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80152f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801532:	e9 ba fe ff ff       	jmp    8013f1 <vprintfmt+0x23>
  801537:	89 f9                	mov    %edi,%ecx
  801539:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80153c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80153f:	8b 45 14             	mov    0x14(%ebp),%eax
  801542:	8d 50 04             	lea    0x4(%eax),%edx
  801545:	89 55 14             	mov    %edx,0x14(%ebp)
  801548:	8b 30                	mov    (%eax),%esi
  80154a:	85 f6                	test   %esi,%esi
  80154c:	75 05                	jne    801553 <vprintfmt+0x185>
				p = "(null)";
  80154e:	be a0 20 80 00       	mov    $0x8020a0,%esi
			if (width > 0 && padc != '-')
  801553:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801557:	0f 8e 84 00 00 00    	jle    8015e1 <vprintfmt+0x213>
  80155d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801561:	74 7e                	je     8015e1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801563:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801567:	89 34 24             	mov    %esi,(%esp)
  80156a:	e8 ab 02 00 00       	call   80181a <strnlen>
  80156f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801572:	29 c2                	sub    %eax,%edx
  801574:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801577:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80157b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80157e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801581:	89 de                	mov    %ebx,%esi
  801583:	89 d3                	mov    %edx,%ebx
  801585:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801587:	eb 0b                	jmp    801594 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801589:	89 74 24 04          	mov    %esi,0x4(%esp)
  80158d:	89 3c 24             	mov    %edi,(%esp)
  801590:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801593:	4b                   	dec    %ebx
  801594:	85 db                	test   %ebx,%ebx
  801596:	7f f1                	jg     801589 <vprintfmt+0x1bb>
  801598:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80159b:	89 f3                	mov    %esi,%ebx
  80159d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8015a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	79 05                	jns    8015ac <vprintfmt+0x1de>
  8015a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015af:	29 c2                	sub    %eax,%edx
  8015b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015b4:	eb 2b                	jmp    8015e1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8015b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8015ba:	74 18                	je     8015d4 <vprintfmt+0x206>
  8015bc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8015bf:	83 fa 5e             	cmp    $0x5e,%edx
  8015c2:	76 10                	jbe    8015d4 <vprintfmt+0x206>
					putch('?', putdat);
  8015c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015cf:	ff 55 08             	call   *0x8(%ebp)
  8015d2:	eb 0a                	jmp    8015de <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8015d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015d8:	89 04 24             	mov    %eax,(%esp)
  8015db:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015de:	ff 4d e4             	decl   -0x1c(%ebp)
  8015e1:	0f be 06             	movsbl (%esi),%eax
  8015e4:	46                   	inc    %esi
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	74 21                	je     80160a <vprintfmt+0x23c>
  8015e9:	85 ff                	test   %edi,%edi
  8015eb:	78 c9                	js     8015b6 <vprintfmt+0x1e8>
  8015ed:	4f                   	dec    %edi
  8015ee:	79 c6                	jns    8015b6 <vprintfmt+0x1e8>
  8015f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015f3:	89 de                	mov    %ebx,%esi
  8015f5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8015f8:	eb 18                	jmp    801612 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801605:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801607:	4b                   	dec    %ebx
  801608:	eb 08                	jmp    801612 <vprintfmt+0x244>
  80160a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80160d:	89 de                	mov    %ebx,%esi
  80160f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801612:	85 db                	test   %ebx,%ebx
  801614:	7f e4                	jg     8015fa <vprintfmt+0x22c>
  801616:	89 7d 08             	mov    %edi,0x8(%ebp)
  801619:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80161e:	e9 ce fd ff ff       	jmp    8013f1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801623:	83 f9 01             	cmp    $0x1,%ecx
  801626:	7e 10                	jle    801638 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801628:	8b 45 14             	mov    0x14(%ebp),%eax
  80162b:	8d 50 08             	lea    0x8(%eax),%edx
  80162e:	89 55 14             	mov    %edx,0x14(%ebp)
  801631:	8b 30                	mov    (%eax),%esi
  801633:	8b 78 04             	mov    0x4(%eax),%edi
  801636:	eb 26                	jmp    80165e <vprintfmt+0x290>
	else if (lflag)
  801638:	85 c9                	test   %ecx,%ecx
  80163a:	74 12                	je     80164e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80163c:	8b 45 14             	mov    0x14(%ebp),%eax
  80163f:	8d 50 04             	lea    0x4(%eax),%edx
  801642:	89 55 14             	mov    %edx,0x14(%ebp)
  801645:	8b 30                	mov    (%eax),%esi
  801647:	89 f7                	mov    %esi,%edi
  801649:	c1 ff 1f             	sar    $0x1f,%edi
  80164c:	eb 10                	jmp    80165e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80164e:	8b 45 14             	mov    0x14(%ebp),%eax
  801651:	8d 50 04             	lea    0x4(%eax),%edx
  801654:	89 55 14             	mov    %edx,0x14(%ebp)
  801657:	8b 30                	mov    (%eax),%esi
  801659:	89 f7                	mov    %esi,%edi
  80165b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80165e:	85 ff                	test   %edi,%edi
  801660:	78 0a                	js     80166c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801662:	b8 0a 00 00 00       	mov    $0xa,%eax
  801667:	e9 ac 00 00 00       	jmp    801718 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80166c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801670:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801677:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80167a:	f7 de                	neg    %esi
  80167c:	83 d7 00             	adc    $0x0,%edi
  80167f:	f7 df                	neg    %edi
			}
			base = 10;
  801681:	b8 0a 00 00 00       	mov    $0xa,%eax
  801686:	e9 8d 00 00 00       	jmp    801718 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80168b:	89 ca                	mov    %ecx,%edx
  80168d:	8d 45 14             	lea    0x14(%ebp),%eax
  801690:	e8 bd fc ff ff       	call   801352 <getuint>
  801695:	89 c6                	mov    %eax,%esi
  801697:	89 d7                	mov    %edx,%edi
			base = 10;
  801699:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80169e:	eb 78                	jmp    801718 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8016a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016a4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016ab:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8016ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016b2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016b9:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8016bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8016cd:	e9 1f fd ff ff       	jmp    8013f1 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8016d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8016dd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8016e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8016eb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8016ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f1:	8d 50 04             	lea    0x4(%eax),%edx
  8016f4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8016f7:	8b 30                	mov    (%eax),%esi
  8016f9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8016fe:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801703:	eb 13                	jmp    801718 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801705:	89 ca                	mov    %ecx,%edx
  801707:	8d 45 14             	lea    0x14(%ebp),%eax
  80170a:	e8 43 fc ff ff       	call   801352 <getuint>
  80170f:	89 c6                	mov    %eax,%esi
  801711:	89 d7                	mov    %edx,%edi
			base = 16;
  801713:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801718:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80171c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801720:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801723:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801727:	89 44 24 08          	mov    %eax,0x8(%esp)
  80172b:	89 34 24             	mov    %esi,(%esp)
  80172e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801732:	89 da                	mov    %ebx,%edx
  801734:	8b 45 08             	mov    0x8(%ebp),%eax
  801737:	e8 4c fb ff ff       	call   801288 <printnum>
			break;
  80173c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80173f:	e9 ad fc ff ff       	jmp    8013f1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801748:	89 04 24             	mov    %eax,(%esp)
  80174b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801751:	e9 9b fc ff ff       	jmp    8013f1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801756:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80175a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801761:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801764:	eb 01                	jmp    801767 <vprintfmt+0x399>
  801766:	4e                   	dec    %esi
  801767:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80176b:	75 f9                	jne    801766 <vprintfmt+0x398>
  80176d:	e9 7f fc ff ff       	jmp    8013f1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801772:	83 c4 4c             	add    $0x4c,%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5f                   	pop    %edi
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	83 ec 28             	sub    $0x28,%esp
  801780:	8b 45 08             	mov    0x8(%ebp),%eax
  801783:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801786:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801789:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80178d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801790:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801797:	85 c0                	test   %eax,%eax
  801799:	74 30                	je     8017cb <vsnprintf+0x51>
  80179b:	85 d2                	test   %edx,%edx
  80179d:	7e 33                	jle    8017d2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80179f:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b4:	c7 04 24 8c 13 80 00 	movl   $0x80138c,(%esp)
  8017bb:	e8 0e fc ff ff       	call   8013ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8017c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8017c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c9:	eb 0c                	jmp    8017d7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8017cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d0:	eb 05                	jmp    8017d7 <vsnprintf+0x5d>
  8017d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8017df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8017e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f7:	89 04 24             	mov    %eax,(%esp)
  8017fa:	e8 7b ff ff ff       	call   80177a <vsnprintf>
	va_end(ap);

	return rc;
}
  8017ff:	c9                   	leave  
  801800:	c3                   	ret    
  801801:	00 00                	add    %al,(%eax)
	...

00801804 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80180a:	b8 00 00 00 00       	mov    $0x0,%eax
  80180f:	eb 01                	jmp    801812 <strlen+0xe>
		n++;
  801811:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801812:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801816:	75 f9                	jne    801811 <strlen+0xd>
		n++;
	return n;
}
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801820:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801823:	b8 00 00 00 00       	mov    $0x0,%eax
  801828:	eb 01                	jmp    80182b <strnlen+0x11>
		n++;
  80182a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80182b:	39 d0                	cmp    %edx,%eax
  80182d:	74 06                	je     801835 <strnlen+0x1b>
  80182f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801833:	75 f5                	jne    80182a <strnlen+0x10>
		n++;
	return n;
}
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	53                   	push   %ebx
  80183b:	8b 45 08             	mov    0x8(%ebp),%eax
  80183e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801841:	ba 00 00 00 00       	mov    $0x0,%edx
  801846:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801849:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80184c:	42                   	inc    %edx
  80184d:	84 c9                	test   %cl,%cl
  80184f:	75 f5                	jne    801846 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801851:	5b                   	pop    %ebx
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	53                   	push   %ebx
  801858:	83 ec 08             	sub    $0x8,%esp
  80185b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80185e:	89 1c 24             	mov    %ebx,(%esp)
  801861:	e8 9e ff ff ff       	call   801804 <strlen>
	strcpy(dst + len, src);
  801866:	8b 55 0c             	mov    0xc(%ebp),%edx
  801869:	89 54 24 04          	mov    %edx,0x4(%esp)
  80186d:	01 d8                	add    %ebx,%eax
  80186f:	89 04 24             	mov    %eax,(%esp)
  801872:	e8 c0 ff ff ff       	call   801837 <strcpy>
	return dst;
}
  801877:	89 d8                	mov    %ebx,%eax
  801879:	83 c4 08             	add    $0x8,%esp
  80187c:	5b                   	pop    %ebx
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	56                   	push   %esi
  801883:	53                   	push   %ebx
  801884:	8b 45 08             	mov    0x8(%ebp),%eax
  801887:	8b 55 0c             	mov    0xc(%ebp),%edx
  80188a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80188d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801892:	eb 0c                	jmp    8018a0 <strncpy+0x21>
		*dst++ = *src;
  801894:	8a 1a                	mov    (%edx),%bl
  801896:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801899:	80 3a 01             	cmpb   $0x1,(%edx)
  80189c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80189f:	41                   	inc    %ecx
  8018a0:	39 f1                	cmp    %esi,%ecx
  8018a2:	75 f0                	jne    801894 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8018a4:	5b                   	pop    %ebx
  8018a5:	5e                   	pop    %esi
  8018a6:	5d                   	pop    %ebp
  8018a7:	c3                   	ret    

008018a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	56                   	push   %esi
  8018ac:	53                   	push   %ebx
  8018ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8018b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018b3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018b6:	85 d2                	test   %edx,%edx
  8018b8:	75 0a                	jne    8018c4 <strlcpy+0x1c>
  8018ba:	89 f0                	mov    %esi,%eax
  8018bc:	eb 1a                	jmp    8018d8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8018be:	88 18                	mov    %bl,(%eax)
  8018c0:	40                   	inc    %eax
  8018c1:	41                   	inc    %ecx
  8018c2:	eb 02                	jmp    8018c6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018c4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8018c6:	4a                   	dec    %edx
  8018c7:	74 0a                	je     8018d3 <strlcpy+0x2b>
  8018c9:	8a 19                	mov    (%ecx),%bl
  8018cb:	84 db                	test   %bl,%bl
  8018cd:	75 ef                	jne    8018be <strlcpy+0x16>
  8018cf:	89 c2                	mov    %eax,%edx
  8018d1:	eb 02                	jmp    8018d5 <strlcpy+0x2d>
  8018d3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8018d5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8018d8:	29 f0                	sub    %esi,%eax
}
  8018da:	5b                   	pop    %ebx
  8018db:	5e                   	pop    %esi
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8018e7:	eb 02                	jmp    8018eb <strcmp+0xd>
		p++, q++;
  8018e9:	41                   	inc    %ecx
  8018ea:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8018eb:	8a 01                	mov    (%ecx),%al
  8018ed:	84 c0                	test   %al,%al
  8018ef:	74 04                	je     8018f5 <strcmp+0x17>
  8018f1:	3a 02                	cmp    (%edx),%al
  8018f3:	74 f4                	je     8018e9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018f5:	0f b6 c0             	movzbl %al,%eax
  8018f8:	0f b6 12             	movzbl (%edx),%edx
  8018fb:	29 d0                	sub    %edx,%eax
}
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	53                   	push   %ebx
  801903:	8b 45 08             	mov    0x8(%ebp),%eax
  801906:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801909:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80190c:	eb 03                	jmp    801911 <strncmp+0x12>
		n--, p++, q++;
  80190e:	4a                   	dec    %edx
  80190f:	40                   	inc    %eax
  801910:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801911:	85 d2                	test   %edx,%edx
  801913:	74 14                	je     801929 <strncmp+0x2a>
  801915:	8a 18                	mov    (%eax),%bl
  801917:	84 db                	test   %bl,%bl
  801919:	74 04                	je     80191f <strncmp+0x20>
  80191b:	3a 19                	cmp    (%ecx),%bl
  80191d:	74 ef                	je     80190e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80191f:	0f b6 00             	movzbl (%eax),%eax
  801922:	0f b6 11             	movzbl (%ecx),%edx
  801925:	29 d0                	sub    %edx,%eax
  801927:	eb 05                	jmp    80192e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801929:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80192e:	5b                   	pop    %ebx
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    

00801931 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	8b 45 08             	mov    0x8(%ebp),%eax
  801937:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80193a:	eb 05                	jmp    801941 <strchr+0x10>
		if (*s == c)
  80193c:	38 ca                	cmp    %cl,%dl
  80193e:	74 0c                	je     80194c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801940:	40                   	inc    %eax
  801941:	8a 10                	mov    (%eax),%dl
  801943:	84 d2                	test   %dl,%dl
  801945:	75 f5                	jne    80193c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	8b 45 08             	mov    0x8(%ebp),%eax
  801954:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801957:	eb 05                	jmp    80195e <strfind+0x10>
		if (*s == c)
  801959:	38 ca                	cmp    %cl,%dl
  80195b:	74 07                	je     801964 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80195d:	40                   	inc    %eax
  80195e:	8a 10                	mov    (%eax),%dl
  801960:	84 d2                	test   %dl,%dl
  801962:	75 f5                	jne    801959 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	57                   	push   %edi
  80196a:	56                   	push   %esi
  80196b:	53                   	push   %ebx
  80196c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80196f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801972:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801975:	85 c9                	test   %ecx,%ecx
  801977:	74 30                	je     8019a9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801979:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80197f:	75 25                	jne    8019a6 <memset+0x40>
  801981:	f6 c1 03             	test   $0x3,%cl
  801984:	75 20                	jne    8019a6 <memset+0x40>
		c &= 0xFF;
  801986:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801989:	89 d3                	mov    %edx,%ebx
  80198b:	c1 e3 08             	shl    $0x8,%ebx
  80198e:	89 d6                	mov    %edx,%esi
  801990:	c1 e6 18             	shl    $0x18,%esi
  801993:	89 d0                	mov    %edx,%eax
  801995:	c1 e0 10             	shl    $0x10,%eax
  801998:	09 f0                	or     %esi,%eax
  80199a:	09 d0                	or     %edx,%eax
  80199c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80199e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8019a1:	fc                   	cld    
  8019a2:	f3 ab                	rep stos %eax,%es:(%edi)
  8019a4:	eb 03                	jmp    8019a9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8019a6:	fc                   	cld    
  8019a7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8019a9:	89 f8                	mov    %edi,%eax
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5f                   	pop    %edi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    

008019b0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	57                   	push   %edi
  8019b4:	56                   	push   %esi
  8019b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8019be:	39 c6                	cmp    %eax,%esi
  8019c0:	73 34                	jae    8019f6 <memmove+0x46>
  8019c2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019c5:	39 d0                	cmp    %edx,%eax
  8019c7:	73 2d                	jae    8019f6 <memmove+0x46>
		s += n;
		d += n;
  8019c9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019cc:	f6 c2 03             	test   $0x3,%dl
  8019cf:	75 1b                	jne    8019ec <memmove+0x3c>
  8019d1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019d7:	75 13                	jne    8019ec <memmove+0x3c>
  8019d9:	f6 c1 03             	test   $0x3,%cl
  8019dc:	75 0e                	jne    8019ec <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019de:	83 ef 04             	sub    $0x4,%edi
  8019e1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019e4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8019e7:	fd                   	std    
  8019e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019ea:	eb 07                	jmp    8019f3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019ec:	4f                   	dec    %edi
  8019ed:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8019f0:	fd                   	std    
  8019f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019f3:	fc                   	cld    
  8019f4:	eb 20                	jmp    801a16 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019f6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019fc:	75 13                	jne    801a11 <memmove+0x61>
  8019fe:	a8 03                	test   $0x3,%al
  801a00:	75 0f                	jne    801a11 <memmove+0x61>
  801a02:	f6 c1 03             	test   $0x3,%cl
  801a05:	75 0a                	jne    801a11 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a07:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801a0a:	89 c7                	mov    %eax,%edi
  801a0c:	fc                   	cld    
  801a0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a0f:	eb 05                	jmp    801a16 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801a11:	89 c7                	mov    %eax,%edi
  801a13:	fc                   	cld    
  801a14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a16:	5e                   	pop    %esi
  801a17:	5f                   	pop    %edi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a20:	8b 45 10             	mov    0x10(%ebp),%eax
  801a23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a31:	89 04 24             	mov    %eax,(%esp)
  801a34:	e8 77 ff ff ff       	call   8019b0 <memmove>
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	57                   	push   %edi
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a44:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a4a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4f:	eb 16                	jmp    801a67 <memcmp+0x2c>
		if (*s1 != *s2)
  801a51:	8a 04 17             	mov    (%edi,%edx,1),%al
  801a54:	42                   	inc    %edx
  801a55:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801a59:	38 c8                	cmp    %cl,%al
  801a5b:	74 0a                	je     801a67 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801a5d:	0f b6 c0             	movzbl %al,%eax
  801a60:	0f b6 c9             	movzbl %cl,%ecx
  801a63:	29 c8                	sub    %ecx,%eax
  801a65:	eb 09                	jmp    801a70 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a67:	39 da                	cmp    %ebx,%edx
  801a69:	75 e6                	jne    801a51 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801a6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a70:	5b                   	pop    %ebx
  801a71:	5e                   	pop    %esi
  801a72:	5f                   	pop    %edi
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    

00801a75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a7e:	89 c2                	mov    %eax,%edx
  801a80:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a83:	eb 05                	jmp    801a8a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a85:	38 08                	cmp    %cl,(%eax)
  801a87:	74 05                	je     801a8e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801a89:	40                   	inc    %eax
  801a8a:	39 d0                	cmp    %edx,%eax
  801a8c:	72 f7                	jb     801a85 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	57                   	push   %edi
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	8b 55 08             	mov    0x8(%ebp),%edx
  801a99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a9c:	eb 01                	jmp    801a9f <strtol+0xf>
		s++;
  801a9e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a9f:	8a 02                	mov    (%edx),%al
  801aa1:	3c 20                	cmp    $0x20,%al
  801aa3:	74 f9                	je     801a9e <strtol+0xe>
  801aa5:	3c 09                	cmp    $0x9,%al
  801aa7:	74 f5                	je     801a9e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801aa9:	3c 2b                	cmp    $0x2b,%al
  801aab:	75 08                	jne    801ab5 <strtol+0x25>
		s++;
  801aad:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801aae:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab3:	eb 13                	jmp    801ac8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ab5:	3c 2d                	cmp    $0x2d,%al
  801ab7:	75 0a                	jne    801ac3 <strtol+0x33>
		s++, neg = 1;
  801ab9:	8d 52 01             	lea    0x1(%edx),%edx
  801abc:	bf 01 00 00 00       	mov    $0x1,%edi
  801ac1:	eb 05                	jmp    801ac8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ac3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ac8:	85 db                	test   %ebx,%ebx
  801aca:	74 05                	je     801ad1 <strtol+0x41>
  801acc:	83 fb 10             	cmp    $0x10,%ebx
  801acf:	75 28                	jne    801af9 <strtol+0x69>
  801ad1:	8a 02                	mov    (%edx),%al
  801ad3:	3c 30                	cmp    $0x30,%al
  801ad5:	75 10                	jne    801ae7 <strtol+0x57>
  801ad7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801adb:	75 0a                	jne    801ae7 <strtol+0x57>
		s += 2, base = 16;
  801add:	83 c2 02             	add    $0x2,%edx
  801ae0:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ae5:	eb 12                	jmp    801af9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801ae7:	85 db                	test   %ebx,%ebx
  801ae9:	75 0e                	jne    801af9 <strtol+0x69>
  801aeb:	3c 30                	cmp    $0x30,%al
  801aed:	75 05                	jne    801af4 <strtol+0x64>
		s++, base = 8;
  801aef:	42                   	inc    %edx
  801af0:	b3 08                	mov    $0x8,%bl
  801af2:	eb 05                	jmp    801af9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801af4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801af9:	b8 00 00 00 00       	mov    $0x0,%eax
  801afe:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b00:	8a 0a                	mov    (%edx),%cl
  801b02:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801b05:	80 fb 09             	cmp    $0x9,%bl
  801b08:	77 08                	ja     801b12 <strtol+0x82>
			dig = *s - '0';
  801b0a:	0f be c9             	movsbl %cl,%ecx
  801b0d:	83 e9 30             	sub    $0x30,%ecx
  801b10:	eb 1e                	jmp    801b30 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801b12:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b15:	80 fb 19             	cmp    $0x19,%bl
  801b18:	77 08                	ja     801b22 <strtol+0x92>
			dig = *s - 'a' + 10;
  801b1a:	0f be c9             	movsbl %cl,%ecx
  801b1d:	83 e9 57             	sub    $0x57,%ecx
  801b20:	eb 0e                	jmp    801b30 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b22:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b25:	80 fb 19             	cmp    $0x19,%bl
  801b28:	77 12                	ja     801b3c <strtol+0xac>
			dig = *s - 'A' + 10;
  801b2a:	0f be c9             	movsbl %cl,%ecx
  801b2d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b30:	39 f1                	cmp    %esi,%ecx
  801b32:	7d 0c                	jge    801b40 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801b34:	42                   	inc    %edx
  801b35:	0f af c6             	imul   %esi,%eax
  801b38:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801b3a:	eb c4                	jmp    801b00 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801b3c:	89 c1                	mov    %eax,%ecx
  801b3e:	eb 02                	jmp    801b42 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801b40:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801b42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b46:	74 05                	je     801b4d <strtol+0xbd>
		*endptr = (char *) s;
  801b48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b4b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801b4d:	85 ff                	test   %edi,%edi
  801b4f:	74 04                	je     801b55 <strtol+0xc5>
  801b51:	89 c8                	mov    %ecx,%eax
  801b53:	f7 d8                	neg    %eax
}
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5f                   	pop    %edi
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    
	...

00801b5c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	56                   	push   %esi
  801b60:	53                   	push   %ebx
  801b61:	83 ec 10             	sub    $0x10,%esp
  801b64:	8b 75 08             	mov    0x8(%ebp),%esi
  801b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	75 05                	jne    801b76 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801b71:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801b76:	89 04 24             	mov    %eax,(%esp)
  801b79:	e8 29 e8 ff ff       	call   8003a7 <sys_ipc_recv>
	if (!err) {
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	75 26                	jne    801ba8 <ipc_recv+0x4c>
		if (from_env_store) {
  801b82:	85 f6                	test   %esi,%esi
  801b84:	74 0a                	je     801b90 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801b86:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8b:	8b 40 74             	mov    0x74(%eax),%eax
  801b8e:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801b90:	85 db                	test   %ebx,%ebx
  801b92:	74 0a                	je     801b9e <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801b94:	a1 04 40 80 00       	mov    0x804004,%eax
  801b99:	8b 40 78             	mov    0x78(%eax),%eax
  801b9c:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801b9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba3:	8b 40 70             	mov    0x70(%eax),%eax
  801ba6:	eb 14                	jmp    801bbc <ipc_recv+0x60>
	}
	if (from_env_store) {
  801ba8:	85 f6                	test   %esi,%esi
  801baa:	74 06                	je     801bb2 <ipc_recv+0x56>
		*from_env_store = 0;
  801bac:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801bb2:	85 db                	test   %ebx,%ebx
  801bb4:	74 06                	je     801bbc <ipc_recv+0x60>
		*perm_store = 0;
  801bb6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	5b                   	pop    %ebx
  801bc0:	5e                   	pop    %esi
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    

00801bc3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	57                   	push   %edi
  801bc7:	56                   	push   %esi
  801bc8:	53                   	push   %ebx
  801bc9:	83 ec 1c             	sub    $0x1c,%esp
  801bcc:	8b 75 10             	mov    0x10(%ebp),%esi
  801bcf:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801bd2:	85 f6                	test   %esi,%esi
  801bd4:	75 05                	jne    801bdb <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801bd6:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801bdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bdf:	89 74 24 08          	mov    %esi,0x8(%esp)
  801be3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bea:	8b 45 08             	mov    0x8(%ebp),%eax
  801bed:	89 04 24             	mov    %eax,(%esp)
  801bf0:	e8 8f e7 ff ff       	call   800384 <sys_ipc_try_send>
  801bf5:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801bf7:	e8 76 e5 ff ff       	call   800172 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801bfc:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801bff:	74 da                	je     801bdb <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801c01:	85 db                	test   %ebx,%ebx
  801c03:	74 20                	je     801c25 <ipc_send+0x62>
		panic("send fail: %e", err);
  801c05:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c09:	c7 44 24 08 a0 23 80 	movl   $0x8023a0,0x8(%esp)
  801c10:	00 
  801c11:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801c18:	00 
  801c19:	c7 04 24 ae 23 80 00 	movl   $0x8023ae,(%esp)
  801c20:	e8 4f f5 ff ff       	call   801174 <_panic>
	}
	return;
}
  801c25:	83 c4 1c             	add    $0x1c,%esp
  801c28:	5b                   	pop    %ebx
  801c29:	5e                   	pop    %esi
  801c2a:	5f                   	pop    %edi
  801c2b:	5d                   	pop    %ebp
  801c2c:	c3                   	ret    

00801c2d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	53                   	push   %ebx
  801c31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c39:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c40:	89 c2                	mov    %eax,%edx
  801c42:	c1 e2 07             	shl    $0x7,%edx
  801c45:	29 ca                	sub    %ecx,%edx
  801c47:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c4d:	8b 52 50             	mov    0x50(%edx),%edx
  801c50:	39 da                	cmp    %ebx,%edx
  801c52:	75 0f                	jne    801c63 <ipc_find_env+0x36>
			return envs[i].env_id;
  801c54:	c1 e0 07             	shl    $0x7,%eax
  801c57:	29 c8                	sub    %ecx,%eax
  801c59:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c5e:	8b 40 40             	mov    0x40(%eax),%eax
  801c61:	eb 0c                	jmp    801c6f <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c63:	40                   	inc    %eax
  801c64:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c69:	75 ce                	jne    801c39 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c6b:	66 b8 00 00          	mov    $0x0,%ax
}
  801c6f:	5b                   	pop    %ebx
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
	...

00801c74 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c7a:	89 c2                	mov    %eax,%edx
  801c7c:	c1 ea 16             	shr    $0x16,%edx
  801c7f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c86:	f6 c2 01             	test   $0x1,%dl
  801c89:	74 1e                	je     801ca9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c8b:	c1 e8 0c             	shr    $0xc,%eax
  801c8e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c95:	a8 01                	test   $0x1,%al
  801c97:	74 17                	je     801cb0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c99:	c1 e8 0c             	shr    $0xc,%eax
  801c9c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801ca3:	ef 
  801ca4:	0f b7 c0             	movzwl %ax,%eax
  801ca7:	eb 0c                	jmp    801cb5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ca9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cae:	eb 05                	jmp    801cb5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801cb0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    
	...

00801cb8 <__udivdi3>:
  801cb8:	55                   	push   %ebp
  801cb9:	57                   	push   %edi
  801cba:	56                   	push   %esi
  801cbb:	83 ec 10             	sub    $0x10,%esp
  801cbe:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cc2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cca:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cce:	89 cd                	mov    %ecx,%ebp
  801cd0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	75 2c                	jne    801d04 <__udivdi3+0x4c>
  801cd8:	39 f9                	cmp    %edi,%ecx
  801cda:	77 68                	ja     801d44 <__udivdi3+0x8c>
  801cdc:	85 c9                	test   %ecx,%ecx
  801cde:	75 0b                	jne    801ceb <__udivdi3+0x33>
  801ce0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce5:	31 d2                	xor    %edx,%edx
  801ce7:	f7 f1                	div    %ecx
  801ce9:	89 c1                	mov    %eax,%ecx
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	89 f8                	mov    %edi,%eax
  801cef:	f7 f1                	div    %ecx
  801cf1:	89 c7                	mov    %eax,%edi
  801cf3:	89 f0                	mov    %esi,%eax
  801cf5:	f7 f1                	div    %ecx
  801cf7:	89 c6                	mov    %eax,%esi
  801cf9:	89 f0                	mov    %esi,%eax
  801cfb:	89 fa                	mov    %edi,%edx
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	5e                   	pop    %esi
  801d01:	5f                   	pop    %edi
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    
  801d04:	39 f8                	cmp    %edi,%eax
  801d06:	77 2c                	ja     801d34 <__udivdi3+0x7c>
  801d08:	0f bd f0             	bsr    %eax,%esi
  801d0b:	83 f6 1f             	xor    $0x1f,%esi
  801d0e:	75 4c                	jne    801d5c <__udivdi3+0xa4>
  801d10:	39 f8                	cmp    %edi,%eax
  801d12:	bf 00 00 00 00       	mov    $0x0,%edi
  801d17:	72 0a                	jb     801d23 <__udivdi3+0x6b>
  801d19:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d1d:	0f 87 ad 00 00 00    	ja     801dd0 <__udivdi3+0x118>
  801d23:	be 01 00 00 00       	mov    $0x1,%esi
  801d28:	89 f0                	mov    %esi,%eax
  801d2a:	89 fa                	mov    %edi,%edx
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	5e                   	pop    %esi
  801d30:	5f                   	pop    %edi
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    
  801d33:	90                   	nop
  801d34:	31 ff                	xor    %edi,%edi
  801d36:	31 f6                	xor    %esi,%esi
  801d38:	89 f0                	mov    %esi,%eax
  801d3a:	89 fa                	mov    %edi,%edx
  801d3c:	83 c4 10             	add    $0x10,%esp
  801d3f:	5e                   	pop    %esi
  801d40:	5f                   	pop    %edi
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    
  801d43:	90                   	nop
  801d44:	89 fa                	mov    %edi,%edx
  801d46:	89 f0                	mov    %esi,%eax
  801d48:	f7 f1                	div    %ecx
  801d4a:	89 c6                	mov    %eax,%esi
  801d4c:	31 ff                	xor    %edi,%edi
  801d4e:	89 f0                	mov    %esi,%eax
  801d50:	89 fa                	mov    %edi,%edx
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
  801d59:	8d 76 00             	lea    0x0(%esi),%esi
  801d5c:	89 f1                	mov    %esi,%ecx
  801d5e:	d3 e0                	shl    %cl,%eax
  801d60:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d64:	b8 20 00 00 00       	mov    $0x20,%eax
  801d69:	29 f0                	sub    %esi,%eax
  801d6b:	89 ea                	mov    %ebp,%edx
  801d6d:	88 c1                	mov    %al,%cl
  801d6f:	d3 ea                	shr    %cl,%edx
  801d71:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d75:	09 ca                	or     %ecx,%edx
  801d77:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d7b:	89 f1                	mov    %esi,%ecx
  801d7d:	d3 e5                	shl    %cl,%ebp
  801d7f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d83:	89 fd                	mov    %edi,%ebp
  801d85:	88 c1                	mov    %al,%cl
  801d87:	d3 ed                	shr    %cl,%ebp
  801d89:	89 fa                	mov    %edi,%edx
  801d8b:	89 f1                	mov    %esi,%ecx
  801d8d:	d3 e2                	shl    %cl,%edx
  801d8f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d93:	88 c1                	mov    %al,%cl
  801d95:	d3 ef                	shr    %cl,%edi
  801d97:	09 d7                	or     %edx,%edi
  801d99:	89 f8                	mov    %edi,%eax
  801d9b:	89 ea                	mov    %ebp,%edx
  801d9d:	f7 74 24 08          	divl   0x8(%esp)
  801da1:	89 d1                	mov    %edx,%ecx
  801da3:	89 c7                	mov    %eax,%edi
  801da5:	f7 64 24 0c          	mull   0xc(%esp)
  801da9:	39 d1                	cmp    %edx,%ecx
  801dab:	72 17                	jb     801dc4 <__udivdi3+0x10c>
  801dad:	74 09                	je     801db8 <__udivdi3+0x100>
  801daf:	89 fe                	mov    %edi,%esi
  801db1:	31 ff                	xor    %edi,%edi
  801db3:	e9 41 ff ff ff       	jmp    801cf9 <__udivdi3+0x41>
  801db8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dbc:	89 f1                	mov    %esi,%ecx
  801dbe:	d3 e2                	shl    %cl,%edx
  801dc0:	39 c2                	cmp    %eax,%edx
  801dc2:	73 eb                	jae    801daf <__udivdi3+0xf7>
  801dc4:	8d 77 ff             	lea    -0x1(%edi),%esi
  801dc7:	31 ff                	xor    %edi,%edi
  801dc9:	e9 2b ff ff ff       	jmp    801cf9 <__udivdi3+0x41>
  801dce:	66 90                	xchg   %ax,%ax
  801dd0:	31 f6                	xor    %esi,%esi
  801dd2:	e9 22 ff ff ff       	jmp    801cf9 <__udivdi3+0x41>
	...

00801dd8 <__umoddi3>:
  801dd8:	55                   	push   %ebp
  801dd9:	57                   	push   %edi
  801dda:	56                   	push   %esi
  801ddb:	83 ec 20             	sub    $0x20,%esp
  801dde:	8b 44 24 30          	mov    0x30(%esp),%eax
  801de2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801de6:	89 44 24 14          	mov    %eax,0x14(%esp)
  801dea:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801df2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801df6:	89 c7                	mov    %eax,%edi
  801df8:	89 f2                	mov    %esi,%edx
  801dfa:	85 ed                	test   %ebp,%ebp
  801dfc:	75 16                	jne    801e14 <__umoddi3+0x3c>
  801dfe:	39 f1                	cmp    %esi,%ecx
  801e00:	0f 86 a6 00 00 00    	jbe    801eac <__umoddi3+0xd4>
  801e06:	f7 f1                	div    %ecx
  801e08:	89 d0                	mov    %edx,%eax
  801e0a:	31 d2                	xor    %edx,%edx
  801e0c:	83 c4 20             	add    $0x20,%esp
  801e0f:	5e                   	pop    %esi
  801e10:	5f                   	pop    %edi
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    
  801e13:	90                   	nop
  801e14:	39 f5                	cmp    %esi,%ebp
  801e16:	0f 87 ac 00 00 00    	ja     801ec8 <__umoddi3+0xf0>
  801e1c:	0f bd c5             	bsr    %ebp,%eax
  801e1f:	83 f0 1f             	xor    $0x1f,%eax
  801e22:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e26:	0f 84 a8 00 00 00    	je     801ed4 <__umoddi3+0xfc>
  801e2c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e30:	d3 e5                	shl    %cl,%ebp
  801e32:	bf 20 00 00 00       	mov    $0x20,%edi
  801e37:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e3b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e3f:	89 f9                	mov    %edi,%ecx
  801e41:	d3 e8                	shr    %cl,%eax
  801e43:	09 e8                	or     %ebp,%eax
  801e45:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e49:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e4d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e51:	d3 e0                	shl    %cl,%eax
  801e53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e57:	89 f2                	mov    %esi,%edx
  801e59:	d3 e2                	shl    %cl,%edx
  801e5b:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e5f:	d3 e0                	shl    %cl,%eax
  801e61:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e65:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e69:	89 f9                	mov    %edi,%ecx
  801e6b:	d3 e8                	shr    %cl,%eax
  801e6d:	09 d0                	or     %edx,%eax
  801e6f:	d3 ee                	shr    %cl,%esi
  801e71:	89 f2                	mov    %esi,%edx
  801e73:	f7 74 24 18          	divl   0x18(%esp)
  801e77:	89 d6                	mov    %edx,%esi
  801e79:	f7 64 24 0c          	mull   0xc(%esp)
  801e7d:	89 c5                	mov    %eax,%ebp
  801e7f:	89 d1                	mov    %edx,%ecx
  801e81:	39 d6                	cmp    %edx,%esi
  801e83:	72 67                	jb     801eec <__umoddi3+0x114>
  801e85:	74 75                	je     801efc <__umoddi3+0x124>
  801e87:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e8b:	29 e8                	sub    %ebp,%eax
  801e8d:	19 ce                	sbb    %ecx,%esi
  801e8f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e93:	d3 e8                	shr    %cl,%eax
  801e95:	89 f2                	mov    %esi,%edx
  801e97:	89 f9                	mov    %edi,%ecx
  801e99:	d3 e2                	shl    %cl,%edx
  801e9b:	09 d0                	or     %edx,%eax
  801e9d:	89 f2                	mov    %esi,%edx
  801e9f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ea3:	d3 ea                	shr    %cl,%edx
  801ea5:	83 c4 20             	add    $0x20,%esp
  801ea8:	5e                   	pop    %esi
  801ea9:	5f                   	pop    %edi
  801eaa:	5d                   	pop    %ebp
  801eab:	c3                   	ret    
  801eac:	85 c9                	test   %ecx,%ecx
  801eae:	75 0b                	jne    801ebb <__umoddi3+0xe3>
  801eb0:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb5:	31 d2                	xor    %edx,%edx
  801eb7:	f7 f1                	div    %ecx
  801eb9:	89 c1                	mov    %eax,%ecx
  801ebb:	89 f0                	mov    %esi,%eax
  801ebd:	31 d2                	xor    %edx,%edx
  801ebf:	f7 f1                	div    %ecx
  801ec1:	89 f8                	mov    %edi,%eax
  801ec3:	e9 3e ff ff ff       	jmp    801e06 <__umoddi3+0x2e>
  801ec8:	89 f2                	mov    %esi,%edx
  801eca:	83 c4 20             	add    $0x20,%esp
  801ecd:	5e                   	pop    %esi
  801ece:	5f                   	pop    %edi
  801ecf:	5d                   	pop    %ebp
  801ed0:	c3                   	ret    
  801ed1:	8d 76 00             	lea    0x0(%esi),%esi
  801ed4:	39 f5                	cmp    %esi,%ebp
  801ed6:	72 04                	jb     801edc <__umoddi3+0x104>
  801ed8:	39 f9                	cmp    %edi,%ecx
  801eda:	77 06                	ja     801ee2 <__umoddi3+0x10a>
  801edc:	89 f2                	mov    %esi,%edx
  801ede:	29 cf                	sub    %ecx,%edi
  801ee0:	19 ea                	sbb    %ebp,%edx
  801ee2:	89 f8                	mov    %edi,%eax
  801ee4:	83 c4 20             	add    $0x20,%esp
  801ee7:	5e                   	pop    %esi
  801ee8:	5f                   	pop    %edi
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    
  801eeb:	90                   	nop
  801eec:	89 d1                	mov    %edx,%ecx
  801eee:	89 c5                	mov    %eax,%ebp
  801ef0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801ef4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ef8:	eb 8d                	jmp    801e87 <__umoddi3+0xaf>
  801efa:	66 90                	xchg   %ax,%ax
  801efc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f00:	72 ea                	jb     801eec <__umoddi3+0x114>
  801f02:	89 f1                	mov    %esi,%ecx
  801f04:	eb 81                	jmp    801e87 <__umoddi3+0xaf>
