
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 3b 07 00 00       	call   80076c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800041:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800048:	e8 52 0e 00 00       	call   800e9f <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800053:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80005a:	e8 6e 15 00 00       	call   8015cd <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800066:	00 
  800067:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	89 04 24             	mov    %eax,(%esp)
  80007a:	e8 e4 14 00 00       	call   801563 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008e:	cc 
  80008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800096:	e8 61 14 00 00       	call   8014fc <ipc_recv>
}
  80009b:	83 c4 14             	add    $0x14,%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <umain>:

void
umain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	81 ec cc 02 00 00    	sub    $0x2cc,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b2:	b8 20 26 80 00       	mov    $0x802620,%eax
  8000b7:	e8 78 ff ff ff       	call   800034 <xopen>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	79 25                	jns    8000e5 <umain+0x44>
  8000c0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c3:	74 3c                	je     800101 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c9:	c7 44 24 08 2b 26 80 	movl   $0x80262b,0x8(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d8:	00 
  8000d9:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  8000e0:	e8 f7 06 00 00       	call   8007dc <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e5:	c7 44 24 08 e0 27 80 	movl   $0x8027e0,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  8000fc:	e8 db 06 00 00       	call   8007dc <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 55 26 80 00       	mov    $0x802655,%eax
  80010b:	e8 24 ff ff ff       	call   800034 <xopen>
  800110:	85 c0                	test   %eax,%eax
  800112:	79 20                	jns    800134 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800118:	c7 44 24 08 5e 26 80 	movl   $0x80265e,0x8(%esp)
  80011f:	00 
  800120:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800127:	00 
  800128:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  80012f:	e8 a8 06 00 00       	call   8007dc <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800134:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013b:	75 12                	jne    80014f <umain+0xae>
  80013d:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800144:	75 09                	jne    80014f <umain+0xae>
  800146:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014d:	74 1c                	je     80016b <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014f:	c7 44 24 08 04 28 80 	movl   $0x802804,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  800166:	e8 71 06 00 00       	call   8007dc <_panic>
	cprintf("serve_open is good\n");
  80016b:	c7 04 24 76 26 80 00 	movl   $0x802676,(%esp)
  800172:	e8 5d 07 00 00       	call   8008d4 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800177:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800188:	ff 15 1c 30 80 00    	call   *0x80301c
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 20                	jns    8001b2 <umain+0x111>
		panic("file_stat: %e", r);
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	c7 44 24 08 8a 26 80 	movl   $0x80268a,0x8(%esp)
  80019d:	00 
  80019e:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001a5:	00 
  8001a6:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  8001ad:	e8 2a 06 00 00       	call   8007dc <_panic>
	if (strlen(msg) != st.st_size)
  8001b2:	a1 00 30 80 00       	mov    0x803000,%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 ad 0c 00 00       	call   800e6c <strlen>
  8001bf:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c2:	74 34                	je     8001f8 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c4:	a1 00 30 80 00       	mov    0x803000,%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 9b 0c 00 00       	call   800e6c <strlen>
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	c7 44 24 08 34 28 80 	movl   $0x802834,0x8(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8001eb:	00 
  8001ec:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  8001f3:	e8 e4 05 00 00       	call   8007dc <_panic>
	cprintf("file_stat is good\n");
  8001f8:	c7 04 24 98 26 80 00 	movl   $0x802698,(%esp)
  8001ff:	e8 d0 06 00 00       	call   8008d4 <cprintf>

	memset(buf, 0, sizeof buf);
  800204:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800213:	00 
  800214:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80021a:	89 1c 24             	mov    %ebx,(%esp)
  80021d:	e8 ac 0d 00 00       	call   800fce <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800222:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800229:	00 
  80022a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80022e:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800235:	ff 15 10 30 80 00    	call   *0x803010
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 20                	jns    80025f <umain+0x1be>
		panic("file_read: %e", r);
  80023f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800243:	c7 44 24 08 ab 26 80 	movl   $0x8026ab,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  80025a:	e8 7d 05 00 00       	call   8007dc <_panic>
	if (strcmp(buf, msg) != 0)
  80025f:	a1 00 30 80 00       	mov    0x803000,%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	e8 d0 0c 00 00       	call   800f46 <strcmp>
  800276:	85 c0                	test   %eax,%eax
  800278:	74 1c                	je     800296 <umain+0x1f5>
		panic("file_read returned wrong data");
  80027a:	c7 44 24 08 b9 26 80 	movl   $0x8026b9,0x8(%esp)
  800281:	00 
  800282:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800289:	00 
  80028a:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  800291:	e8 46 05 00 00       	call   8007dc <_panic>
	cprintf("file_read is good\n");
  800296:	c7 04 24 d7 26 80 00 	movl   $0x8026d7,(%esp)
  80029d:	e8 32 06 00 00       	call   8008d4 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a9:	ff 15 18 30 80 00    	call   *0x803018
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	79 20                	jns    8002d3 <umain+0x232>
		panic("file_close: %e", r);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	c7 44 24 08 ea 26 80 	movl   $0x8026ea,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  8002ce:	e8 09 05 00 00       	call   8007dc <_panic>
	cprintf("file_close is good\n");
  8002d3:	c7 04 24 f9 26 80 00 	movl   $0x8026f9,(%esp)
  8002da:	e8 f5 05 00 00       	call   8008d4 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002df:	be 00 c0 cc cc       	mov    $0xccccc000,%esi
  8002e4:	8d 7d d8             	lea    -0x28(%ebp),%edi
  8002e7:	b9 04 00 00 00       	mov    $0x4,%ecx
  8002ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	sys_page_unmap(0, FVA);
  8002ee:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  8002f5:	cc 
  8002f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002fd:	e8 36 10 00 00       	call   801338 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800302:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800309:	00 
  80030a:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	ff 15 10 30 80 00    	call   *0x803010
  800320:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800323:	74 20                	je     800345 <umain+0x2a4>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800329:	c7 44 24 08 5c 28 80 	movl   $0x80285c,0x8(%esp)
  800330:	00 
  800331:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800338:	00 
  800339:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  800340:	e8 97 04 00 00       	call   8007dc <_panic>
	cprintf("stale fileid is good\n");
  800345:	c7 04 24 0d 27 80 00 	movl   $0x80270d,(%esp)
  80034c:	e8 83 05 00 00       	call   8008d4 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800351:	ba 02 01 00 00       	mov    $0x102,%edx
  800356:	b8 23 27 80 00       	mov    $0x802723,%eax
  80035b:	e8 d4 fc ff ff       	call   800034 <xopen>
  800360:	85 c0                	test   %eax,%eax
  800362:	79 20                	jns    800384 <umain+0x2e3>
		panic("serve_open /new-file: %e", r);
  800364:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800368:	c7 44 24 08 2d 27 80 	movl   $0x80272d,0x8(%esp)
  80036f:	00 
  800370:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800377:	00 
  800378:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  80037f:	e8 58 04 00 00       	call   8007dc <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800384:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  80038a:	a1 00 30 80 00       	mov    0x803000,%eax
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	e8 d5 0a 00 00       	call   800e6c <strlen>
  800397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039b:	a1 00 30 80 00       	mov    0x803000,%eax
  8003a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a4:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003ab:	ff d3                	call   *%ebx
  8003ad:	89 c3                	mov    %eax,%ebx
  8003af:	a1 00 30 80 00       	mov    0x803000,%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 b0 0a 00 00       	call   800e6c <strlen>
  8003bc:	39 c3                	cmp    %eax,%ebx
  8003be:	74 20                	je     8003e0 <umain+0x33f>
		panic("file_write: %e", r);
  8003c0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003c4:	c7 44 24 08 46 27 80 	movl   $0x802746,0x8(%esp)
  8003cb:	00 
  8003cc:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8003d3:	00 
  8003d4:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  8003db:	e8 fc 03 00 00       	call   8007dc <_panic>
	cprintf("file_write is good\n");
  8003e0:	c7 04 24 55 27 80 00 	movl   $0x802755,(%esp)
  8003e7:	e8 e8 04 00 00       	call   8008d4 <cprintf>

	FVA->fd_offset = 0;
  8003ec:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  8003f3:	00 00 00 
	memset(buf, 0, sizeof buf);
  8003f6:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8003fd:	00 
  8003fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800405:	00 
  800406:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80040c:	89 1c 24             	mov    %ebx,(%esp)
  80040f:	e8 ba 0b 00 00       	call   800fce <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800414:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80041b:	00 
  80041c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800420:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800427:	ff 15 10 30 80 00    	call   *0x803010
  80042d:	89 c3                	mov    %eax,%ebx
  80042f:	85 c0                	test   %eax,%eax
  800431:	79 20                	jns    800453 <umain+0x3b2>
		panic("file_read after file_write: %e", r);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	c7 44 24 08 94 28 80 	movl   $0x802894,0x8(%esp)
  80043e:	00 
  80043f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800446:	00 
  800447:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  80044e:	e8 89 03 00 00       	call   8007dc <_panic>
	if (r != strlen(msg))
  800453:	a1 00 30 80 00       	mov    0x803000,%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 0c 0a 00 00       	call   800e6c <strlen>
  800460:	39 d8                	cmp    %ebx,%eax
  800462:	74 20                	je     800484 <umain+0x3e3>
		panic("file_read after file_write returned wrong length: %d", r);
  800464:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800468:	c7 44 24 08 b4 28 80 	movl   $0x8028b4,0x8(%esp)
  80046f:	00 
  800470:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800477:	00 
  800478:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  80047f:	e8 58 03 00 00       	call   8007dc <_panic>
	if (strcmp(buf, msg) != 0)
  800484:	a1 00 30 80 00       	mov    0x803000,%eax
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 ab 0a 00 00       	call   800f46 <strcmp>
  80049b:	85 c0                	test   %eax,%eax
  80049d:	74 1c                	je     8004bb <umain+0x41a>
		panic("file_read after file_write returned wrong data");
  80049f:	c7 44 24 08 ec 28 80 	movl   $0x8028ec,0x8(%esp)
  8004a6:	00 
  8004a7:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8004ae:	00 
  8004af:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  8004b6:	e8 21 03 00 00       	call   8007dc <_panic>
	cprintf("file_read after file_write is good\n");
  8004bb:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  8004c2:	e8 0d 04 00 00       	call   8008d4 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 20 26 80 00 	movl   $0x802620,(%esp)
  8004d6:	e8 fa 18 00 00       	call   801dd5 <open>
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	79 25                	jns    800504 <umain+0x463>
  8004df:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004e2:	74 3c                	je     800520 <umain+0x47f>
		panic("open /not-found: %e", r);
  8004e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e8:	c7 44 24 08 31 26 80 	movl   $0x802631,0x8(%esp)
  8004ef:	00 
  8004f0:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8004f7:	00 
  8004f8:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  8004ff:	e8 d8 02 00 00       	call   8007dc <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800504:	c7 44 24 08 69 27 80 	movl   $0x802769,0x8(%esp)
  80050b:	00 
  80050c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800513:	00 
  800514:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  80051b:	e8 bc 02 00 00       	call   8007dc <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800520:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800527:	00 
  800528:	c7 04 24 55 26 80 00 	movl   $0x802655,(%esp)
  80052f:	e8 a1 18 00 00       	call   801dd5 <open>
  800534:	85 c0                	test   %eax,%eax
  800536:	79 20                	jns    800558 <umain+0x4b7>
		panic("open /newmotd: %e", r);
  800538:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053c:	c7 44 24 08 64 26 80 	movl   $0x802664,0x8(%esp)
  800543:	00 
  800544:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80054b:	00 
  80054c:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  800553:	e8 84 02 00 00       	call   8007dc <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800558:	05 00 00 0d 00       	add    $0xd0000,%eax
  80055d:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800560:	83 38 66             	cmpl   $0x66,(%eax)
  800563:	75 0c                	jne    800571 <umain+0x4d0>
  800565:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  800569:	75 06                	jne    800571 <umain+0x4d0>
  80056b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80056f:	74 1c                	je     80058d <umain+0x4ec>
		panic("open did not fill struct Fd correctly\n");
  800571:	c7 44 24 08 40 29 80 	movl   $0x802940,0x8(%esp)
  800578:	00 
  800579:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  800580:	00 
  800581:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  800588:	e8 4f 02 00 00       	call   8007dc <_panic>
	cprintf("open is good\n");
  80058d:	c7 04 24 7c 26 80 00 	movl   $0x80267c,(%esp)
  800594:	e8 3b 03 00 00       	call   8008d4 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  800599:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005a0:	00 
  8005a1:	c7 04 24 84 27 80 00 	movl   $0x802784,(%esp)
  8005a8:	e8 28 18 00 00       	call   801dd5 <open>
  8005ad:	89 c7                	mov    %eax,%edi
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	79 20                	jns    8005d3 <umain+0x532>
		panic("creat /big: %e", f);
  8005b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b7:	c7 44 24 08 89 27 80 	movl   $0x802789,0x8(%esp)
  8005be:	00 
  8005bf:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8005c6:	00 
  8005c7:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  8005ce:	e8 09 02 00 00       	call   8007dc <_panic>
	memset(buf, 0, sizeof(buf));
  8005d3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005da:	00 
  8005db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8005e2:	00 
  8005e3:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8005e9:	89 04 24             	mov    %eax,(%esp)
  8005ec:	e8 dd 09 00 00       	call   800fce <memset>
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005f1:	be 00 00 00 00       	mov    $0x0,%esi
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8005f6:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  8005fc:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800602:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800609:	00 
  80060a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060e:	89 3c 24             	mov    %edi,(%esp)
  800611:	e8 f3 13 00 00       	call   801a09 <write>
  800616:	85 c0                	test   %eax,%eax
  800618:	79 24                	jns    80063e <umain+0x59d>
			panic("write /big@%d: %e", i, r);
  80061a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80061e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800622:	c7 44 24 08 98 27 80 	movl   $0x802798,0x8(%esp)
  800629:	00 
  80062a:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800631:	00 
  800632:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  800639:	e8 9e 01 00 00       	call   8007dc <_panic>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
	return ipc_recv(NULL, FVA, NULL);
}

void
umain(int argc, char **argv)
  80063e:	8d 86 00 02 00 00    	lea    0x200(%esi),%eax
  800644:	89 c6                	mov    %eax,%esi

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800646:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  80064b:	75 af                	jne    8005fc <umain+0x55b>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  80064d:	89 3c 24             	mov    %edi,(%esp)
  800650:	e8 75 11 00 00       	call   8017ca <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800655:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80065c:	00 
  80065d:	c7 04 24 84 27 80 00 	movl   $0x802784,(%esp)
  800664:	e8 6c 17 00 00       	call   801dd5 <open>
  800669:	89 c3                	mov    %eax,%ebx
  80066b:	85 c0                	test   %eax,%eax
  80066d:	79 20                	jns    80068f <umain+0x5ee>
		panic("open /big: %e", f);
  80066f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800673:	c7 44 24 08 aa 27 80 	movl   $0x8027aa,0x8(%esp)
  80067a:	00 
  80067b:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800682:	00 
  800683:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  80068a:	e8 4d 01 00 00       	call   8007dc <_panic>
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
  80068f:	be 00 00 00 00       	mov    $0x0,%esi
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800694:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  80069a:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006a0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8006a7:	00 
  8006a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ac:	89 1c 24             	mov    %ebx,(%esp)
  8006af:	e8 0a 13 00 00       	call   8019be <readn>
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	79 24                	jns    8006dc <umain+0x63b>
			panic("read /big@%d: %e", i, r);
  8006b8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006bc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006c0:	c7 44 24 08 b8 27 80 	movl   $0x8027b8,0x8(%esp)
  8006c7:	00 
  8006c8:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  8006cf:	00 
  8006d0:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  8006d7:	e8 00 01 00 00       	call   8007dc <_panic>
		if (r != sizeof(buf))
  8006dc:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006e1:	74 2c                	je     80070f <umain+0x66e>
			panic("read /big from %d returned %d < %d bytes",
  8006e3:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  8006ea:	00 
  8006eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006f3:	c7 44 24 08 68 29 80 	movl   $0x802968,0x8(%esp)
  8006fa:	00 
  8006fb:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  800702:	00 
  800703:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  80070a:	e8 cd 00 00 00       	call   8007dc <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  80070f:	8b 07                	mov    (%edi),%eax
  800711:	39 f0                	cmp    %esi,%eax
  800713:	74 24                	je     800739 <umain+0x698>
			panic("read /big from %d returned bad data %d",
  800715:	89 44 24 10          	mov    %eax,0x10(%esp)
  800719:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80071d:	c7 44 24 08 94 29 80 	movl   $0x802994,0x8(%esp)
  800724:	00 
  800725:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  80072c:	00 
  80072d:	c7 04 24 45 26 80 00 	movl   $0x802645,(%esp)
  800734:	e8 a3 00 00 00       	call   8007dc <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800739:	8d b0 00 02 00 00    	lea    0x200(%eax),%esi
  80073f:	81 fe ff df 01 00    	cmp    $0x1dfff,%esi
  800745:	0f 8e 4f ff ff ff    	jle    80069a <umain+0x5f9>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  80074b:	89 1c 24             	mov    %ebx,(%esp)
  80074e:	e8 77 10 00 00       	call   8017ca <close>
	cprintf("large file is good\n");
  800753:	c7 04 24 c9 27 80 00 	movl   $0x8027c9,(%esp)
  80075a:	e8 75 01 00 00       	call   8008d4 <cprintf>
}
  80075f:	81 c4 cc 02 00 00    	add    $0x2cc,%esp
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5f                   	pop    %edi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    
	...

0080076c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	56                   	push   %esi
  800770:	53                   	push   %ebx
  800771:	83 ec 10             	sub    $0x10,%esp
  800774:	8b 75 08             	mov    0x8(%ebp),%esi
  800777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80077a:	e8 d4 0a 00 00       	call   801253 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80077f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800784:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80078b:	c1 e0 07             	shl    $0x7,%eax
  80078e:	29 d0                	sub    %edx,%eax
  800790:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800795:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80079a:	85 f6                	test   %esi,%esi
  80079c:	7e 07                	jle    8007a5 <libmain+0x39>
		binaryname = argv[0];
  80079e:	8b 03                	mov    (%ebx),%eax
  8007a0:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8007a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a9:	89 34 24             	mov    %esi,(%esp)
  8007ac:	e8 f0 f8 ff ff       	call   8000a1 <umain>

	// exit gracefully
	exit();
  8007b1:	e8 0a 00 00 00       	call   8007c0 <exit>
}
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	5b                   	pop    %ebx
  8007ba:	5e                   	pop    %esi
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    
  8007bd:	00 00                	add    %al,(%eax)
	...

008007c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8007c6:	e8 30 10 00 00       	call   8017fb <close_all>
	sys_env_destroy(0);
  8007cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007d2:	e8 2a 0a 00 00       	call   801201 <sys_env_destroy>
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    
  8007d9:	00 00                	add    %al,(%eax)
	...

008007dc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007e7:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8007ed:	e8 61 0a 00 00       	call   801253 <sys_getenvid>
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8007fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800800:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800804:	89 44 24 04          	mov    %eax,0x4(%esp)
  800808:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  80080f:	e8 c0 00 00 00       	call   8008d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800814:	89 74 24 04          	mov    %esi,0x4(%esp)
  800818:	8b 45 10             	mov    0x10(%ebp),%eax
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	e8 50 00 00 00       	call   800873 <vcprintf>
	cprintf("\n");
  800823:	c7 04 24 5d 2e 80 00 	movl   $0x802e5d,(%esp)
  80082a:	e8 a5 00 00 00       	call   8008d4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80082f:	cc                   	int3   
  800830:	eb fd                	jmp    80082f <_panic+0x53>
	...

00800834 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	83 ec 14             	sub    $0x14,%esp
  80083b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80083e:	8b 03                	mov    (%ebx),%eax
  800840:	8b 55 08             	mov    0x8(%ebp),%edx
  800843:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800847:	40                   	inc    %eax
  800848:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80084a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80084f:	75 19                	jne    80086a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800851:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800858:	00 
  800859:	8d 43 08             	lea    0x8(%ebx),%eax
  80085c:	89 04 24             	mov    %eax,(%esp)
  80085f:	e8 60 09 00 00       	call   8011c4 <sys_cputs>
		b->idx = 0;
  800864:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80086a:	ff 43 04             	incl   0x4(%ebx)
}
  80086d:	83 c4 14             	add    $0x14,%esp
  800870:	5b                   	pop    %ebx
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80087c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800883:	00 00 00 
	b.cnt = 0;
  800886:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80088d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800890:	8b 45 0c             	mov    0xc(%ebp),%eax
  800893:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a8:	c7 04 24 34 08 80 00 	movl   $0x800834,(%esp)
  8008af:	e8 82 01 00 00       	call   800a36 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008b4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8008ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008be:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008c4:	89 04 24             	mov    %eax,(%esp)
  8008c7:	e8 f8 08 00 00       	call   8011c4 <sys_cputs>

	return b.cnt;
}
  8008cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    

008008d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8008da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8008dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	89 04 24             	mov    %eax,(%esp)
  8008e7:	e8 87 ff ff ff       	call   800873 <vcprintf>
	va_end(ap);

	return cnt;
}
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    
	...

008008f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	57                   	push   %edi
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	83 ec 3c             	sub    $0x3c,%esp
  8008f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008fc:	89 d7                	mov    %edx,%edi
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800904:	8b 45 0c             	mov    0xc(%ebp),%eax
  800907:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80090a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80090d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800910:	85 c0                	test   %eax,%eax
  800912:	75 08                	jne    80091c <printnum+0x2c>
  800914:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800917:	39 45 10             	cmp    %eax,0x10(%ebp)
  80091a:	77 57                	ja     800973 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80091c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800920:	4b                   	dec    %ebx
  800921:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800925:	8b 45 10             	mov    0x10(%ebp),%eax
  800928:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800930:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800934:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80093b:	00 
  80093c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80093f:	89 04 24             	mov    %eax,(%esp)
  800942:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800945:	89 44 24 04          	mov    %eax,0x4(%esp)
  800949:	e8 82 1a 00 00       	call   8023d0 <__udivdi3>
  80094e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800952:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800956:	89 04 24             	mov    %eax,(%esp)
  800959:	89 54 24 04          	mov    %edx,0x4(%esp)
  80095d:	89 fa                	mov    %edi,%edx
  80095f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800962:	e8 89 ff ff ff       	call   8008f0 <printnum>
  800967:	eb 0f                	jmp    800978 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800969:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80096d:	89 34 24             	mov    %esi,(%esp)
  800970:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800973:	4b                   	dec    %ebx
  800974:	85 db                	test   %ebx,%ebx
  800976:	7f f1                	jg     800969 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800978:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800980:	8b 45 10             	mov    0x10(%ebp),%eax
  800983:	89 44 24 08          	mov    %eax,0x8(%esp)
  800987:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80098e:	00 
  80098f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800992:	89 04 24             	mov    %eax,(%esp)
  800995:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800998:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099c:	e8 4f 1b 00 00       	call   8024f0 <__umoddi3>
  8009a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009a5:	0f be 80 0f 2a 80 00 	movsbl 0x802a0f(%eax),%eax
  8009ac:	89 04 24             	mov    %eax,(%esp)
  8009af:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8009b2:	83 c4 3c             	add    $0x3c,%esp
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5f                   	pop    %edi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8009bd:	83 fa 01             	cmp    $0x1,%edx
  8009c0:	7e 0e                	jle    8009d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8009c2:	8b 10                	mov    (%eax),%edx
  8009c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8009c7:	89 08                	mov    %ecx,(%eax)
  8009c9:	8b 02                	mov    (%edx),%eax
  8009cb:	8b 52 04             	mov    0x4(%edx),%edx
  8009ce:	eb 22                	jmp    8009f2 <getuint+0x38>
	else if (lflag)
  8009d0:	85 d2                	test   %edx,%edx
  8009d2:	74 10                	je     8009e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8009d4:	8b 10                	mov    (%eax),%edx
  8009d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009d9:	89 08                	mov    %ecx,(%eax)
  8009db:	8b 02                	mov    (%edx),%eax
  8009dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e2:	eb 0e                	jmp    8009f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8009e4:	8b 10                	mov    (%eax),%edx
  8009e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009e9:	89 08                	mov    %ecx,(%eax)
  8009eb:	8b 02                	mov    (%edx),%eax
  8009ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8009fa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8009fd:	8b 10                	mov    (%eax),%edx
  8009ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800a02:	73 08                	jae    800a0c <sprintputch+0x18>
		*b->buf++ = ch;
  800a04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a07:	88 0a                	mov    %cl,(%edx)
  800a09:	42                   	inc    %edx
  800a0a:	89 10                	mov    %edx,(%eax)
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800a14:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	89 04 24             	mov    %eax,(%esp)
  800a2f:	e8 02 00 00 00       	call   800a36 <vprintfmt>
	va_end(ap);
}
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    

00800a36 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	57                   	push   %edi
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	83 ec 4c             	sub    $0x4c,%esp
  800a3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a42:	8b 75 10             	mov    0x10(%ebp),%esi
  800a45:	eb 12                	jmp    800a59 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a47:	85 c0                	test   %eax,%eax
  800a49:	0f 84 8b 03 00 00    	je     800dda <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800a4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a53:	89 04 24             	mov    %eax,(%esp)
  800a56:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a59:	0f b6 06             	movzbl (%esi),%eax
  800a5c:	46                   	inc    %esi
  800a5d:	83 f8 25             	cmp    $0x25,%eax
  800a60:	75 e5                	jne    800a47 <vprintfmt+0x11>
  800a62:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800a66:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800a6d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800a72:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800a79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7e:	eb 26                	jmp    800aa6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a80:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a83:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800a87:	eb 1d                	jmp    800aa6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a89:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a8c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800a90:	eb 14                	jmp    800aa6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a92:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800a95:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800a9c:	eb 08                	jmp    800aa6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a9e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800aa1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aa6:	0f b6 06             	movzbl (%esi),%eax
  800aa9:	8d 56 01             	lea    0x1(%esi),%edx
  800aac:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800aaf:	8a 16                	mov    (%esi),%dl
  800ab1:	83 ea 23             	sub    $0x23,%edx
  800ab4:	80 fa 55             	cmp    $0x55,%dl
  800ab7:	0f 87 01 03 00 00    	ja     800dbe <vprintfmt+0x388>
  800abd:	0f b6 d2             	movzbl %dl,%edx
  800ac0:	ff 24 95 60 2b 80 00 	jmp    *0x802b60(,%edx,4)
  800ac7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800aca:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800acf:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800ad2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800ad6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800ad9:	8d 50 d0             	lea    -0x30(%eax),%edx
  800adc:	83 fa 09             	cmp    $0x9,%edx
  800adf:	77 2a                	ja     800b0b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ae1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ae2:	eb eb                	jmp    800acf <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800ae4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae7:	8d 50 04             	lea    0x4(%eax),%edx
  800aea:	89 55 14             	mov    %edx,0x14(%ebp)
  800aed:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800af2:	eb 17                	jmp    800b0b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800af4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800af8:	78 98                	js     800a92 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800afa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800afd:	eb a7                	jmp    800aa6 <vprintfmt+0x70>
  800aff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800b02:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800b09:	eb 9b                	jmp    800aa6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800b0b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b0f:	79 95                	jns    800aa6 <vprintfmt+0x70>
  800b11:	eb 8b                	jmp    800a9e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b13:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b14:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b17:	eb 8d                	jmp    800aa6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b19:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1c:	8d 50 04             	lea    0x4(%eax),%edx
  800b1f:	89 55 14             	mov    %edx,0x14(%ebp)
  800b22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b26:	8b 00                	mov    (%eax),%eax
  800b28:	89 04 24             	mov    %eax,(%esp)
  800b2b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b2e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800b31:	e9 23 ff ff ff       	jmp    800a59 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b36:	8b 45 14             	mov    0x14(%ebp),%eax
  800b39:	8d 50 04             	lea    0x4(%eax),%edx
  800b3c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b3f:	8b 00                	mov    (%eax),%eax
  800b41:	85 c0                	test   %eax,%eax
  800b43:	79 02                	jns    800b47 <vprintfmt+0x111>
  800b45:	f7 d8                	neg    %eax
  800b47:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b49:	83 f8 0f             	cmp    $0xf,%eax
  800b4c:	7f 0b                	jg     800b59 <vprintfmt+0x123>
  800b4e:	8b 04 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%eax
  800b55:	85 c0                	test   %eax,%eax
  800b57:	75 23                	jne    800b7c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800b59:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b5d:	c7 44 24 08 27 2a 80 	movl   $0x802a27,0x8(%esp)
  800b64:	00 
  800b65:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	89 04 24             	mov    %eax,(%esp)
  800b6f:	e8 9a fe ff ff       	call   800a0e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b74:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800b77:	e9 dd fe ff ff       	jmp    800a59 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800b7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b80:	c7 44 24 08 36 2e 80 	movl   $0x802e36,0x8(%esp)
  800b87:	00 
  800b88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	89 14 24             	mov    %edx,(%esp)
  800b92:	e8 77 fe ff ff       	call   800a0e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b97:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b9a:	e9 ba fe ff ff       	jmp    800a59 <vprintfmt+0x23>
  800b9f:	89 f9                	mov    %edi,%ecx
  800ba1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ba4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800ba7:	8b 45 14             	mov    0x14(%ebp),%eax
  800baa:	8d 50 04             	lea    0x4(%eax),%edx
  800bad:	89 55 14             	mov    %edx,0x14(%ebp)
  800bb0:	8b 30                	mov    (%eax),%esi
  800bb2:	85 f6                	test   %esi,%esi
  800bb4:	75 05                	jne    800bbb <vprintfmt+0x185>
				p = "(null)";
  800bb6:	be 20 2a 80 00       	mov    $0x802a20,%esi
			if (width > 0 && padc != '-')
  800bbb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800bbf:	0f 8e 84 00 00 00    	jle    800c49 <vprintfmt+0x213>
  800bc5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800bc9:	74 7e                	je     800c49 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800bcb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800bcf:	89 34 24             	mov    %esi,(%esp)
  800bd2:	e8 ab 02 00 00       	call   800e82 <strnlen>
  800bd7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800bda:	29 c2                	sub    %eax,%edx
  800bdc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800bdf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800be3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800be6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800be9:	89 de                	mov    %ebx,%esi
  800beb:	89 d3                	mov    %edx,%ebx
  800bed:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bef:	eb 0b                	jmp    800bfc <vprintfmt+0x1c6>
					putch(padc, putdat);
  800bf1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf5:	89 3c 24             	mov    %edi,(%esp)
  800bf8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bfb:	4b                   	dec    %ebx
  800bfc:	85 db                	test   %ebx,%ebx
  800bfe:	7f f1                	jg     800bf1 <vprintfmt+0x1bb>
  800c00:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800c03:	89 f3                	mov    %esi,%ebx
  800c05:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800c08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	79 05                	jns    800c14 <vprintfmt+0x1de>
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c17:	29 c2                	sub    %eax,%edx
  800c19:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c1c:	eb 2b                	jmp    800c49 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c1e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c22:	74 18                	je     800c3c <vprintfmt+0x206>
  800c24:	8d 50 e0             	lea    -0x20(%eax),%edx
  800c27:	83 fa 5e             	cmp    $0x5e,%edx
  800c2a:	76 10                	jbe    800c3c <vprintfmt+0x206>
					putch('?', putdat);
  800c2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c30:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c37:	ff 55 08             	call   *0x8(%ebp)
  800c3a:	eb 0a                	jmp    800c46 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800c3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c40:	89 04 24             	mov    %eax,(%esp)
  800c43:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c46:	ff 4d e4             	decl   -0x1c(%ebp)
  800c49:	0f be 06             	movsbl (%esi),%eax
  800c4c:	46                   	inc    %esi
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	74 21                	je     800c72 <vprintfmt+0x23c>
  800c51:	85 ff                	test   %edi,%edi
  800c53:	78 c9                	js     800c1e <vprintfmt+0x1e8>
  800c55:	4f                   	dec    %edi
  800c56:	79 c6                	jns    800c1e <vprintfmt+0x1e8>
  800c58:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c60:	eb 18                	jmp    800c7a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c62:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c66:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c6d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c6f:	4b                   	dec    %ebx
  800c70:	eb 08                	jmp    800c7a <vprintfmt+0x244>
  800c72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c75:	89 de                	mov    %ebx,%esi
  800c77:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c7a:	85 db                	test   %ebx,%ebx
  800c7c:	7f e4                	jg     800c62 <vprintfmt+0x22c>
  800c7e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800c81:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c83:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c86:	e9 ce fd ff ff       	jmp    800a59 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c8b:	83 f9 01             	cmp    $0x1,%ecx
  800c8e:	7e 10                	jle    800ca0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800c90:	8b 45 14             	mov    0x14(%ebp),%eax
  800c93:	8d 50 08             	lea    0x8(%eax),%edx
  800c96:	89 55 14             	mov    %edx,0x14(%ebp)
  800c99:	8b 30                	mov    (%eax),%esi
  800c9b:	8b 78 04             	mov    0x4(%eax),%edi
  800c9e:	eb 26                	jmp    800cc6 <vprintfmt+0x290>
	else if (lflag)
  800ca0:	85 c9                	test   %ecx,%ecx
  800ca2:	74 12                	je     800cb6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800ca4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca7:	8d 50 04             	lea    0x4(%eax),%edx
  800caa:	89 55 14             	mov    %edx,0x14(%ebp)
  800cad:	8b 30                	mov    (%eax),%esi
  800caf:	89 f7                	mov    %esi,%edi
  800cb1:	c1 ff 1f             	sar    $0x1f,%edi
  800cb4:	eb 10                	jmp    800cc6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800cb6:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb9:	8d 50 04             	lea    0x4(%eax),%edx
  800cbc:	89 55 14             	mov    %edx,0x14(%ebp)
  800cbf:	8b 30                	mov    (%eax),%esi
  800cc1:	89 f7                	mov    %esi,%edi
  800cc3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800cc6:	85 ff                	test   %edi,%edi
  800cc8:	78 0a                	js     800cd4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800cca:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ccf:	e9 ac 00 00 00       	jmp    800d80 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800cd4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800cdf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ce2:	f7 de                	neg    %esi
  800ce4:	83 d7 00             	adc    $0x0,%edi
  800ce7:	f7 df                	neg    %edi
			}
			base = 10;
  800ce9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cee:	e9 8d 00 00 00       	jmp    800d80 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800cf3:	89 ca                	mov    %ecx,%edx
  800cf5:	8d 45 14             	lea    0x14(%ebp),%eax
  800cf8:	e8 bd fc ff ff       	call   8009ba <getuint>
  800cfd:	89 c6                	mov    %eax,%esi
  800cff:	89 d7                	mov    %edx,%edi
			base = 10;
  800d01:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800d06:	eb 78                	jmp    800d80 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800d08:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d0c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800d13:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800d16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d1a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800d21:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800d24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d28:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800d2f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d32:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800d35:	e9 1f fd ff ff       	jmp    800a59 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800d3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d3e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800d45:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800d48:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d4c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d53:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d56:	8b 45 14             	mov    0x14(%ebp),%eax
  800d59:	8d 50 04             	lea    0x4(%eax),%edx
  800d5c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800d5f:	8b 30                	mov    (%eax),%esi
  800d61:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d66:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800d6b:	eb 13                	jmp    800d80 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d6d:	89 ca                	mov    %ecx,%edx
  800d6f:	8d 45 14             	lea    0x14(%ebp),%eax
  800d72:	e8 43 fc ff ff       	call   8009ba <getuint>
  800d77:	89 c6                	mov    %eax,%esi
  800d79:	89 d7                	mov    %edx,%edi
			base = 16;
  800d7b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d80:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800d84:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d88:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d93:	89 34 24             	mov    %esi,(%esp)
  800d96:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d9a:	89 da                	mov    %ebx,%edx
  800d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9f:	e8 4c fb ff ff       	call   8008f0 <printnum>
			break;
  800da4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800da7:	e9 ad fc ff ff       	jmp    800a59 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800dac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800db0:	89 04 24             	mov    %eax,(%esp)
  800db3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800db6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800db9:	e9 9b fc ff ff       	jmp    800a59 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800dbe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dc2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800dc9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800dcc:	eb 01                	jmp    800dcf <vprintfmt+0x399>
  800dce:	4e                   	dec    %esi
  800dcf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800dd3:	75 f9                	jne    800dce <vprintfmt+0x398>
  800dd5:	e9 7f fc ff ff       	jmp    800a59 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800dda:	83 c4 4c             	add    $0x4c,%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	83 ec 28             	sub    $0x28,%esp
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800df1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800df5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800df8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	74 30                	je     800e33 <vsnprintf+0x51>
  800e03:	85 d2                	test   %edx,%edx
  800e05:	7e 33                	jle    800e3a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e07:	8b 45 14             	mov    0x14(%ebp),%eax
  800e0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e0e:	8b 45 10             	mov    0x10(%ebp),%eax
  800e11:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e15:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e18:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e1c:	c7 04 24 f4 09 80 00 	movl   $0x8009f4,(%esp)
  800e23:	e8 0e fc ff ff       	call   800a36 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e2b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e31:	eb 0c                	jmp    800e3f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e38:	eb 05                	jmp    800e3f <vsnprintf+0x5d>
  800e3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e3f:	c9                   	leave  
  800e40:	c3                   	ret    

00800e41 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e47:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800e51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e58:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5f:	89 04 24             	mov    %eax,(%esp)
  800e62:	e8 7b ff ff ff       	call   800de2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800e67:	c9                   	leave  
  800e68:	c3                   	ret    
  800e69:	00 00                	add    %al,(%eax)
	...

00800e6c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e72:	b8 00 00 00 00       	mov    $0x0,%eax
  800e77:	eb 01                	jmp    800e7a <strlen+0xe>
		n++;
  800e79:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e7a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e7e:	75 f9                	jne    800e79 <strlen+0xd>
		n++;
	return n;
}
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800e88:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e90:	eb 01                	jmp    800e93 <strnlen+0x11>
		n++;
  800e92:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e93:	39 d0                	cmp    %edx,%eax
  800e95:	74 06                	je     800e9d <strnlen+0x1b>
  800e97:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800e9b:	75 f5                	jne    800e92 <strnlen+0x10>
		n++;
	return n;
}
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	53                   	push   %ebx
  800ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ea9:	ba 00 00 00 00       	mov    $0x0,%edx
  800eae:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800eb1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800eb4:	42                   	inc    %edx
  800eb5:	84 c9                	test   %cl,%cl
  800eb7:	75 f5                	jne    800eae <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800eb9:	5b                   	pop    %ebx
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 08             	sub    $0x8,%esp
  800ec3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ec6:	89 1c 24             	mov    %ebx,(%esp)
  800ec9:	e8 9e ff ff ff       	call   800e6c <strlen>
	strcpy(dst + len, src);
  800ece:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ed5:	01 d8                	add    %ebx,%eax
  800ed7:	89 04 24             	mov    %eax,(%esp)
  800eda:	e8 c0 ff ff ff       	call   800e9f <strcpy>
	return dst;
}
  800edf:	89 d8                	mov    %ebx,%eax
  800ee1:	83 c4 08             	add    $0x8,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
  800eec:	8b 45 08             	mov    0x8(%ebp),%eax
  800eef:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ef2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ef5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800efa:	eb 0c                	jmp    800f08 <strncpy+0x21>
		*dst++ = *src;
  800efc:	8a 1a                	mov    (%edx),%bl
  800efe:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f01:	80 3a 01             	cmpb   $0x1,(%edx)
  800f04:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f07:	41                   	inc    %ecx
  800f08:	39 f1                	cmp    %esi,%ecx
  800f0a:	75 f0                	jne    800efc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800f0c:	5b                   	pop    %ebx
  800f0d:	5e                   	pop    %esi
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	56                   	push   %esi
  800f14:	53                   	push   %ebx
  800f15:	8b 75 08             	mov    0x8(%ebp),%esi
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f1e:	85 d2                	test   %edx,%edx
  800f20:	75 0a                	jne    800f2c <strlcpy+0x1c>
  800f22:	89 f0                	mov    %esi,%eax
  800f24:	eb 1a                	jmp    800f40 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f26:	88 18                	mov    %bl,(%eax)
  800f28:	40                   	inc    %eax
  800f29:	41                   	inc    %ecx
  800f2a:	eb 02                	jmp    800f2e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f2c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800f2e:	4a                   	dec    %edx
  800f2f:	74 0a                	je     800f3b <strlcpy+0x2b>
  800f31:	8a 19                	mov    (%ecx),%bl
  800f33:	84 db                	test   %bl,%bl
  800f35:	75 ef                	jne    800f26 <strlcpy+0x16>
  800f37:	89 c2                	mov    %eax,%edx
  800f39:	eb 02                	jmp    800f3d <strlcpy+0x2d>
  800f3b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800f3d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800f40:	29 f0                	sub    %esi,%eax
}
  800f42:	5b                   	pop    %ebx
  800f43:	5e                   	pop    %esi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f4f:	eb 02                	jmp    800f53 <strcmp+0xd>
		p++, q++;
  800f51:	41                   	inc    %ecx
  800f52:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f53:	8a 01                	mov    (%ecx),%al
  800f55:	84 c0                	test   %al,%al
  800f57:	74 04                	je     800f5d <strcmp+0x17>
  800f59:	3a 02                	cmp    (%edx),%al
  800f5b:	74 f4                	je     800f51 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f5d:	0f b6 c0             	movzbl %al,%eax
  800f60:	0f b6 12             	movzbl (%edx),%edx
  800f63:	29 d0                	sub    %edx,%eax
}
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	53                   	push   %ebx
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f71:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800f74:	eb 03                	jmp    800f79 <strncmp+0x12>
		n--, p++, q++;
  800f76:	4a                   	dec    %edx
  800f77:	40                   	inc    %eax
  800f78:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f79:	85 d2                	test   %edx,%edx
  800f7b:	74 14                	je     800f91 <strncmp+0x2a>
  800f7d:	8a 18                	mov    (%eax),%bl
  800f7f:	84 db                	test   %bl,%bl
  800f81:	74 04                	je     800f87 <strncmp+0x20>
  800f83:	3a 19                	cmp    (%ecx),%bl
  800f85:	74 ef                	je     800f76 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f87:	0f b6 00             	movzbl (%eax),%eax
  800f8a:	0f b6 11             	movzbl (%ecx),%edx
  800f8d:	29 d0                	sub    %edx,%eax
  800f8f:	eb 05                	jmp    800f96 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f91:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f96:	5b                   	pop    %ebx
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800fa2:	eb 05                	jmp    800fa9 <strchr+0x10>
		if (*s == c)
  800fa4:	38 ca                	cmp    %cl,%dl
  800fa6:	74 0c                	je     800fb4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800fa8:	40                   	inc    %eax
  800fa9:	8a 10                	mov    (%eax),%dl
  800fab:	84 d2                	test   %dl,%dl
  800fad:	75 f5                	jne    800fa4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800faf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800fbf:	eb 05                	jmp    800fc6 <strfind+0x10>
		if (*s == c)
  800fc1:	38 ca                	cmp    %cl,%dl
  800fc3:	74 07                	je     800fcc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800fc5:	40                   	inc    %eax
  800fc6:	8a 10                	mov    (%eax),%dl
  800fc8:	84 d2                	test   %dl,%dl
  800fca:	75 f5                	jne    800fc1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fda:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800fdd:	85 c9                	test   %ecx,%ecx
  800fdf:	74 30                	je     801011 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fe1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fe7:	75 25                	jne    80100e <memset+0x40>
  800fe9:	f6 c1 03             	test   $0x3,%cl
  800fec:	75 20                	jne    80100e <memset+0x40>
		c &= 0xFF;
  800fee:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ff1:	89 d3                	mov    %edx,%ebx
  800ff3:	c1 e3 08             	shl    $0x8,%ebx
  800ff6:	89 d6                	mov    %edx,%esi
  800ff8:	c1 e6 18             	shl    $0x18,%esi
  800ffb:	89 d0                	mov    %edx,%eax
  800ffd:	c1 e0 10             	shl    $0x10,%eax
  801000:	09 f0                	or     %esi,%eax
  801002:	09 d0                	or     %edx,%eax
  801004:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801006:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801009:	fc                   	cld    
  80100a:	f3 ab                	rep stos %eax,%es:(%edi)
  80100c:	eb 03                	jmp    801011 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80100e:	fc                   	cld    
  80100f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801011:	89 f8                	mov    %edi,%eax
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	57                   	push   %edi
  80101c:	56                   	push   %esi
  80101d:	8b 45 08             	mov    0x8(%ebp),%eax
  801020:	8b 75 0c             	mov    0xc(%ebp),%esi
  801023:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801026:	39 c6                	cmp    %eax,%esi
  801028:	73 34                	jae    80105e <memmove+0x46>
  80102a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80102d:	39 d0                	cmp    %edx,%eax
  80102f:	73 2d                	jae    80105e <memmove+0x46>
		s += n;
		d += n;
  801031:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801034:	f6 c2 03             	test   $0x3,%dl
  801037:	75 1b                	jne    801054 <memmove+0x3c>
  801039:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80103f:	75 13                	jne    801054 <memmove+0x3c>
  801041:	f6 c1 03             	test   $0x3,%cl
  801044:	75 0e                	jne    801054 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801046:	83 ef 04             	sub    $0x4,%edi
  801049:	8d 72 fc             	lea    -0x4(%edx),%esi
  80104c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80104f:	fd                   	std    
  801050:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801052:	eb 07                	jmp    80105b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801054:	4f                   	dec    %edi
  801055:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801058:	fd                   	std    
  801059:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80105b:	fc                   	cld    
  80105c:	eb 20                	jmp    80107e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80105e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801064:	75 13                	jne    801079 <memmove+0x61>
  801066:	a8 03                	test   $0x3,%al
  801068:	75 0f                	jne    801079 <memmove+0x61>
  80106a:	f6 c1 03             	test   $0x3,%cl
  80106d:	75 0a                	jne    801079 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80106f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801072:	89 c7                	mov    %eax,%edi
  801074:	fc                   	cld    
  801075:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801077:	eb 05                	jmp    80107e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801079:	89 c7                	mov    %eax,%edi
  80107b:	fc                   	cld    
  80107c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80107e:	5e                   	pop    %esi
  80107f:	5f                   	pop    %edi
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801088:	8b 45 10             	mov    0x10(%ebp),%eax
  80108b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80108f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801092:	89 44 24 04          	mov    %eax,0x4(%esp)
  801096:	8b 45 08             	mov    0x8(%ebp),%eax
  801099:	89 04 24             	mov    %eax,(%esp)
  80109c:	e8 77 ff ff ff       	call   801018 <memmove>
}
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    

008010a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b7:	eb 16                	jmp    8010cf <memcmp+0x2c>
		if (*s1 != *s2)
  8010b9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8010bc:	42                   	inc    %edx
  8010bd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8010c1:	38 c8                	cmp    %cl,%al
  8010c3:	74 0a                	je     8010cf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8010c5:	0f b6 c0             	movzbl %al,%eax
  8010c8:	0f b6 c9             	movzbl %cl,%ecx
  8010cb:	29 c8                	sub    %ecx,%eax
  8010cd:	eb 09                	jmp    8010d8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010cf:	39 da                	cmp    %ebx,%edx
  8010d1:	75 e6                	jne    8010b9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8010e6:	89 c2                	mov    %eax,%edx
  8010e8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010eb:	eb 05                	jmp    8010f2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010ed:	38 08                	cmp    %cl,(%eax)
  8010ef:	74 05                	je     8010f6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010f1:	40                   	inc    %eax
  8010f2:	39 d0                	cmp    %edx,%eax
  8010f4:	72 f7                	jb     8010ed <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
  8010fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801101:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801104:	eb 01                	jmp    801107 <strtol+0xf>
		s++;
  801106:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801107:	8a 02                	mov    (%edx),%al
  801109:	3c 20                	cmp    $0x20,%al
  80110b:	74 f9                	je     801106 <strtol+0xe>
  80110d:	3c 09                	cmp    $0x9,%al
  80110f:	74 f5                	je     801106 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801111:	3c 2b                	cmp    $0x2b,%al
  801113:	75 08                	jne    80111d <strtol+0x25>
		s++;
  801115:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801116:	bf 00 00 00 00       	mov    $0x0,%edi
  80111b:	eb 13                	jmp    801130 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80111d:	3c 2d                	cmp    $0x2d,%al
  80111f:	75 0a                	jne    80112b <strtol+0x33>
		s++, neg = 1;
  801121:	8d 52 01             	lea    0x1(%edx),%edx
  801124:	bf 01 00 00 00       	mov    $0x1,%edi
  801129:	eb 05                	jmp    801130 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80112b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801130:	85 db                	test   %ebx,%ebx
  801132:	74 05                	je     801139 <strtol+0x41>
  801134:	83 fb 10             	cmp    $0x10,%ebx
  801137:	75 28                	jne    801161 <strtol+0x69>
  801139:	8a 02                	mov    (%edx),%al
  80113b:	3c 30                	cmp    $0x30,%al
  80113d:	75 10                	jne    80114f <strtol+0x57>
  80113f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801143:	75 0a                	jne    80114f <strtol+0x57>
		s += 2, base = 16;
  801145:	83 c2 02             	add    $0x2,%edx
  801148:	bb 10 00 00 00       	mov    $0x10,%ebx
  80114d:	eb 12                	jmp    801161 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80114f:	85 db                	test   %ebx,%ebx
  801151:	75 0e                	jne    801161 <strtol+0x69>
  801153:	3c 30                	cmp    $0x30,%al
  801155:	75 05                	jne    80115c <strtol+0x64>
		s++, base = 8;
  801157:	42                   	inc    %edx
  801158:	b3 08                	mov    $0x8,%bl
  80115a:	eb 05                	jmp    801161 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80115c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801161:	b8 00 00 00 00       	mov    $0x0,%eax
  801166:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801168:	8a 0a                	mov    (%edx),%cl
  80116a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80116d:	80 fb 09             	cmp    $0x9,%bl
  801170:	77 08                	ja     80117a <strtol+0x82>
			dig = *s - '0';
  801172:	0f be c9             	movsbl %cl,%ecx
  801175:	83 e9 30             	sub    $0x30,%ecx
  801178:	eb 1e                	jmp    801198 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80117a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80117d:	80 fb 19             	cmp    $0x19,%bl
  801180:	77 08                	ja     80118a <strtol+0x92>
			dig = *s - 'a' + 10;
  801182:	0f be c9             	movsbl %cl,%ecx
  801185:	83 e9 57             	sub    $0x57,%ecx
  801188:	eb 0e                	jmp    801198 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80118a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80118d:	80 fb 19             	cmp    $0x19,%bl
  801190:	77 12                	ja     8011a4 <strtol+0xac>
			dig = *s - 'A' + 10;
  801192:	0f be c9             	movsbl %cl,%ecx
  801195:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801198:	39 f1                	cmp    %esi,%ecx
  80119a:	7d 0c                	jge    8011a8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  80119c:	42                   	inc    %edx
  80119d:	0f af c6             	imul   %esi,%eax
  8011a0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8011a2:	eb c4                	jmp    801168 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8011a4:	89 c1                	mov    %eax,%ecx
  8011a6:	eb 02                	jmp    8011aa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8011a8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8011aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011ae:	74 05                	je     8011b5 <strtol+0xbd>
		*endptr = (char *) s;
  8011b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011b3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8011b5:	85 ff                	test   %edi,%edi
  8011b7:	74 04                	je     8011bd <strtol+0xc5>
  8011b9:	89 c8                	mov    %ecx,%eax
  8011bb:	f7 d8                	neg    %eax
}
  8011bd:	5b                   	pop    %ebx
  8011be:	5e                   	pop    %esi
  8011bf:	5f                   	pop    %edi
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    
	...

008011c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	57                   	push   %edi
  8011c8:	56                   	push   %esi
  8011c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d5:	89 c3                	mov    %eax,%ebx
  8011d7:	89 c7                	mov    %eax,%edi
  8011d9:	89 c6                	mov    %eax,%esi
  8011db:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	57                   	push   %edi
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f2:	89 d1                	mov    %edx,%ecx
  8011f4:	89 d3                	mov    %edx,%ebx
  8011f6:	89 d7                	mov    %edx,%edi
  8011f8:	89 d6                	mov    %edx,%esi
  8011fa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011fc:	5b                   	pop    %ebx
  8011fd:	5e                   	pop    %esi
  8011fe:	5f                   	pop    %edi
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	57                   	push   %edi
  801205:	56                   	push   %esi
  801206:	53                   	push   %ebx
  801207:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80120f:	b8 03 00 00 00       	mov    $0x3,%eax
  801214:	8b 55 08             	mov    0x8(%ebp),%edx
  801217:	89 cb                	mov    %ecx,%ebx
  801219:	89 cf                	mov    %ecx,%edi
  80121b:	89 ce                	mov    %ecx,%esi
  80121d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80121f:	85 c0                	test   %eax,%eax
  801221:	7e 28                	jle    80124b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801223:	89 44 24 10          	mov    %eax,0x10(%esp)
  801227:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80122e:	00 
  80122f:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  801236:	00 
  801237:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80123e:	00 
  80123f:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  801246:	e8 91 f5 ff ff       	call   8007dc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80124b:	83 c4 2c             	add    $0x2c,%esp
  80124e:	5b                   	pop    %ebx
  80124f:	5e                   	pop    %esi
  801250:	5f                   	pop    %edi
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	57                   	push   %edi
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801259:	ba 00 00 00 00       	mov    $0x0,%edx
  80125e:	b8 02 00 00 00       	mov    $0x2,%eax
  801263:	89 d1                	mov    %edx,%ecx
  801265:	89 d3                	mov    %edx,%ebx
  801267:	89 d7                	mov    %edx,%edi
  801269:	89 d6                	mov    %edx,%esi
  80126b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80126d:	5b                   	pop    %ebx
  80126e:	5e                   	pop    %esi
  80126f:	5f                   	pop    %edi
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <sys_yield>:

void
sys_yield(void)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	57                   	push   %edi
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801278:	ba 00 00 00 00       	mov    $0x0,%edx
  80127d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801282:	89 d1                	mov    %edx,%ecx
  801284:	89 d3                	mov    %edx,%ebx
  801286:	89 d7                	mov    %edx,%edi
  801288:	89 d6                	mov    %edx,%esi
  80128a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80128c:	5b                   	pop    %ebx
  80128d:	5e                   	pop    %esi
  80128e:	5f                   	pop    %edi
  80128f:	5d                   	pop    %ebp
  801290:	c3                   	ret    

00801291 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	57                   	push   %edi
  801295:	56                   	push   %esi
  801296:	53                   	push   %ebx
  801297:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129a:	be 00 00 00 00       	mov    $0x0,%esi
  80129f:	b8 04 00 00 00       	mov    $0x4,%eax
  8012a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ad:	89 f7                	mov    %esi,%edi
  8012af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	7e 28                	jle    8012dd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8012c0:	00 
  8012c1:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  8012c8:	00 
  8012c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012d0:	00 
  8012d1:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  8012d8:	e8 ff f4 ff ff       	call   8007dc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012dd:	83 c4 2c             	add    $0x2c,%esp
  8012e0:	5b                   	pop    %ebx
  8012e1:	5e                   	pop    %esi
  8012e2:	5f                   	pop    %edi
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	57                   	push   %edi
  8012e9:	56                   	push   %esi
  8012ea:	53                   	push   %ebx
  8012eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8012f3:	8b 75 18             	mov    0x18(%ebp),%esi
  8012f6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801302:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801304:	85 c0                	test   %eax,%eax
  801306:	7e 28                	jle    801330 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801308:	89 44 24 10          	mov    %eax,0x10(%esp)
  80130c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801313:	00 
  801314:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  80131b:	00 
  80131c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801323:	00 
  801324:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  80132b:	e8 ac f4 ff ff       	call   8007dc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801330:	83 c4 2c             	add    $0x2c,%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	5f                   	pop    %edi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	57                   	push   %edi
  80133c:	56                   	push   %esi
  80133d:	53                   	push   %ebx
  80133e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801341:	bb 00 00 00 00       	mov    $0x0,%ebx
  801346:	b8 06 00 00 00       	mov    $0x6,%eax
  80134b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134e:	8b 55 08             	mov    0x8(%ebp),%edx
  801351:	89 df                	mov    %ebx,%edi
  801353:	89 de                	mov    %ebx,%esi
  801355:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801357:	85 c0                	test   %eax,%eax
  801359:	7e 28                	jle    801383 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80135f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801366:	00 
  801367:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  80136e:	00 
  80136f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801376:	00 
  801377:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  80137e:	e8 59 f4 ff ff       	call   8007dc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801383:	83 c4 2c             	add    $0x2c,%esp
  801386:	5b                   	pop    %ebx
  801387:	5e                   	pop    %esi
  801388:	5f                   	pop    %edi
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    

0080138b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	57                   	push   %edi
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801394:	bb 00 00 00 00       	mov    $0x0,%ebx
  801399:	b8 08 00 00 00       	mov    $0x8,%eax
  80139e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a4:	89 df                	mov    %ebx,%edi
  8013a6:	89 de                	mov    %ebx,%esi
  8013a8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	7e 28                	jle    8013d6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013b2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8013b9:	00 
  8013ba:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  8013c1:	00 
  8013c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013c9:	00 
  8013ca:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  8013d1:	e8 06 f4 ff ff       	call   8007dc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013d6:	83 c4 2c             	add    $0x2c,%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	57                   	push   %edi
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
  8013e4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ec:	b8 09 00 00 00       	mov    $0x9,%eax
  8013f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f7:	89 df                	mov    %ebx,%edi
  8013f9:	89 de                	mov    %ebx,%esi
  8013fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	7e 28                	jle    801429 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801401:	89 44 24 10          	mov    %eax,0x10(%esp)
  801405:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80140c:	00 
  80140d:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  801414:	00 
  801415:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80141c:	00 
  80141d:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  801424:	e8 b3 f3 ff ff       	call   8007dc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801429:	83 c4 2c             	add    $0x2c,%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	5f                   	pop    %edi
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	57                   	push   %edi
  801435:	56                   	push   %esi
  801436:	53                   	push   %ebx
  801437:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80143a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80143f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801444:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801447:	8b 55 08             	mov    0x8(%ebp),%edx
  80144a:	89 df                	mov    %ebx,%edi
  80144c:	89 de                	mov    %ebx,%esi
  80144e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801450:	85 c0                	test   %eax,%eax
  801452:	7e 28                	jle    80147c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801454:	89 44 24 10          	mov    %eax,0x10(%esp)
  801458:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80145f:	00 
  801460:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  801467:	00 
  801468:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80146f:	00 
  801470:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  801477:	e8 60 f3 ff ff       	call   8007dc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80147c:	83 c4 2c             	add    $0x2c,%esp
  80147f:	5b                   	pop    %ebx
  801480:	5e                   	pop    %esi
  801481:	5f                   	pop    %edi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	57                   	push   %edi
  801488:	56                   	push   %esi
  801489:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80148a:	be 00 00 00 00       	mov    $0x0,%esi
  80148f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801494:	8b 7d 14             	mov    0x14(%ebp),%edi
  801497:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80149a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80149d:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8014a2:	5b                   	pop    %ebx
  8014a3:	5e                   	pop    %esi
  8014a4:	5f                   	pop    %edi
  8014a5:	5d                   	pop    %ebp
  8014a6:	c3                   	ret    

008014a7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	57                   	push   %edi
  8014ab:	56                   	push   %esi
  8014ac:	53                   	push   %ebx
  8014ad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014b5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8014ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bd:	89 cb                	mov    %ecx,%ebx
  8014bf:	89 cf                	mov    %ecx,%edi
  8014c1:	89 ce                	mov    %ecx,%esi
  8014c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	7e 28                	jle    8014f1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014cd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8014d4:	00 
  8014d5:	c7 44 24 08 1f 2d 80 	movl   $0x802d1f,0x8(%esp)
  8014dc:	00 
  8014dd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014e4:	00 
  8014e5:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  8014ec:	e8 eb f2 ff ff       	call   8007dc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014f1:	83 c4 2c             	add    $0x2c,%esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5e                   	pop    %esi
  8014f6:	5f                   	pop    %edi
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    
  8014f9:	00 00                	add    %al,(%eax)
	...

008014fc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	56                   	push   %esi
  801500:	53                   	push   %ebx
  801501:	83 ec 10             	sub    $0x10,%esp
  801504:	8b 75 08             	mov    0x8(%ebp),%esi
  801507:	8b 45 0c             	mov    0xc(%ebp),%eax
  80150a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  80150d:	85 c0                	test   %eax,%eax
  80150f:	75 05                	jne    801516 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801511:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801516:	89 04 24             	mov    %eax,(%esp)
  801519:	e8 89 ff ff ff       	call   8014a7 <sys_ipc_recv>
	if (!err) {
  80151e:	85 c0                	test   %eax,%eax
  801520:	75 26                	jne    801548 <ipc_recv+0x4c>
		if (from_env_store) {
  801522:	85 f6                	test   %esi,%esi
  801524:	74 0a                	je     801530 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801526:	a1 04 40 80 00       	mov    0x804004,%eax
  80152b:	8b 40 74             	mov    0x74(%eax),%eax
  80152e:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801530:	85 db                	test   %ebx,%ebx
  801532:	74 0a                	je     80153e <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801534:	a1 04 40 80 00       	mov    0x804004,%eax
  801539:	8b 40 78             	mov    0x78(%eax),%eax
  80153c:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  80153e:	a1 04 40 80 00       	mov    0x804004,%eax
  801543:	8b 40 70             	mov    0x70(%eax),%eax
  801546:	eb 14                	jmp    80155c <ipc_recv+0x60>
	}
	if (from_env_store) {
  801548:	85 f6                	test   %esi,%esi
  80154a:	74 06                	je     801552 <ipc_recv+0x56>
		*from_env_store = 0;
  80154c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801552:	85 db                	test   %ebx,%ebx
  801554:	74 06                	je     80155c <ipc_recv+0x60>
		*perm_store = 0;
  801556:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	5b                   	pop    %ebx
  801560:	5e                   	pop    %esi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    

00801563 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	57                   	push   %edi
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
  801569:	83 ec 1c             	sub    $0x1c,%esp
  80156c:	8b 75 10             	mov    0x10(%ebp),%esi
  80156f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801572:	85 f6                	test   %esi,%esi
  801574:	75 05                	jne    80157b <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801576:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  80157b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80157f:	89 74 24 08          	mov    %esi,0x8(%esp)
  801583:	8b 45 0c             	mov    0xc(%ebp),%eax
  801586:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158a:	8b 45 08             	mov    0x8(%ebp),%eax
  80158d:	89 04 24             	mov    %eax,(%esp)
  801590:	e8 ef fe ff ff       	call   801484 <sys_ipc_try_send>
  801595:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801597:	e8 d6 fc ff ff       	call   801272 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  80159c:	83 fb f9             	cmp    $0xfffffff9,%ebx
  80159f:	74 da                	je     80157b <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  8015a1:	85 db                	test   %ebx,%ebx
  8015a3:	74 20                	je     8015c5 <ipc_send+0x62>
		panic("send fail: %e", err);
  8015a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8015a9:	c7 44 24 08 4a 2d 80 	movl   $0x802d4a,0x8(%esp)
  8015b0:	00 
  8015b1:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8015b8:	00 
  8015b9:	c7 04 24 58 2d 80 00 	movl   $0x802d58,(%esp)
  8015c0:	e8 17 f2 ff ff       	call   8007dc <_panic>
	}
	return;
}
  8015c5:	83 c4 1c             	add    $0x1c,%esp
  8015c8:	5b                   	pop    %ebx
  8015c9:	5e                   	pop    %esi
  8015ca:	5f                   	pop    %edi
  8015cb:	5d                   	pop    %ebp
  8015cc:	c3                   	ret    

008015cd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	53                   	push   %ebx
  8015d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8015d4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8015d9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	c1 e2 07             	shl    $0x7,%edx
  8015e5:	29 ca                	sub    %ecx,%edx
  8015e7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8015ed:	8b 52 50             	mov    0x50(%edx),%edx
  8015f0:	39 da                	cmp    %ebx,%edx
  8015f2:	75 0f                	jne    801603 <ipc_find_env+0x36>
			return envs[i].env_id;
  8015f4:	c1 e0 07             	shl    $0x7,%eax
  8015f7:	29 c8                	sub    %ecx,%eax
  8015f9:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8015fe:	8b 40 40             	mov    0x40(%eax),%eax
  801601:	eb 0c                	jmp    80160f <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801603:	40                   	inc    %eax
  801604:	3d 00 04 00 00       	cmp    $0x400,%eax
  801609:	75 ce                	jne    8015d9 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80160b:	66 b8 00 00          	mov    $0x0,%ax
}
  80160f:	5b                   	pop    %ebx
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    
	...

00801614 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801617:	8b 45 08             	mov    0x8(%ebp),%eax
  80161a:	05 00 00 00 30       	add    $0x30000000,%eax
  80161f:	c1 e8 0c             	shr    $0xc,%eax
}
  801622:	5d                   	pop    %ebp
  801623:	c3                   	ret    

00801624 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80162a:	8b 45 08             	mov    0x8(%ebp),%eax
  80162d:	89 04 24             	mov    %eax,(%esp)
  801630:	e8 df ff ff ff       	call   801614 <fd2num>
  801635:	05 20 00 0d 00       	add    $0xd0020,%eax
  80163a:	c1 e0 0c             	shl    $0xc,%eax
}
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801646:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80164b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80164d:	89 c2                	mov    %eax,%edx
  80164f:	c1 ea 16             	shr    $0x16,%edx
  801652:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801659:	f6 c2 01             	test   $0x1,%dl
  80165c:	74 11                	je     80166f <fd_alloc+0x30>
  80165e:	89 c2                	mov    %eax,%edx
  801660:	c1 ea 0c             	shr    $0xc,%edx
  801663:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80166a:	f6 c2 01             	test   $0x1,%dl
  80166d:	75 09                	jne    801678 <fd_alloc+0x39>
			*fd_store = fd;
  80166f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801671:	b8 00 00 00 00       	mov    $0x0,%eax
  801676:	eb 17                	jmp    80168f <fd_alloc+0x50>
  801678:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80167d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801682:	75 c7                	jne    80164b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801684:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80168a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80168f:	5b                   	pop    %ebx
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    

00801692 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801698:	83 f8 1f             	cmp    $0x1f,%eax
  80169b:	77 36                	ja     8016d3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80169d:	05 00 00 0d 00       	add    $0xd0000,%eax
  8016a2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016a5:	89 c2                	mov    %eax,%edx
  8016a7:	c1 ea 16             	shr    $0x16,%edx
  8016aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016b1:	f6 c2 01             	test   $0x1,%dl
  8016b4:	74 24                	je     8016da <fd_lookup+0x48>
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	c1 ea 0c             	shr    $0xc,%edx
  8016bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016c2:	f6 c2 01             	test   $0x1,%dl
  8016c5:	74 1a                	je     8016e1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ca:	89 02                	mov    %eax,(%edx)
	return 0;
  8016cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d1:	eb 13                	jmp    8016e6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d8:	eb 0c                	jmp    8016e6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016df:	eb 05                	jmp    8016e6 <fd_lookup+0x54>
  8016e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    

008016e8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 14             	sub    $0x14,%esp
  8016ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8016f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fa:	eb 0e                	jmp    80170a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8016fc:	39 08                	cmp    %ecx,(%eax)
  8016fe:	75 09                	jne    801709 <dev_lookup+0x21>
			*dev = devtab[i];
  801700:	89 03                	mov    %eax,(%ebx)
			return 0;
  801702:	b8 00 00 00 00       	mov    $0x0,%eax
  801707:	eb 33                	jmp    80173c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801709:	42                   	inc    %edx
  80170a:	8b 04 95 e4 2d 80 00 	mov    0x802de4(,%edx,4),%eax
  801711:	85 c0                	test   %eax,%eax
  801713:	75 e7                	jne    8016fc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801715:	a1 04 40 80 00       	mov    0x804004,%eax
  80171a:	8b 40 48             	mov    0x48(%eax),%eax
  80171d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801721:	89 44 24 04          	mov    %eax,0x4(%esp)
  801725:	c7 04 24 64 2d 80 00 	movl   $0x802d64,(%esp)
  80172c:	e8 a3 f1 ff ff       	call   8008d4 <cprintf>
	*dev = 0;
  801731:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801737:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80173c:	83 c4 14             	add    $0x14,%esp
  80173f:	5b                   	pop    %ebx
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    

00801742 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	56                   	push   %esi
  801746:	53                   	push   %ebx
  801747:	83 ec 30             	sub    $0x30,%esp
  80174a:	8b 75 08             	mov    0x8(%ebp),%esi
  80174d:	8a 45 0c             	mov    0xc(%ebp),%al
  801750:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801753:	89 34 24             	mov    %esi,(%esp)
  801756:	e8 b9 fe ff ff       	call   801614 <fd2num>
  80175b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80175e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801762:	89 04 24             	mov    %eax,(%esp)
  801765:	e8 28 ff ff ff       	call   801692 <fd_lookup>
  80176a:	89 c3                	mov    %eax,%ebx
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 05                	js     801775 <fd_close+0x33>
	    || fd != fd2)
  801770:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801773:	74 0d                	je     801782 <fd_close+0x40>
		return (must_exist ? r : 0);
  801775:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801779:	75 46                	jne    8017c1 <fd_close+0x7f>
  80177b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801780:	eb 3f                	jmp    8017c1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801782:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801785:	89 44 24 04          	mov    %eax,0x4(%esp)
  801789:	8b 06                	mov    (%esi),%eax
  80178b:	89 04 24             	mov    %eax,(%esp)
  80178e:	e8 55 ff ff ff       	call   8016e8 <dev_lookup>
  801793:	89 c3                	mov    %eax,%ebx
  801795:	85 c0                	test   %eax,%eax
  801797:	78 18                	js     8017b1 <fd_close+0x6f>
		if (dev->dev_close)
  801799:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179c:	8b 40 10             	mov    0x10(%eax),%eax
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	74 09                	je     8017ac <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8017a3:	89 34 24             	mov    %esi,(%esp)
  8017a6:	ff d0                	call   *%eax
  8017a8:	89 c3                	mov    %eax,%ebx
  8017aa:	eb 05                	jmp    8017b1 <fd_close+0x6f>
		else
			r = 0;
  8017ac:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8017b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017bc:	e8 77 fb ff ff       	call   801338 <sys_page_unmap>
	return r;
}
  8017c1:	89 d8                	mov    %ebx,%eax
  8017c3:	83 c4 30             	add    $0x30,%esp
  8017c6:	5b                   	pop    %ebx
  8017c7:	5e                   	pop    %esi
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	89 04 24             	mov    %eax,(%esp)
  8017dd:	e8 b0 fe ff ff       	call   801692 <fd_lookup>
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 13                	js     8017f9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8017e6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8017ed:	00 
  8017ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f1:	89 04 24             	mov    %eax,(%esp)
  8017f4:	e8 49 ff ff ff       	call   801742 <fd_close>
}
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <close_all>:

void
close_all(void)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801802:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801807:	89 1c 24             	mov    %ebx,(%esp)
  80180a:	e8 bb ff ff ff       	call   8017ca <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80180f:	43                   	inc    %ebx
  801810:	83 fb 20             	cmp    $0x20,%ebx
  801813:	75 f2                	jne    801807 <close_all+0xc>
		close(i);
}
  801815:	83 c4 14             	add    $0x14,%esp
  801818:	5b                   	pop    %ebx
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	57                   	push   %edi
  80181f:	56                   	push   %esi
  801820:	53                   	push   %ebx
  801821:	83 ec 4c             	sub    $0x4c,%esp
  801824:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801827:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80182a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182e:	8b 45 08             	mov    0x8(%ebp),%eax
  801831:	89 04 24             	mov    %eax,(%esp)
  801834:	e8 59 fe ff ff       	call   801692 <fd_lookup>
  801839:	89 c3                	mov    %eax,%ebx
  80183b:	85 c0                	test   %eax,%eax
  80183d:	0f 88 e1 00 00 00    	js     801924 <dup+0x109>
		return r;
	close(newfdnum);
  801843:	89 3c 24             	mov    %edi,(%esp)
  801846:	e8 7f ff ff ff       	call   8017ca <close>

	newfd = INDEX2FD(newfdnum);
  80184b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801851:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801854:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801857:	89 04 24             	mov    %eax,(%esp)
  80185a:	e8 c5 fd ff ff       	call   801624 <fd2data>
  80185f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801861:	89 34 24             	mov    %esi,(%esp)
  801864:	e8 bb fd ff ff       	call   801624 <fd2data>
  801869:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80186c:	89 d8                	mov    %ebx,%eax
  80186e:	c1 e8 16             	shr    $0x16,%eax
  801871:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801878:	a8 01                	test   $0x1,%al
  80187a:	74 46                	je     8018c2 <dup+0xa7>
  80187c:	89 d8                	mov    %ebx,%eax
  80187e:	c1 e8 0c             	shr    $0xc,%eax
  801881:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801888:	f6 c2 01             	test   $0x1,%dl
  80188b:	74 35                	je     8018c2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80188d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801894:	25 07 0e 00 00       	and    $0xe07,%eax
  801899:	89 44 24 10          	mov    %eax,0x10(%esp)
  80189d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018ab:	00 
  8018ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b7:	e8 29 fa ff ff       	call   8012e5 <sys_page_map>
  8018bc:	89 c3                	mov    %eax,%ebx
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	78 3b                	js     8018fd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018c5:	89 c2                	mov    %eax,%edx
  8018c7:	c1 ea 0c             	shr    $0xc,%edx
  8018ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018d1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8018d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018e6:	00 
  8018e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f2:	e8 ee f9 ff ff       	call   8012e5 <sys_page_map>
  8018f7:	89 c3                	mov    %eax,%ebx
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	79 25                	jns    801922 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8018fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801901:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801908:	e8 2b fa ff ff       	call   801338 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80190d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801910:	89 44 24 04          	mov    %eax,0x4(%esp)
  801914:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191b:	e8 18 fa ff ff       	call   801338 <sys_page_unmap>
	return r;
  801920:	eb 02                	jmp    801924 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801922:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801924:	89 d8                	mov    %ebx,%eax
  801926:	83 c4 4c             	add    $0x4c,%esp
  801929:	5b                   	pop    %ebx
  80192a:	5e                   	pop    %esi
  80192b:	5f                   	pop    %edi
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    

0080192e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	53                   	push   %ebx
  801932:	83 ec 24             	sub    $0x24,%esp
  801935:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801938:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80193b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193f:	89 1c 24             	mov    %ebx,(%esp)
  801942:	e8 4b fd ff ff       	call   801692 <fd_lookup>
  801947:	85 c0                	test   %eax,%eax
  801949:	78 6d                	js     8019b8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80194b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801952:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801955:	8b 00                	mov    (%eax),%eax
  801957:	89 04 24             	mov    %eax,(%esp)
  80195a:	e8 89 fd ff ff       	call   8016e8 <dev_lookup>
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 55                	js     8019b8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801963:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801966:	8b 50 08             	mov    0x8(%eax),%edx
  801969:	83 e2 03             	and    $0x3,%edx
  80196c:	83 fa 01             	cmp    $0x1,%edx
  80196f:	75 23                	jne    801994 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801971:	a1 04 40 80 00       	mov    0x804004,%eax
  801976:	8b 40 48             	mov    0x48(%eax),%eax
  801979:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80197d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801981:	c7 04 24 a8 2d 80 00 	movl   $0x802da8,(%esp)
  801988:	e8 47 ef ff ff       	call   8008d4 <cprintf>
		return -E_INVAL;
  80198d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801992:	eb 24                	jmp    8019b8 <read+0x8a>
	}
	if (!dev->dev_read)
  801994:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801997:	8b 52 08             	mov    0x8(%edx),%edx
  80199a:	85 d2                	test   %edx,%edx
  80199c:	74 15                	je     8019b3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80199e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019a1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019ac:	89 04 24             	mov    %eax,(%esp)
  8019af:	ff d2                	call   *%edx
  8019b1:	eb 05                	jmp    8019b8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8019b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8019b8:	83 c4 24             	add    $0x24,%esp
  8019bb:	5b                   	pop    %ebx
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	57                   	push   %edi
  8019c2:	56                   	push   %esi
  8019c3:	53                   	push   %ebx
  8019c4:	83 ec 1c             	sub    $0x1c,%esp
  8019c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019d2:	eb 23                	jmp    8019f7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019d4:	89 f0                	mov    %esi,%eax
  8019d6:	29 d8                	sub    %ebx,%eax
  8019d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019df:	01 d8                	add    %ebx,%eax
  8019e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e5:	89 3c 24             	mov    %edi,(%esp)
  8019e8:	e8 41 ff ff ff       	call   80192e <read>
		if (m < 0)
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	78 10                	js     801a01 <readn+0x43>
			return m;
		if (m == 0)
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	74 0a                	je     8019ff <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019f5:	01 c3                	add    %eax,%ebx
  8019f7:	39 f3                	cmp    %esi,%ebx
  8019f9:	72 d9                	jb     8019d4 <readn+0x16>
  8019fb:	89 d8                	mov    %ebx,%eax
  8019fd:	eb 02                	jmp    801a01 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8019ff:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801a01:	83 c4 1c             	add    $0x1c,%esp
  801a04:	5b                   	pop    %ebx
  801a05:	5e                   	pop    %esi
  801a06:	5f                   	pop    %edi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	53                   	push   %ebx
  801a0d:	83 ec 24             	sub    $0x24,%esp
  801a10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a13:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1a:	89 1c 24             	mov    %ebx,(%esp)
  801a1d:	e8 70 fc ff ff       	call   801692 <fd_lookup>
  801a22:	85 c0                	test   %eax,%eax
  801a24:	78 68                	js     801a8e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a30:	8b 00                	mov    (%eax),%eax
  801a32:	89 04 24             	mov    %eax,(%esp)
  801a35:	e8 ae fc ff ff       	call   8016e8 <dev_lookup>
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	78 50                	js     801a8e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a41:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a45:	75 23                	jne    801a6a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a47:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4c:	8b 40 48             	mov    0x48(%eax),%eax
  801a4f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a57:	c7 04 24 c4 2d 80 00 	movl   $0x802dc4,(%esp)
  801a5e:	e8 71 ee ff ff       	call   8008d4 <cprintf>
		return -E_INVAL;
  801a63:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a68:	eb 24                	jmp    801a8e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a6d:	8b 52 0c             	mov    0xc(%edx),%edx
  801a70:	85 d2                	test   %edx,%edx
  801a72:	74 15                	je     801a89 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a74:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a77:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a7e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a82:	89 04 24             	mov    %eax,(%esp)
  801a85:	ff d2                	call   *%edx
  801a87:	eb 05                	jmp    801a8e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a89:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801a8e:	83 c4 24             	add    $0x24,%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    

00801a94 <seek>:

int
seek(int fdnum, off_t offset)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a9a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa4:	89 04 24             	mov    %eax,(%esp)
  801aa7:	e8 e6 fb ff ff       	call   801692 <fd_lookup>
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 0e                	js     801abe <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801ab0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ab6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801ab9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 24             	sub    $0x24,%esp
  801ac7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801acd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad1:	89 1c 24             	mov    %ebx,(%esp)
  801ad4:	e8 b9 fb ff ff       	call   801692 <fd_lookup>
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	78 61                	js     801b3e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801add:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae7:	8b 00                	mov    (%eax),%eax
  801ae9:	89 04 24             	mov    %eax,(%esp)
  801aec:	e8 f7 fb ff ff       	call   8016e8 <dev_lookup>
  801af1:	85 c0                	test   %eax,%eax
  801af3:	78 49                	js     801b3e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801af5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801afc:	75 23                	jne    801b21 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801afe:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b03:	8b 40 48             	mov    0x48(%eax),%eax
  801b06:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0e:	c7 04 24 84 2d 80 00 	movl   $0x802d84,(%esp)
  801b15:	e8 ba ed ff ff       	call   8008d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b1f:	eb 1d                	jmp    801b3e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801b21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b24:	8b 52 18             	mov    0x18(%edx),%edx
  801b27:	85 d2                	test   %edx,%edx
  801b29:	74 0e                	je     801b39 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b2e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b32:	89 04 24             	mov    %eax,(%esp)
  801b35:	ff d2                	call   *%edx
  801b37:	eb 05                	jmp    801b3e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b39:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801b3e:	83 c4 24             	add    $0x24,%esp
  801b41:	5b                   	pop    %ebx
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	53                   	push   %ebx
  801b48:	83 ec 24             	sub    $0x24,%esp
  801b4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b4e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b55:	8b 45 08             	mov    0x8(%ebp),%eax
  801b58:	89 04 24             	mov    %eax,(%esp)
  801b5b:	e8 32 fb ff ff       	call   801692 <fd_lookup>
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 52                	js     801bb6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6e:	8b 00                	mov    (%eax),%eax
  801b70:	89 04 24             	mov    %eax,(%esp)
  801b73:	e8 70 fb ff ff       	call   8016e8 <dev_lookup>
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	78 3a                	js     801bb6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b83:	74 2c                	je     801bb1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b85:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b88:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b8f:	00 00 00 
	stat->st_isdir = 0;
  801b92:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b99:	00 00 00 
	stat->st_dev = dev;
  801b9c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ba2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ba6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ba9:	89 14 24             	mov    %edx,(%esp)
  801bac:	ff 50 14             	call   *0x14(%eax)
  801baf:	eb 05                	jmp    801bb6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801bb1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801bb6:	83 c4 24             	add    $0x24,%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5d                   	pop    %ebp
  801bbb:	c3                   	ret    

00801bbc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801bc4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bcb:	00 
  801bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcf:	89 04 24             	mov    %eax,(%esp)
  801bd2:	e8 fe 01 00 00       	call   801dd5 <open>
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	78 1b                	js     801bf8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be4:	89 1c 24             	mov    %ebx,(%esp)
  801be7:	e8 58 ff ff ff       	call   801b44 <fstat>
  801bec:	89 c6                	mov    %eax,%esi
	close(fd);
  801bee:	89 1c 24             	mov    %ebx,(%esp)
  801bf1:	e8 d4 fb ff ff       	call   8017ca <close>
	return r;
  801bf6:	89 f3                	mov    %esi,%ebx
}
  801bf8:	89 d8                	mov    %ebx,%eax
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    
  801c01:	00 00                	add    %al,(%eax)
	...

00801c04 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	56                   	push   %esi
  801c08:	53                   	push   %ebx
  801c09:	83 ec 10             	sub    $0x10,%esp
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c10:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801c17:	75 11                	jne    801c2a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c20:	e8 a8 f9 ff ff       	call   8015cd <ipc_find_env>
  801c25:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c2a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c31:	00 
  801c32:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c39:	00 
  801c3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3e:	a1 00 40 80 00       	mov    0x804000,%eax
  801c43:	89 04 24             	mov    %eax,(%esp)
  801c46:	e8 18 f9 ff ff       	call   801563 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c52:	00 
  801c53:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5e:	e8 99 f8 ff ff       	call   8014fc <ipc_recv>
}
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	5b                   	pop    %ebx
  801c67:	5e                   	pop    %esi
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    

00801c6a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c70:	8b 45 08             	mov    0x8(%ebp),%eax
  801c73:	8b 40 0c             	mov    0xc(%eax),%eax
  801c76:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c83:	ba 00 00 00 00       	mov    $0x0,%edx
  801c88:	b8 02 00 00 00       	mov    $0x2,%eax
  801c8d:	e8 72 ff ff ff       	call   801c04 <fsipc>
}
  801c92:	c9                   	leave  
  801c93:	c3                   	ret    

00801c94 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9d:	8b 40 0c             	mov    0xc(%eax),%eax
  801ca0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ca5:	ba 00 00 00 00       	mov    $0x0,%edx
  801caa:	b8 06 00 00 00       	mov    $0x6,%eax
  801caf:	e8 50 ff ff ff       	call   801c04 <fsipc>
}
  801cb4:	c9                   	leave  
  801cb5:	c3                   	ret    

00801cb6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	53                   	push   %ebx
  801cba:	83 ec 14             	sub    $0x14,%esp
  801cbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc3:	8b 40 0c             	mov    0xc(%eax),%eax
  801cc6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ccb:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd0:	b8 05 00 00 00       	mov    $0x5,%eax
  801cd5:	e8 2a ff ff ff       	call   801c04 <fsipc>
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	78 2b                	js     801d09 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cde:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ce5:	00 
  801ce6:	89 1c 24             	mov    %ebx,(%esp)
  801ce9:	e8 b1 f1 ff ff       	call   800e9f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cee:	a1 80 50 80 00       	mov    0x805080,%eax
  801cf3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cf9:	a1 84 50 80 00       	mov    0x805084,%eax
  801cfe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d09:	83 c4 14             	add    $0x14,%esp
  801d0c:	5b                   	pop    %ebx
  801d0d:	5d                   	pop    %ebp
  801d0e:	c3                   	ret    

00801d0f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801d15:	c7 44 24 08 f4 2d 80 	movl   $0x802df4,0x8(%esp)
  801d1c:	00 
  801d1d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801d24:	00 
  801d25:	c7 04 24 12 2e 80 00 	movl   $0x802e12,(%esp)
  801d2c:	e8 ab ea ff ff       	call   8007dc <_panic>

00801d31 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	56                   	push   %esi
  801d35:	53                   	push   %ebx
  801d36:	83 ec 10             	sub    $0x10,%esp
  801d39:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d42:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801d47:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d52:	b8 03 00 00 00       	mov    $0x3,%eax
  801d57:	e8 a8 fe ff ff       	call   801c04 <fsipc>
  801d5c:	89 c3                	mov    %eax,%ebx
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	78 6a                	js     801dcc <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801d62:	39 c6                	cmp    %eax,%esi
  801d64:	73 24                	jae    801d8a <devfile_read+0x59>
  801d66:	c7 44 24 0c 1d 2e 80 	movl   $0x802e1d,0xc(%esp)
  801d6d:	00 
  801d6e:	c7 44 24 08 24 2e 80 	movl   $0x802e24,0x8(%esp)
  801d75:	00 
  801d76:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801d7d:	00 
  801d7e:	c7 04 24 12 2e 80 00 	movl   $0x802e12,(%esp)
  801d85:	e8 52 ea ff ff       	call   8007dc <_panic>
	assert(r <= PGSIZE);
  801d8a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d8f:	7e 24                	jle    801db5 <devfile_read+0x84>
  801d91:	c7 44 24 0c 39 2e 80 	movl   $0x802e39,0xc(%esp)
  801d98:	00 
  801d99:	c7 44 24 08 24 2e 80 	movl   $0x802e24,0x8(%esp)
  801da0:	00 
  801da1:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801da8:	00 
  801da9:	c7 04 24 12 2e 80 00 	movl   $0x802e12,(%esp)
  801db0:	e8 27 ea ff ff       	call   8007dc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801db5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db9:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801dc0:	00 
  801dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc4:	89 04 24             	mov    %eax,(%esp)
  801dc7:	e8 4c f2 ff ff       	call   801018 <memmove>
	return r;
}
  801dcc:	89 d8                	mov    %ebx,%eax
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	5b                   	pop    %ebx
  801dd2:	5e                   	pop    %esi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	56                   	push   %esi
  801dd9:	53                   	push   %ebx
  801dda:	83 ec 20             	sub    $0x20,%esp
  801ddd:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801de0:	89 34 24             	mov    %esi,(%esp)
  801de3:	e8 84 f0 ff ff       	call   800e6c <strlen>
  801de8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ded:	7f 60                	jg     801e4f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801def:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df2:	89 04 24             	mov    %eax,(%esp)
  801df5:	e8 45 f8 ff ff       	call   80163f <fd_alloc>
  801dfa:	89 c3                	mov    %eax,%ebx
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	78 54                	js     801e54 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e00:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e04:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e0b:	e8 8f f0 ff ff       	call   800e9f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e13:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e18:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e1b:	b8 01 00 00 00       	mov    $0x1,%eax
  801e20:	e8 df fd ff ff       	call   801c04 <fsipc>
  801e25:	89 c3                	mov    %eax,%ebx
  801e27:	85 c0                	test   %eax,%eax
  801e29:	79 15                	jns    801e40 <open+0x6b>
		fd_close(fd, 0);
  801e2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e32:	00 
  801e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e36:	89 04 24             	mov    %eax,(%esp)
  801e39:	e8 04 f9 ff ff       	call   801742 <fd_close>
		return r;
  801e3e:	eb 14                	jmp    801e54 <open+0x7f>
	}

	return fd2num(fd);
  801e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e43:	89 04 24             	mov    %eax,(%esp)
  801e46:	e8 c9 f7 ff ff       	call   801614 <fd2num>
  801e4b:	89 c3                	mov    %eax,%ebx
  801e4d:	eb 05                	jmp    801e54 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e4f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e54:	89 d8                	mov    %ebx,%eax
  801e56:	83 c4 20             	add    $0x20,%esp
  801e59:	5b                   	pop    %ebx
  801e5a:	5e                   	pop    %esi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    

00801e5d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e63:	ba 00 00 00 00       	mov    $0x0,%edx
  801e68:	b8 08 00 00 00       	mov    $0x8,%eax
  801e6d:	e8 92 fd ff ff       	call   801c04 <fsipc>
}
  801e72:	c9                   	leave  
  801e73:	c3                   	ret    

00801e74 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	56                   	push   %esi
  801e78:	53                   	push   %ebx
  801e79:	83 ec 10             	sub    $0x10,%esp
  801e7c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e82:	89 04 24             	mov    %eax,(%esp)
  801e85:	e8 9a f7 ff ff       	call   801624 <fd2data>
  801e8a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e8c:	c7 44 24 04 45 2e 80 	movl   $0x802e45,0x4(%esp)
  801e93:	00 
  801e94:	89 34 24             	mov    %esi,(%esp)
  801e97:	e8 03 f0 ff ff       	call   800e9f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e9c:	8b 43 04             	mov    0x4(%ebx),%eax
  801e9f:	2b 03                	sub    (%ebx),%eax
  801ea1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ea7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801eae:	00 00 00 
	stat->st_dev = &devpipe;
  801eb1:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801eb8:	30 80 00 
	return 0;
}
  801ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec0:	83 c4 10             	add    $0x10,%esp
  801ec3:	5b                   	pop    %ebx
  801ec4:	5e                   	pop    %esi
  801ec5:	5d                   	pop    %ebp
  801ec6:	c3                   	ret    

00801ec7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	53                   	push   %ebx
  801ecb:	83 ec 14             	sub    $0x14,%esp
  801ece:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ed1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ed5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801edc:	e8 57 f4 ff ff       	call   801338 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ee1:	89 1c 24             	mov    %ebx,(%esp)
  801ee4:	e8 3b f7 ff ff       	call   801624 <fd2data>
  801ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ef4:	e8 3f f4 ff ff       	call   801338 <sys_page_unmap>
}
  801ef9:	83 c4 14             	add    $0x14,%esp
  801efc:	5b                   	pop    %ebx
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    

00801eff <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	57                   	push   %edi
  801f03:	56                   	push   %esi
  801f04:	53                   	push   %ebx
  801f05:	83 ec 2c             	sub    $0x2c,%esp
  801f08:	89 c7                	mov    %eax,%edi
  801f0a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f0d:	a1 04 40 80 00       	mov    0x804004,%eax
  801f12:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f15:	89 3c 24             	mov    %edi,(%esp)
  801f18:	e8 6f 04 00 00       	call   80238c <pageref>
  801f1d:	89 c6                	mov    %eax,%esi
  801f1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f22:	89 04 24             	mov    %eax,(%esp)
  801f25:	e8 62 04 00 00       	call   80238c <pageref>
  801f2a:	39 c6                	cmp    %eax,%esi
  801f2c:	0f 94 c0             	sete   %al
  801f2f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f32:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f38:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f3b:	39 cb                	cmp    %ecx,%ebx
  801f3d:	75 08                	jne    801f47 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f3f:	83 c4 2c             	add    $0x2c,%esp
  801f42:	5b                   	pop    %ebx
  801f43:	5e                   	pop    %esi
  801f44:	5f                   	pop    %edi
  801f45:	5d                   	pop    %ebp
  801f46:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801f47:	83 f8 01             	cmp    $0x1,%eax
  801f4a:	75 c1                	jne    801f0d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f4c:	8b 42 58             	mov    0x58(%edx),%eax
  801f4f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801f56:	00 
  801f57:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f5b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f5f:	c7 04 24 4c 2e 80 00 	movl   $0x802e4c,(%esp)
  801f66:	e8 69 e9 ff ff       	call   8008d4 <cprintf>
  801f6b:	eb a0                	jmp    801f0d <_pipeisclosed+0xe>

00801f6d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	57                   	push   %edi
  801f71:	56                   	push   %esi
  801f72:	53                   	push   %ebx
  801f73:	83 ec 1c             	sub    $0x1c,%esp
  801f76:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f79:	89 34 24             	mov    %esi,(%esp)
  801f7c:	e8 a3 f6 ff ff       	call   801624 <fd2data>
  801f81:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f83:	bf 00 00 00 00       	mov    $0x0,%edi
  801f88:	eb 3c                	jmp    801fc6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f8a:	89 da                	mov    %ebx,%edx
  801f8c:	89 f0                	mov    %esi,%eax
  801f8e:	e8 6c ff ff ff       	call   801eff <_pipeisclosed>
  801f93:	85 c0                	test   %eax,%eax
  801f95:	75 38                	jne    801fcf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f97:	e8 d6 f2 ff ff       	call   801272 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f9c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f9f:	8b 13                	mov    (%ebx),%edx
  801fa1:	83 c2 20             	add    $0x20,%edx
  801fa4:	39 d0                	cmp    %edx,%eax
  801fa6:	73 e2                	jae    801f8a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fa8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fab:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801fae:	89 c2                	mov    %eax,%edx
  801fb0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801fb6:	79 05                	jns    801fbd <devpipe_write+0x50>
  801fb8:	4a                   	dec    %edx
  801fb9:	83 ca e0             	or     $0xffffffe0,%edx
  801fbc:	42                   	inc    %edx
  801fbd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fc1:	40                   	inc    %eax
  801fc2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fc5:	47                   	inc    %edi
  801fc6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fc9:	75 d1                	jne    801f9c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fcb:	89 f8                	mov    %edi,%eax
  801fcd:	eb 05                	jmp    801fd4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fcf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fd4:	83 c4 1c             	add    $0x1c,%esp
  801fd7:	5b                   	pop    %ebx
  801fd8:	5e                   	pop    %esi
  801fd9:	5f                   	pop    %edi
  801fda:	5d                   	pop    %ebp
  801fdb:	c3                   	ret    

00801fdc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	57                   	push   %edi
  801fe0:	56                   	push   %esi
  801fe1:	53                   	push   %ebx
  801fe2:	83 ec 1c             	sub    $0x1c,%esp
  801fe5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fe8:	89 3c 24             	mov    %edi,(%esp)
  801feb:	e8 34 f6 ff ff       	call   801624 <fd2data>
  801ff0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff2:	be 00 00 00 00       	mov    $0x0,%esi
  801ff7:	eb 3a                	jmp    802033 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ff9:	85 f6                	test   %esi,%esi
  801ffb:	74 04                	je     802001 <devpipe_read+0x25>
				return i;
  801ffd:	89 f0                	mov    %esi,%eax
  801fff:	eb 40                	jmp    802041 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802001:	89 da                	mov    %ebx,%edx
  802003:	89 f8                	mov    %edi,%eax
  802005:	e8 f5 fe ff ff       	call   801eff <_pipeisclosed>
  80200a:	85 c0                	test   %eax,%eax
  80200c:	75 2e                	jne    80203c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80200e:	e8 5f f2 ff ff       	call   801272 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802013:	8b 03                	mov    (%ebx),%eax
  802015:	3b 43 04             	cmp    0x4(%ebx),%eax
  802018:	74 df                	je     801ff9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80201a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80201f:	79 05                	jns    802026 <devpipe_read+0x4a>
  802021:	48                   	dec    %eax
  802022:	83 c8 e0             	or     $0xffffffe0,%eax
  802025:	40                   	inc    %eax
  802026:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80202a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80202d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802030:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802032:	46                   	inc    %esi
  802033:	3b 75 10             	cmp    0x10(%ebp),%esi
  802036:	75 db                	jne    802013 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802038:	89 f0                	mov    %esi,%eax
  80203a:	eb 05                	jmp    802041 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80203c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802041:	83 c4 1c             	add    $0x1c,%esp
  802044:	5b                   	pop    %ebx
  802045:	5e                   	pop    %esi
  802046:	5f                   	pop    %edi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    

00802049 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	57                   	push   %edi
  80204d:	56                   	push   %esi
  80204e:	53                   	push   %ebx
  80204f:	83 ec 3c             	sub    $0x3c,%esp
  802052:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802055:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802058:	89 04 24             	mov    %eax,(%esp)
  80205b:	e8 df f5 ff ff       	call   80163f <fd_alloc>
  802060:	89 c3                	mov    %eax,%ebx
  802062:	85 c0                	test   %eax,%eax
  802064:	0f 88 45 01 00 00    	js     8021af <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80206a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802071:	00 
  802072:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802075:	89 44 24 04          	mov    %eax,0x4(%esp)
  802079:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802080:	e8 0c f2 ff ff       	call   801291 <sys_page_alloc>
  802085:	89 c3                	mov    %eax,%ebx
  802087:	85 c0                	test   %eax,%eax
  802089:	0f 88 20 01 00 00    	js     8021af <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80208f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802092:	89 04 24             	mov    %eax,(%esp)
  802095:	e8 a5 f5 ff ff       	call   80163f <fd_alloc>
  80209a:	89 c3                	mov    %eax,%ebx
  80209c:	85 c0                	test   %eax,%eax
  80209e:	0f 88 f8 00 00 00    	js     80219c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020ab:	00 
  8020ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ba:	e8 d2 f1 ff ff       	call   801291 <sys_page_alloc>
  8020bf:	89 c3                	mov    %eax,%ebx
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	0f 88 d3 00 00 00    	js     80219c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020cc:	89 04 24             	mov    %eax,(%esp)
  8020cf:	e8 50 f5 ff ff       	call   801624 <fd2data>
  8020d4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020dd:	00 
  8020de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e9:	e8 a3 f1 ff ff       	call   801291 <sys_page_alloc>
  8020ee:	89 c3                	mov    %eax,%ebx
  8020f0:	85 c0                	test   %eax,%eax
  8020f2:	0f 88 91 00 00 00    	js     802189 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020fb:	89 04 24             	mov    %eax,(%esp)
  8020fe:	e8 21 f5 ff ff       	call   801624 <fd2data>
  802103:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80210a:	00 
  80210b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802116:	00 
  802117:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802122:	e8 be f1 ff ff       	call   8012e5 <sys_page_map>
  802127:	89 c3                	mov    %eax,%ebx
  802129:	85 c0                	test   %eax,%eax
  80212b:	78 4c                	js     802179 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80212d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802133:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802136:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802138:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80213b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802142:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802148:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80214b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80214d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802150:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802157:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80215a:	89 04 24             	mov    %eax,(%esp)
  80215d:	e8 b2 f4 ff ff       	call   801614 <fd2num>
  802162:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802164:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802167:	89 04 24             	mov    %eax,(%esp)
  80216a:	e8 a5 f4 ff ff       	call   801614 <fd2num>
  80216f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802172:	bb 00 00 00 00       	mov    $0x0,%ebx
  802177:	eb 36                	jmp    8021af <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802179:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802184:	e8 af f1 ff ff       	call   801338 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802189:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80218c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802190:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802197:	e8 9c f1 ff ff       	call   801338 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80219c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80219f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021aa:	e8 89 f1 ff ff       	call   801338 <sys_page_unmap>
    err:
	return r;
}
  8021af:	89 d8                	mov    %ebx,%eax
  8021b1:	83 c4 3c             	add    $0x3c,%esp
  8021b4:	5b                   	pop    %ebx
  8021b5:	5e                   	pop    %esi
  8021b6:	5f                   	pop    %edi
  8021b7:	5d                   	pop    %ebp
  8021b8:	c3                   	ret    

008021b9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021b9:	55                   	push   %ebp
  8021ba:	89 e5                	mov    %esp,%ebp
  8021bc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c9:	89 04 24             	mov    %eax,(%esp)
  8021cc:	e8 c1 f4 ff ff       	call   801692 <fd_lookup>
  8021d1:	85 c0                	test   %eax,%eax
  8021d3:	78 15                	js     8021ea <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d8:	89 04 24             	mov    %eax,(%esp)
  8021db:	e8 44 f4 ff ff       	call   801624 <fd2data>
	return _pipeisclosed(fd, p);
  8021e0:	89 c2                	mov    %eax,%edx
  8021e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e5:	e8 15 fd ff ff       	call   801eff <_pipeisclosed>
}
  8021ea:	c9                   	leave  
  8021eb:	c3                   	ret    

008021ec <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f4:	5d                   	pop    %ebp
  8021f5:	c3                   	ret    

008021f6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021f6:	55                   	push   %ebp
  8021f7:	89 e5                	mov    %esp,%ebp
  8021f9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8021fc:	c7 44 24 04 64 2e 80 	movl   $0x802e64,0x4(%esp)
  802203:	00 
  802204:	8b 45 0c             	mov    0xc(%ebp),%eax
  802207:	89 04 24             	mov    %eax,(%esp)
  80220a:	e8 90 ec ff ff       	call   800e9f <strcpy>
	return 0;
}
  80220f:	b8 00 00 00 00       	mov    $0x0,%eax
  802214:	c9                   	leave  
  802215:	c3                   	ret    

00802216 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	57                   	push   %edi
  80221a:	56                   	push   %esi
  80221b:	53                   	push   %ebx
  80221c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802222:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802227:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80222d:	eb 30                	jmp    80225f <devcons_write+0x49>
		m = n - tot;
  80222f:	8b 75 10             	mov    0x10(%ebp),%esi
  802232:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802234:	83 fe 7f             	cmp    $0x7f,%esi
  802237:	76 05                	jbe    80223e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802239:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80223e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802242:	03 45 0c             	add    0xc(%ebp),%eax
  802245:	89 44 24 04          	mov    %eax,0x4(%esp)
  802249:	89 3c 24             	mov    %edi,(%esp)
  80224c:	e8 c7 ed ff ff       	call   801018 <memmove>
		sys_cputs(buf, m);
  802251:	89 74 24 04          	mov    %esi,0x4(%esp)
  802255:	89 3c 24             	mov    %edi,(%esp)
  802258:	e8 67 ef ff ff       	call   8011c4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80225d:	01 f3                	add    %esi,%ebx
  80225f:	89 d8                	mov    %ebx,%eax
  802261:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802264:	72 c9                	jb     80222f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802266:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80226c:	5b                   	pop    %ebx
  80226d:	5e                   	pop    %esi
  80226e:	5f                   	pop    %edi
  80226f:	5d                   	pop    %ebp
  802270:	c3                   	ret    

00802271 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802277:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80227b:	75 07                	jne    802284 <devcons_read+0x13>
  80227d:	eb 25                	jmp    8022a4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80227f:	e8 ee ef ff ff       	call   801272 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802284:	e8 59 ef ff ff       	call   8011e2 <sys_cgetc>
  802289:	85 c0                	test   %eax,%eax
  80228b:	74 f2                	je     80227f <devcons_read+0xe>
  80228d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80228f:	85 c0                	test   %eax,%eax
  802291:	78 1d                	js     8022b0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802293:	83 f8 04             	cmp    $0x4,%eax
  802296:	74 13                	je     8022ab <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80229b:	88 10                	mov    %dl,(%eax)
	return 1;
  80229d:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a2:	eb 0c                	jmp    8022b0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8022a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a9:	eb 05                	jmp    8022b0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022ab:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022b0:	c9                   	leave  
  8022b1:	c3                   	ret    

008022b2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8022b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8022c5:	00 
  8022c6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022c9:	89 04 24             	mov    %eax,(%esp)
  8022cc:	e8 f3 ee ff ff       	call   8011c4 <sys_cputs>
}
  8022d1:	c9                   	leave  
  8022d2:	c3                   	ret    

008022d3 <getchar>:

int
getchar(void)
{
  8022d3:	55                   	push   %ebp
  8022d4:	89 e5                	mov    %esp,%ebp
  8022d6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022d9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8022e0:	00 
  8022e1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022ef:	e8 3a f6 ff ff       	call   80192e <read>
	if (r < 0)
  8022f4:	85 c0                	test   %eax,%eax
  8022f6:	78 0f                	js     802307 <getchar+0x34>
		return r;
	if (r < 1)
  8022f8:	85 c0                	test   %eax,%eax
  8022fa:	7e 06                	jle    802302 <getchar+0x2f>
		return -E_EOF;
	return c;
  8022fc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802300:	eb 05                	jmp    802307 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802302:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802307:	c9                   	leave  
  802308:	c3                   	ret    

00802309 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802309:	55                   	push   %ebp
  80230a:	89 e5                	mov    %esp,%ebp
  80230c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80230f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802312:	89 44 24 04          	mov    %eax,0x4(%esp)
  802316:	8b 45 08             	mov    0x8(%ebp),%eax
  802319:	89 04 24             	mov    %eax,(%esp)
  80231c:	e8 71 f3 ff ff       	call   801692 <fd_lookup>
  802321:	85 c0                	test   %eax,%eax
  802323:	78 11                	js     802336 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802325:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802328:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80232e:	39 10                	cmp    %edx,(%eax)
  802330:	0f 94 c0             	sete   %al
  802333:	0f b6 c0             	movzbl %al,%eax
}
  802336:	c9                   	leave  
  802337:	c3                   	ret    

00802338 <opencons>:

int
opencons(void)
{
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80233e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802341:	89 04 24             	mov    %eax,(%esp)
  802344:	e8 f6 f2 ff ff       	call   80163f <fd_alloc>
  802349:	85 c0                	test   %eax,%eax
  80234b:	78 3c                	js     802389 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80234d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802354:	00 
  802355:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802358:	89 44 24 04          	mov    %eax,0x4(%esp)
  80235c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802363:	e8 29 ef ff ff       	call   801291 <sys_page_alloc>
  802368:	85 c0                	test   %eax,%eax
  80236a:	78 1d                	js     802389 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80236c:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802372:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802375:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802377:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802381:	89 04 24             	mov    %eax,(%esp)
  802384:	e8 8b f2 ff ff       	call   801614 <fd2num>
}
  802389:	c9                   	leave  
  80238a:	c3                   	ret    
	...

0080238c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80238c:	55                   	push   %ebp
  80238d:	89 e5                	mov    %esp,%ebp
  80238f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802392:	89 c2                	mov    %eax,%edx
  802394:	c1 ea 16             	shr    $0x16,%edx
  802397:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80239e:	f6 c2 01             	test   $0x1,%dl
  8023a1:	74 1e                	je     8023c1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023a3:	c1 e8 0c             	shr    $0xc,%eax
  8023a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023ad:	a8 01                	test   $0x1,%al
  8023af:	74 17                	je     8023c8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023b1:	c1 e8 0c             	shr    $0xc,%eax
  8023b4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8023bb:	ef 
  8023bc:	0f b7 c0             	movzwl %ax,%eax
  8023bf:	eb 0c                	jmp    8023cd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8023c6:	eb 05                	jmp    8023cd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023c8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023cd:	5d                   	pop    %ebp
  8023ce:	c3                   	ret    
	...

008023d0 <__udivdi3>:
  8023d0:	55                   	push   %ebp
  8023d1:	57                   	push   %edi
  8023d2:	56                   	push   %esi
  8023d3:	83 ec 10             	sub    $0x10,%esp
  8023d6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8023da:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8023de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8023e6:	89 cd                	mov    %ecx,%ebp
  8023e8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8023ec:	85 c0                	test   %eax,%eax
  8023ee:	75 2c                	jne    80241c <__udivdi3+0x4c>
  8023f0:	39 f9                	cmp    %edi,%ecx
  8023f2:	77 68                	ja     80245c <__udivdi3+0x8c>
  8023f4:	85 c9                	test   %ecx,%ecx
  8023f6:	75 0b                	jne    802403 <__udivdi3+0x33>
  8023f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8023fd:	31 d2                	xor    %edx,%edx
  8023ff:	f7 f1                	div    %ecx
  802401:	89 c1                	mov    %eax,%ecx
  802403:	31 d2                	xor    %edx,%edx
  802405:	89 f8                	mov    %edi,%eax
  802407:	f7 f1                	div    %ecx
  802409:	89 c7                	mov    %eax,%edi
  80240b:	89 f0                	mov    %esi,%eax
  80240d:	f7 f1                	div    %ecx
  80240f:	89 c6                	mov    %eax,%esi
  802411:	89 f0                	mov    %esi,%eax
  802413:	89 fa                	mov    %edi,%edx
  802415:	83 c4 10             	add    $0x10,%esp
  802418:	5e                   	pop    %esi
  802419:	5f                   	pop    %edi
  80241a:	5d                   	pop    %ebp
  80241b:	c3                   	ret    
  80241c:	39 f8                	cmp    %edi,%eax
  80241e:	77 2c                	ja     80244c <__udivdi3+0x7c>
  802420:	0f bd f0             	bsr    %eax,%esi
  802423:	83 f6 1f             	xor    $0x1f,%esi
  802426:	75 4c                	jne    802474 <__udivdi3+0xa4>
  802428:	39 f8                	cmp    %edi,%eax
  80242a:	bf 00 00 00 00       	mov    $0x0,%edi
  80242f:	72 0a                	jb     80243b <__udivdi3+0x6b>
  802431:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802435:	0f 87 ad 00 00 00    	ja     8024e8 <__udivdi3+0x118>
  80243b:	be 01 00 00 00       	mov    $0x1,%esi
  802440:	89 f0                	mov    %esi,%eax
  802442:	89 fa                	mov    %edi,%edx
  802444:	83 c4 10             	add    $0x10,%esp
  802447:	5e                   	pop    %esi
  802448:	5f                   	pop    %edi
  802449:	5d                   	pop    %ebp
  80244a:	c3                   	ret    
  80244b:	90                   	nop
  80244c:	31 ff                	xor    %edi,%edi
  80244e:	31 f6                	xor    %esi,%esi
  802450:	89 f0                	mov    %esi,%eax
  802452:	89 fa                	mov    %edi,%edx
  802454:	83 c4 10             	add    $0x10,%esp
  802457:	5e                   	pop    %esi
  802458:	5f                   	pop    %edi
  802459:	5d                   	pop    %ebp
  80245a:	c3                   	ret    
  80245b:	90                   	nop
  80245c:	89 fa                	mov    %edi,%edx
  80245e:	89 f0                	mov    %esi,%eax
  802460:	f7 f1                	div    %ecx
  802462:	89 c6                	mov    %eax,%esi
  802464:	31 ff                	xor    %edi,%edi
  802466:	89 f0                	mov    %esi,%eax
  802468:	89 fa                	mov    %edi,%edx
  80246a:	83 c4 10             	add    $0x10,%esp
  80246d:	5e                   	pop    %esi
  80246e:	5f                   	pop    %edi
  80246f:	5d                   	pop    %ebp
  802470:	c3                   	ret    
  802471:	8d 76 00             	lea    0x0(%esi),%esi
  802474:	89 f1                	mov    %esi,%ecx
  802476:	d3 e0                	shl    %cl,%eax
  802478:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80247c:	b8 20 00 00 00       	mov    $0x20,%eax
  802481:	29 f0                	sub    %esi,%eax
  802483:	89 ea                	mov    %ebp,%edx
  802485:	88 c1                	mov    %al,%cl
  802487:	d3 ea                	shr    %cl,%edx
  802489:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80248d:	09 ca                	or     %ecx,%edx
  80248f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802493:	89 f1                	mov    %esi,%ecx
  802495:	d3 e5                	shl    %cl,%ebp
  802497:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80249b:	89 fd                	mov    %edi,%ebp
  80249d:	88 c1                	mov    %al,%cl
  80249f:	d3 ed                	shr    %cl,%ebp
  8024a1:	89 fa                	mov    %edi,%edx
  8024a3:	89 f1                	mov    %esi,%ecx
  8024a5:	d3 e2                	shl    %cl,%edx
  8024a7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024ab:	88 c1                	mov    %al,%cl
  8024ad:	d3 ef                	shr    %cl,%edi
  8024af:	09 d7                	or     %edx,%edi
  8024b1:	89 f8                	mov    %edi,%eax
  8024b3:	89 ea                	mov    %ebp,%edx
  8024b5:	f7 74 24 08          	divl   0x8(%esp)
  8024b9:	89 d1                	mov    %edx,%ecx
  8024bb:	89 c7                	mov    %eax,%edi
  8024bd:	f7 64 24 0c          	mull   0xc(%esp)
  8024c1:	39 d1                	cmp    %edx,%ecx
  8024c3:	72 17                	jb     8024dc <__udivdi3+0x10c>
  8024c5:	74 09                	je     8024d0 <__udivdi3+0x100>
  8024c7:	89 fe                	mov    %edi,%esi
  8024c9:	31 ff                	xor    %edi,%edi
  8024cb:	e9 41 ff ff ff       	jmp    802411 <__udivdi3+0x41>
  8024d0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024d4:	89 f1                	mov    %esi,%ecx
  8024d6:	d3 e2                	shl    %cl,%edx
  8024d8:	39 c2                	cmp    %eax,%edx
  8024da:	73 eb                	jae    8024c7 <__udivdi3+0xf7>
  8024dc:	8d 77 ff             	lea    -0x1(%edi),%esi
  8024df:	31 ff                	xor    %edi,%edi
  8024e1:	e9 2b ff ff ff       	jmp    802411 <__udivdi3+0x41>
  8024e6:	66 90                	xchg   %ax,%ax
  8024e8:	31 f6                	xor    %esi,%esi
  8024ea:	e9 22 ff ff ff       	jmp    802411 <__udivdi3+0x41>
	...

008024f0 <__umoddi3>:
  8024f0:	55                   	push   %ebp
  8024f1:	57                   	push   %edi
  8024f2:	56                   	push   %esi
  8024f3:	83 ec 20             	sub    $0x20,%esp
  8024f6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024fa:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8024fe:	89 44 24 14          	mov    %eax,0x14(%esp)
  802502:	8b 74 24 34          	mov    0x34(%esp),%esi
  802506:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80250a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80250e:	89 c7                	mov    %eax,%edi
  802510:	89 f2                	mov    %esi,%edx
  802512:	85 ed                	test   %ebp,%ebp
  802514:	75 16                	jne    80252c <__umoddi3+0x3c>
  802516:	39 f1                	cmp    %esi,%ecx
  802518:	0f 86 a6 00 00 00    	jbe    8025c4 <__umoddi3+0xd4>
  80251e:	f7 f1                	div    %ecx
  802520:	89 d0                	mov    %edx,%eax
  802522:	31 d2                	xor    %edx,%edx
  802524:	83 c4 20             	add    $0x20,%esp
  802527:	5e                   	pop    %esi
  802528:	5f                   	pop    %edi
  802529:	5d                   	pop    %ebp
  80252a:	c3                   	ret    
  80252b:	90                   	nop
  80252c:	39 f5                	cmp    %esi,%ebp
  80252e:	0f 87 ac 00 00 00    	ja     8025e0 <__umoddi3+0xf0>
  802534:	0f bd c5             	bsr    %ebp,%eax
  802537:	83 f0 1f             	xor    $0x1f,%eax
  80253a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80253e:	0f 84 a8 00 00 00    	je     8025ec <__umoddi3+0xfc>
  802544:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802548:	d3 e5                	shl    %cl,%ebp
  80254a:	bf 20 00 00 00       	mov    $0x20,%edi
  80254f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802553:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802557:	89 f9                	mov    %edi,%ecx
  802559:	d3 e8                	shr    %cl,%eax
  80255b:	09 e8                	or     %ebp,%eax
  80255d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802561:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802565:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802569:	d3 e0                	shl    %cl,%eax
  80256b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80256f:	89 f2                	mov    %esi,%edx
  802571:	d3 e2                	shl    %cl,%edx
  802573:	8b 44 24 14          	mov    0x14(%esp),%eax
  802577:	d3 e0                	shl    %cl,%eax
  802579:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80257d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802581:	89 f9                	mov    %edi,%ecx
  802583:	d3 e8                	shr    %cl,%eax
  802585:	09 d0                	or     %edx,%eax
  802587:	d3 ee                	shr    %cl,%esi
  802589:	89 f2                	mov    %esi,%edx
  80258b:	f7 74 24 18          	divl   0x18(%esp)
  80258f:	89 d6                	mov    %edx,%esi
  802591:	f7 64 24 0c          	mull   0xc(%esp)
  802595:	89 c5                	mov    %eax,%ebp
  802597:	89 d1                	mov    %edx,%ecx
  802599:	39 d6                	cmp    %edx,%esi
  80259b:	72 67                	jb     802604 <__umoddi3+0x114>
  80259d:	74 75                	je     802614 <__umoddi3+0x124>
  80259f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8025a3:	29 e8                	sub    %ebp,%eax
  8025a5:	19 ce                	sbb    %ecx,%esi
  8025a7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025ab:	d3 e8                	shr    %cl,%eax
  8025ad:	89 f2                	mov    %esi,%edx
  8025af:	89 f9                	mov    %edi,%ecx
  8025b1:	d3 e2                	shl    %cl,%edx
  8025b3:	09 d0                	or     %edx,%eax
  8025b5:	89 f2                	mov    %esi,%edx
  8025b7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025bb:	d3 ea                	shr    %cl,%edx
  8025bd:	83 c4 20             	add    $0x20,%esp
  8025c0:	5e                   	pop    %esi
  8025c1:	5f                   	pop    %edi
  8025c2:	5d                   	pop    %ebp
  8025c3:	c3                   	ret    
  8025c4:	85 c9                	test   %ecx,%ecx
  8025c6:	75 0b                	jne    8025d3 <__umoddi3+0xe3>
  8025c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8025cd:	31 d2                	xor    %edx,%edx
  8025cf:	f7 f1                	div    %ecx
  8025d1:	89 c1                	mov    %eax,%ecx
  8025d3:	89 f0                	mov    %esi,%eax
  8025d5:	31 d2                	xor    %edx,%edx
  8025d7:	f7 f1                	div    %ecx
  8025d9:	89 f8                	mov    %edi,%eax
  8025db:	e9 3e ff ff ff       	jmp    80251e <__umoddi3+0x2e>
  8025e0:	89 f2                	mov    %esi,%edx
  8025e2:	83 c4 20             	add    $0x20,%esp
  8025e5:	5e                   	pop    %esi
  8025e6:	5f                   	pop    %edi
  8025e7:	5d                   	pop    %ebp
  8025e8:	c3                   	ret    
  8025e9:	8d 76 00             	lea    0x0(%esi),%esi
  8025ec:	39 f5                	cmp    %esi,%ebp
  8025ee:	72 04                	jb     8025f4 <__umoddi3+0x104>
  8025f0:	39 f9                	cmp    %edi,%ecx
  8025f2:	77 06                	ja     8025fa <__umoddi3+0x10a>
  8025f4:	89 f2                	mov    %esi,%edx
  8025f6:	29 cf                	sub    %ecx,%edi
  8025f8:	19 ea                	sbb    %ebp,%edx
  8025fa:	89 f8                	mov    %edi,%eax
  8025fc:	83 c4 20             	add    $0x20,%esp
  8025ff:	5e                   	pop    %esi
  802600:	5f                   	pop    %edi
  802601:	5d                   	pop    %ebp
  802602:	c3                   	ret    
  802603:	90                   	nop
  802604:	89 d1                	mov    %edx,%ecx
  802606:	89 c5                	mov    %eax,%ebp
  802608:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80260c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802610:	eb 8d                	jmp    80259f <__umoddi3+0xaf>
  802612:	66 90                	xchg   %ax,%ax
  802614:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802618:	72 ea                	jb     802604 <__umoddi3+0x114>
  80261a:	89 f1                	mov    %esi,%ecx
  80261c:	eb 81                	jmp    80259f <__umoddi3+0xaf>
