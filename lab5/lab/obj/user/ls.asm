
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 f7 02 00 00       	call   800328 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003e:	8a 45 0c             	mov    0xc(%ebp),%al
  800041:	88 45 f7             	mov    %al,-0x9(%ebp)
	const char *sep;

	if(flag['l'])
  800044:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  80004b:	74 21                	je     80006e <ls1+0x3a>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  80004d:	3c 01                	cmp    $0x1,%al
  80004f:	19 c0                	sbb    %eax,%eax
  800051:	83 e0 c9             	and    $0xffffffc9,%eax
  800054:	83 c0 64             	add    $0x64,%eax
  800057:	89 44 24 08          	mov    %eax,0x8(%esp)
  80005b:	8b 45 10             	mov    0x10(%ebp),%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 82 24 80 00 	movl   $0x802482,(%esp)
  800069:	e8 17 1b 00 00       	call   801b85 <printf>
	if(prefix) {
  80006e:	85 db                	test   %ebx,%ebx
  800070:	74 3b                	je     8000ad <ls1+0x79>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800072:	80 3b 00             	cmpb   $0x0,(%ebx)
  800075:	74 16                	je     80008d <ls1+0x59>
  800077:	89 1c 24             	mov    %ebx,(%esp)
  80007a:	e8 a9 09 00 00       	call   800a28 <strlen>
  80007f:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800084:	74 0e                	je     800094 <ls1+0x60>
			sep = "/";
  800086:	b8 80 24 80 00       	mov    $0x802480,%eax
  80008b:	eb 0c                	jmp    800099 <ls1+0x65>
		else
			sep = "";
  80008d:	b8 e8 24 80 00       	mov    $0x8024e8,%eax
  800092:	eb 05                	jmp    800099 <ls1+0x65>
  800094:	b8 e8 24 80 00       	mov    $0x8024e8,%eax
		printf("%s%s", prefix, sep);
  800099:	89 44 24 08          	mov    %eax,0x8(%esp)
  80009d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a1:	c7 04 24 8b 24 80 00 	movl   $0x80248b,(%esp)
  8000a8:	e8 d8 1a 00 00       	call   801b85 <printf>
	}
	printf("%s", name);
  8000ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8000b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b4:	c7 04 24 3e 29 80 00 	movl   $0x80293e,(%esp)
  8000bb:	e8 c5 1a 00 00       	call   801b85 <printf>
	if(flag['F'] && isdir)
  8000c0:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000c7:	74 12                	je     8000db <ls1+0xa7>
  8000c9:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  8000cd:	74 0c                	je     8000db <ls1+0xa7>
		printf("/");
  8000cf:	c7 04 24 80 24 80 00 	movl   $0x802480,(%esp)
  8000d6:	e8 aa 1a 00 00       	call   801b85 <printf>
	printf("\n");
  8000db:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  8000e2:	e8 9e 1a 00 00       	call   801b85 <printf>
}
  8000e7:	83 c4 24             	add    $0x24,%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  8000f9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800103:	00 
  800104:	8b 45 08             	mov    0x8(%ebp),%eax
  800107:	89 04 24             	mov    %eax,(%esp)
  80010a:	e8 c2 18 00 00       	call   8019d1 <open>
  80010f:	89 c6                	mov    %eax,%esi
  800111:	85 c0                	test   %eax,%eax
  800113:	79 59                	jns    80016e <lsdir+0x81>
		panic("open %s: %e", path, fd);
  800115:	89 44 24 10          	mov    %eax,0x10(%esp)
  800119:	8b 45 08             	mov    0x8(%ebp),%eax
  80011c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800120:	c7 44 24 08 90 24 80 	movl   $0x802490,0x8(%esp)
  800127:	00 
  800128:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  80012f:	00 
  800130:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  800137:	e8 5c 02 00 00       	call   800398 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  80013c:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  800143:	74 2f                	je     800174 <lsdir+0x87>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800145:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800149:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  80014f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800153:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80015a:	0f 94 c0             	sete   %al
  80015d:	0f b6 c0             	movzbl %al,%eax
  800160:	89 44 24 04          	mov    %eax,0x4(%esp)
  800164:	89 3c 24             	mov    %edi,(%esp)
  800167:	e8 c8 fe ff ff       	call   800034 <ls1>
  80016c:	eb 06                	jmp    800174 <lsdir+0x87>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80016e:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
  800174:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  80017b:	00 
  80017c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800180:	89 34 24             	mov    %esi,(%esp)
  800183:	e8 32 14 00 00       	call   8015ba <readn>
  800188:	3d 00 01 00 00       	cmp    $0x100,%eax
  80018d:	74 ad                	je     80013c <lsdir+0x4f>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80018f:	85 c0                	test   %eax,%eax
  800191:	7e 23                	jle    8001b6 <lsdir+0xc9>
		panic("short read in directory %s", path);
  800193:	8b 45 08             	mov    0x8(%ebp),%eax
  800196:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019a:	c7 44 24 08 a6 24 80 	movl   $0x8024a6,0x8(%esp)
  8001a1:	00 
  8001a2:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8001a9:	00 
  8001aa:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  8001b1:	e8 e2 01 00 00       	call   800398 <_panic>
	if (n < 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	79 27                	jns    8001e1 <lsdir+0xf4>
		panic("error reading directory %s: %e", path, n);
  8001ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c5:	c7 44 24 08 ec 24 80 	movl   $0x8024ec,0x8(%esp)
  8001cc:	00 
  8001cd:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8001d4:	00 
  8001d5:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  8001dc:	e8 b7 01 00 00       	call   800398 <_panic>
}
  8001e1:	81 c4 2c 01 00 00    	add    $0x12c,%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5e                   	pop    %esi
  8001e9:	5f                   	pop    %edi
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	53                   	push   %ebx
  8001f0:	81 ec b4 00 00 00    	sub    $0xb4,%esp
  8001f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001f9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800203:	89 1c 24             	mov    %ebx,(%esp)
  800206:	e8 ad 15 00 00       	call   8017b8 <stat>
  80020b:	85 c0                	test   %eax,%eax
  80020d:	79 24                	jns    800233 <ls+0x47>
		panic("stat %s: %e", path, r);
  80020f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800213:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800217:	c7 44 24 08 c1 24 80 	movl   $0x8024c1,0x8(%esp)
  80021e:	00 
  80021f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800226:	00 
  800227:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  80022e:	e8 65 01 00 00       	call   800398 <_panic>
	if (st.st_isdir && !flag['d'])
  800233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800236:	85 c0                	test   %eax,%eax
  800238:	74 1a                	je     800254 <ls+0x68>
  80023a:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  800241:	75 11                	jne    800254 <ls+0x68>
		lsdir(path, prefix);
  800243:	8b 45 0c             	mov    0xc(%ebp),%eax
  800246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024a:	89 1c 24             	mov    %ebx,(%esp)
  80024d:	e8 9b fe ff ff       	call   8000ed <lsdir>
  800252:	eb 23                	jmp    800277 <ls+0x8b>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  800254:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800258:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80025b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80025f:	85 c0                	test   %eax,%eax
  800261:	0f 95 c0             	setne  %al
  800264:	0f b6 c0             	movzbl %al,%eax
  800267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800272:	e8 bd fd ff ff       	call   800034 <ls1>
}
  800277:	81 c4 b4 00 00 00    	add    $0xb4,%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <usage>:
	printf("\n");
}

void
usage(void)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 18             	sub    $0x18,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800286:	c7 04 24 cd 24 80 00 	movl   $0x8024cd,(%esp)
  80028d:	e8 f3 18 00 00       	call   801b85 <printf>
	exit();
  800292:	e8 e5 00 00 00       	call   80037c <exit>
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <umain>:

void
umain(int argc, char **argv)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 20             	sub    $0x20,%esp
  8002a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  8002a4:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002af:	8d 45 08             	lea    0x8(%ebp),%eax
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	e8 fe 0d 00 00       	call   8010b8 <argstart>
	while ((i = argnext(&args)) >= 0)
  8002ba:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  8002bd:	eb 1d                	jmp    8002dc <umain+0x43>
		switch (i) {
  8002bf:	83 f8 64             	cmp    $0x64,%eax
  8002c2:	74 0a                	je     8002ce <umain+0x35>
  8002c4:	83 f8 6c             	cmp    $0x6c,%eax
  8002c7:	74 05                	je     8002ce <umain+0x35>
  8002c9:	83 f8 46             	cmp    $0x46,%eax
  8002cc:	75 09                	jne    8002d7 <umain+0x3e>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  8002ce:	ff 04 85 20 40 80 00 	incl   0x804020(,%eax,4)
			break;
  8002d5:	eb 05                	jmp    8002dc <umain+0x43>
		default:
			usage();
  8002d7:	e8 a4 ff ff ff       	call   800280 <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  8002dc:	89 1c 24             	mov    %ebx,(%esp)
  8002df:	e8 0d 0e 00 00       	call   8010f1 <argnext>
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	79 d7                	jns    8002bf <umain+0x26>
			break;
		default:
			usage();
		}

	if (argc == 1)
  8002e8:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8002ec:	75 28                	jne    800316 <umain+0x7d>
		ls("/", "");
  8002ee:	c7 44 24 04 e8 24 80 	movl   $0x8024e8,0x4(%esp)
  8002f5:	00 
  8002f6:	c7 04 24 80 24 80 00 	movl   $0x802480,(%esp)
  8002fd:	e8 ea fe ff ff       	call   8001ec <ls>
  800302:	eb 1c                	jmp    800320 <umain+0x87>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  800304:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030b:	89 04 24             	mov    %eax,(%esp)
  80030e:	e8 d9 fe ff ff       	call   8001ec <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  800313:	43                   	inc    %ebx
  800314:	eb 05                	jmp    80031b <umain+0x82>
			break;
		default:
			usage();
		}

	if (argc == 1)
  800316:	bb 01 00 00 00       	mov    $0x1,%ebx
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  80031b:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80031e:	7c e4                	jl     800304 <umain+0x6b>
			ls(argv[i], argv[i]);
	}
}
  800320:	83 c4 20             	add    $0x20,%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    
	...

00800328 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
  80032d:	83 ec 10             	sub    $0x10,%esp
  800330:	8b 75 08             	mov    0x8(%ebp),%esi
  800333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800336:	e8 d4 0a 00 00       	call   800e0f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80033b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800340:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800347:	c1 e0 07             	shl    $0x7,%eax
  80034a:	29 d0                	sub    %edx,%eax
  80034c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800351:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800356:	85 f6                	test   %esi,%esi
  800358:	7e 07                	jle    800361 <libmain+0x39>
		binaryname = argv[0];
  80035a:	8b 03                	mov    (%ebx),%eax
  80035c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800361:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800365:	89 34 24             	mov    %esi,(%esp)
  800368:	e8 2c ff ff ff       	call   800299 <umain>

	// exit gracefully
	exit();
  80036d:	e8 0a 00 00 00       	call   80037c <exit>
}
  800372:	83 c4 10             	add    $0x10,%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    
  800379:	00 00                	add    %al,(%eax)
	...

0080037c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800382:	e8 70 10 00 00       	call   8013f7 <close_all>
	sys_env_destroy(0);
  800387:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80038e:	e8 2a 0a 00 00       	call   800dbd <sys_env_destroy>
}
  800393:	c9                   	leave  
  800394:	c3                   	ret    
  800395:	00 00                	add    %al,(%eax)
	...

00800398 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8003a9:	e8 61 0a 00 00       	call   800e0f <sys_getenvid>
  8003ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c4:	c7 04 24 18 25 80 00 	movl   $0x802518,(%esp)
  8003cb:	e8 c0 00 00 00       	call   800490 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	e8 50 00 00 00       	call   80042f <vcprintf>
	cprintf("\n");
  8003df:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  8003e6:	e8 a5 00 00 00       	call   800490 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003eb:	cc                   	int3   
  8003ec:	eb fd                	jmp    8003eb <_panic+0x53>
	...

008003f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 14             	sub    $0x14,%esp
  8003f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003fa:	8b 03                	mov    (%ebx),%eax
  8003fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800403:	40                   	inc    %eax
  800404:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800406:	3d ff 00 00 00       	cmp    $0xff,%eax
  80040b:	75 19                	jne    800426 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80040d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800414:	00 
  800415:	8d 43 08             	lea    0x8(%ebx),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	e8 60 09 00 00       	call   800d80 <sys_cputs>
		b->idx = 0;
  800420:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800426:	ff 43 04             	incl   0x4(%ebx)
}
  800429:	83 c4 14             	add    $0x14,%esp
  80042c:	5b                   	pop    %ebx
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800438:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80043f:	00 00 00 
	b.cnt = 0;
  800442:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800449:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80044c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800453:	8b 45 08             	mov    0x8(%ebp),%eax
  800456:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800460:	89 44 24 04          	mov    %eax,0x4(%esp)
  800464:	c7 04 24 f0 03 80 00 	movl   $0x8003f0,(%esp)
  80046b:	e8 82 01 00 00       	call   8005f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800470:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800476:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 f8 08 00 00       	call   800d80 <sys_cputs>

	return b.cnt;
}
  800488:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80048e:	c9                   	leave  
  80048f:	c3                   	ret    

00800490 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800496:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 87 ff ff ff       	call   80042f <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    
	...

008004ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	57                   	push   %edi
  8004b0:	56                   	push   %esi
  8004b1:	53                   	push   %ebx
  8004b2:	83 ec 3c             	sub    $0x3c,%esp
  8004b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b8:	89 d7                	mov    %edx,%edi
  8004ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	75 08                	jne    8004d8 <printnum+0x2c>
  8004d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004d6:	77 57                	ja     80052f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004dc:	4b                   	dec    %ebx
  8004dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004ec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004f7:	00 
  8004f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	89 44 24 04          	mov    %eax,0x4(%esp)
  800505:	e8 12 1d 00 00       	call   80221c <__udivdi3>
  80050a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80050e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800512:	89 04 24             	mov    %eax,(%esp)
  800515:	89 54 24 04          	mov    %edx,0x4(%esp)
  800519:	89 fa                	mov    %edi,%edx
  80051b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051e:	e8 89 ff ff ff       	call   8004ac <printnum>
  800523:	eb 0f                	jmp    800534 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800525:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800529:	89 34 24             	mov    %esi,(%esp)
  80052c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80052f:	4b                   	dec    %ebx
  800530:	85 db                	test   %ebx,%ebx
  800532:	7f f1                	jg     800525 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800534:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800538:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80053c:	8b 45 10             	mov    0x10(%ebp),%eax
  80053f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800543:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054a:	00 
  80054b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800554:	89 44 24 04          	mov    %eax,0x4(%esp)
  800558:	e8 df 1d 00 00       	call   80233c <__umoddi3>
  80055d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800561:	0f be 80 3b 25 80 00 	movsbl 0x80253b(%eax),%eax
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80056e:	83 c4 3c             	add    $0x3c,%esp
  800571:	5b                   	pop    %ebx
  800572:	5e                   	pop    %esi
  800573:	5f                   	pop    %edi
  800574:	5d                   	pop    %ebp
  800575:	c3                   	ret    

00800576 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800576:	55                   	push   %ebp
  800577:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800579:	83 fa 01             	cmp    $0x1,%edx
  80057c:	7e 0e                	jle    80058c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80057e:	8b 10                	mov    (%eax),%edx
  800580:	8d 4a 08             	lea    0x8(%edx),%ecx
  800583:	89 08                	mov    %ecx,(%eax)
  800585:	8b 02                	mov    (%edx),%eax
  800587:	8b 52 04             	mov    0x4(%edx),%edx
  80058a:	eb 22                	jmp    8005ae <getuint+0x38>
	else if (lflag)
  80058c:	85 d2                	test   %edx,%edx
  80058e:	74 10                	je     8005a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8d 4a 04             	lea    0x4(%edx),%ecx
  800595:	89 08                	mov    %ecx,(%eax)
  800597:	8b 02                	mov    (%edx),%eax
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
  80059e:	eb 0e                	jmp    8005ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a0:	8b 10                	mov    (%eax),%edx
  8005a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005a5:	89 08                	mov    %ecx,(%eax)
  8005a7:	8b 02                	mov    (%edx),%eax
  8005a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005ae:	5d                   	pop    %ebp
  8005af:	c3                   	ret    

008005b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005b6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8005be:	73 08                	jae    8005c8 <sprintputch+0x18>
		*b->buf++ = ch;
  8005c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005c3:	88 0a                	mov    %cl,(%edx)
  8005c5:	42                   	inc    %edx
  8005c6:	89 10                	mov    %edx,(%eax)
}
  8005c8:	5d                   	pop    %ebp
  8005c9:	c3                   	ret    

008005ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ca:	55                   	push   %ebp
  8005cb:	89 e5                	mov    %esp,%ebp
  8005cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8005da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e8:	89 04 24             	mov    %eax,(%esp)
  8005eb:	e8 02 00 00 00       	call   8005f2 <vprintfmt>
	va_end(ap);
}
  8005f0:	c9                   	leave  
  8005f1:	c3                   	ret    

008005f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	57                   	push   %edi
  8005f6:	56                   	push   %esi
  8005f7:	53                   	push   %ebx
  8005f8:	83 ec 4c             	sub    $0x4c,%esp
  8005fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fe:	8b 75 10             	mov    0x10(%ebp),%esi
  800601:	eb 12                	jmp    800615 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800603:	85 c0                	test   %eax,%eax
  800605:	0f 84 8b 03 00 00    	je     800996 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80060b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800615:	0f b6 06             	movzbl (%esi),%eax
  800618:	46                   	inc    %esi
  800619:	83 f8 25             	cmp    $0x25,%eax
  80061c:	75 e5                	jne    800603 <vprintfmt+0x11>
  80061e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800622:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800629:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80062e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800635:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063a:	eb 26                	jmp    800662 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80063f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800643:	eb 1d                	jmp    800662 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800648:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80064c:	eb 14                	jmp    800662 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800651:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800658:	eb 08                	jmp    800662 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80065a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80065d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800662:	0f b6 06             	movzbl (%esi),%eax
  800665:	8d 56 01             	lea    0x1(%esi),%edx
  800668:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80066b:	8a 16                	mov    (%esi),%dl
  80066d:	83 ea 23             	sub    $0x23,%edx
  800670:	80 fa 55             	cmp    $0x55,%dl
  800673:	0f 87 01 03 00 00    	ja     80097a <vprintfmt+0x388>
  800679:	0f b6 d2             	movzbl %dl,%edx
  80067c:	ff 24 95 80 26 80 00 	jmp    *0x802680(,%edx,4)
  800683:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800686:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80068b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80068e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800692:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800695:	8d 50 d0             	lea    -0x30(%eax),%edx
  800698:	83 fa 09             	cmp    $0x9,%edx
  80069b:	77 2a                	ja     8006c7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80069d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80069e:	eb eb                	jmp    80068b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006ae:	eb 17                	jmp    8006c7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b4:	78 98                	js     80064e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b9:	eb a7                	jmp    800662 <vprintfmt+0x70>
  8006bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006be:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006c5:	eb 9b                	jmp    800662 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006cb:	79 95                	jns    800662 <vprintfmt+0x70>
  8006cd:	eb 8b                	jmp    80065a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006cf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006d3:	eb 8d                	jmp    800662 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 04             	lea    0x4(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006ed:	e9 23 ff ff ff       	jmp    800615 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 04             	lea    0x4(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	79 02                	jns    800703 <vprintfmt+0x111>
  800701:	f7 d8                	neg    %eax
  800703:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800705:	83 f8 0f             	cmp    $0xf,%eax
  800708:	7f 0b                	jg     800715 <vprintfmt+0x123>
  80070a:	8b 04 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%eax
  800711:	85 c0                	test   %eax,%eax
  800713:	75 23                	jne    800738 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800715:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800719:	c7 44 24 08 53 25 80 	movl   $0x802553,0x8(%esp)
  800720:	00 
  800721:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	e8 9a fe ff ff       	call   8005ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800730:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800733:	e9 dd fe ff ff       	jmp    800615 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800738:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073c:	c7 44 24 08 3e 29 80 	movl   $0x80293e,0x8(%esp)
  800743:	00 
  800744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800748:	8b 55 08             	mov    0x8(%ebp),%edx
  80074b:	89 14 24             	mov    %edx,(%esp)
  80074e:	e8 77 fe ff ff       	call   8005ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800753:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800756:	e9 ba fe ff ff       	jmp    800615 <vprintfmt+0x23>
  80075b:	89 f9                	mov    %edi,%ecx
  80075d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800760:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 30                	mov    (%eax),%esi
  80076e:	85 f6                	test   %esi,%esi
  800770:	75 05                	jne    800777 <vprintfmt+0x185>
				p = "(null)";
  800772:	be 4c 25 80 00       	mov    $0x80254c,%esi
			if (width > 0 && padc != '-')
  800777:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80077b:	0f 8e 84 00 00 00    	jle    800805 <vprintfmt+0x213>
  800781:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800785:	74 7e                	je     800805 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800787:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80078b:	89 34 24             	mov    %esi,(%esp)
  80078e:	e8 ab 02 00 00       	call   800a3e <strnlen>
  800793:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800796:	29 c2                	sub    %eax,%edx
  800798:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80079b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80079f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007a2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007a5:	89 de                	mov    %ebx,%esi
  8007a7:	89 d3                	mov    %edx,%ebx
  8007a9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ab:	eb 0b                	jmp    8007b8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b1:	89 3c 24             	mov    %edi,(%esp)
  8007b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b7:	4b                   	dec    %ebx
  8007b8:	85 db                	test   %ebx,%ebx
  8007ba:	7f f1                	jg     8007ad <vprintfmt+0x1bb>
  8007bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007bf:	89 f3                	mov    %esi,%ebx
  8007c1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	79 05                	jns    8007d0 <vprintfmt+0x1de>
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d3:	29 c2                	sub    %eax,%edx
  8007d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007d8:	eb 2b                	jmp    800805 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007de:	74 18                	je     8007f8 <vprintfmt+0x206>
  8007e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007e3:	83 fa 5e             	cmp    $0x5e,%edx
  8007e6:	76 10                	jbe    8007f8 <vprintfmt+0x206>
					putch('?', putdat);
  8007e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
  8007f6:	eb 0a                	jmp    800802 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fc:	89 04 24             	mov    %eax,(%esp)
  8007ff:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800802:	ff 4d e4             	decl   -0x1c(%ebp)
  800805:	0f be 06             	movsbl (%esi),%eax
  800808:	46                   	inc    %esi
  800809:	85 c0                	test   %eax,%eax
  80080b:	74 21                	je     80082e <vprintfmt+0x23c>
  80080d:	85 ff                	test   %edi,%edi
  80080f:	78 c9                	js     8007da <vprintfmt+0x1e8>
  800811:	4f                   	dec    %edi
  800812:	79 c6                	jns    8007da <vprintfmt+0x1e8>
  800814:	8b 7d 08             	mov    0x8(%ebp),%edi
  800817:	89 de                	mov    %ebx,%esi
  800819:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80081c:	eb 18                	jmp    800836 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80081e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800822:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800829:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80082b:	4b                   	dec    %ebx
  80082c:	eb 08                	jmp    800836 <vprintfmt+0x244>
  80082e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800831:	89 de                	mov    %ebx,%esi
  800833:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800836:	85 db                	test   %ebx,%ebx
  800838:	7f e4                	jg     80081e <vprintfmt+0x22c>
  80083a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80083d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800842:	e9 ce fd ff ff       	jmp    800615 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800847:	83 f9 01             	cmp    $0x1,%ecx
  80084a:	7e 10                	jle    80085c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8d 50 08             	lea    0x8(%eax),%edx
  800852:	89 55 14             	mov    %edx,0x14(%ebp)
  800855:	8b 30                	mov    (%eax),%esi
  800857:	8b 78 04             	mov    0x4(%eax),%edi
  80085a:	eb 26                	jmp    800882 <vprintfmt+0x290>
	else if (lflag)
  80085c:	85 c9                	test   %ecx,%ecx
  80085e:	74 12                	je     800872 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800860:	8b 45 14             	mov    0x14(%ebp),%eax
  800863:	8d 50 04             	lea    0x4(%eax),%edx
  800866:	89 55 14             	mov    %edx,0x14(%ebp)
  800869:	8b 30                	mov    (%eax),%esi
  80086b:	89 f7                	mov    %esi,%edi
  80086d:	c1 ff 1f             	sar    $0x1f,%edi
  800870:	eb 10                	jmp    800882 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8d 50 04             	lea    0x4(%eax),%edx
  800878:	89 55 14             	mov    %edx,0x14(%ebp)
  80087b:	8b 30                	mov    (%eax),%esi
  80087d:	89 f7                	mov    %esi,%edi
  80087f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800882:	85 ff                	test   %edi,%edi
  800884:	78 0a                	js     800890 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800886:	b8 0a 00 00 00       	mov    $0xa,%eax
  80088b:	e9 ac 00 00 00       	jmp    80093c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800890:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800894:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80089b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80089e:	f7 de                	neg    %esi
  8008a0:	83 d7 00             	adc    $0x0,%edi
  8008a3:	f7 df                	neg    %edi
			}
			base = 10;
  8008a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008aa:	e9 8d 00 00 00       	jmp    80093c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008af:	89 ca                	mov    %ecx,%edx
  8008b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b4:	e8 bd fc ff ff       	call   800576 <getuint>
  8008b9:	89 c6                	mov    %eax,%esi
  8008bb:	89 d7                	mov    %edx,%edi
			base = 10;
  8008bd:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008c2:	eb 78                	jmp    80093c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008cf:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d6:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008dd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008eb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008f1:	e9 1f fd ff ff       	jmp    800615 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8008f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008fa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800901:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800904:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800908:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80090f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800912:	8b 45 14             	mov    0x14(%ebp),%eax
  800915:	8d 50 04             	lea    0x4(%eax),%edx
  800918:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80091b:	8b 30                	mov    (%eax),%esi
  80091d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800922:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800927:	eb 13                	jmp    80093c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800929:	89 ca                	mov    %ecx,%edx
  80092b:	8d 45 14             	lea    0x14(%ebp),%eax
  80092e:	e8 43 fc ff ff       	call   800576 <getuint>
  800933:	89 c6                	mov    %eax,%esi
  800935:	89 d7                	mov    %edx,%edi
			base = 16;
  800937:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80093c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800940:	89 54 24 10          	mov    %edx,0x10(%esp)
  800944:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800947:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80094b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094f:	89 34 24             	mov    %esi,(%esp)
  800952:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800956:	89 da                	mov    %ebx,%edx
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	e8 4c fb ff ff       	call   8004ac <printnum>
			break;
  800960:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800963:	e9 ad fc ff ff       	jmp    800615 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800968:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096c:	89 04 24             	mov    %eax,(%esp)
  80096f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800972:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800975:	e9 9b fc ff ff       	jmp    800615 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80097a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800985:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800988:	eb 01                	jmp    80098b <vprintfmt+0x399>
  80098a:	4e                   	dec    %esi
  80098b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80098f:	75 f9                	jne    80098a <vprintfmt+0x398>
  800991:	e9 7f fc ff ff       	jmp    800615 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800996:	83 c4 4c             	add    $0x4c,%esp
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	5f                   	pop    %edi
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	83 ec 28             	sub    $0x28,%esp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009bb:	85 c0                	test   %eax,%eax
  8009bd:	74 30                	je     8009ef <vsnprintf+0x51>
  8009bf:	85 d2                	test   %edx,%edx
  8009c1:	7e 33                	jle    8009f6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8009cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d8:	c7 04 24 b0 05 80 00 	movl   $0x8005b0,(%esp)
  8009df:	e8 0e fc ff ff       	call   8005f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ed:	eb 0c                	jmp    8009fb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009f4:	eb 05                	jmp    8009fb <vsnprintf+0x5d>
  8009f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a03:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a0a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	89 04 24             	mov    %eax,(%esp)
  800a1e:	e8 7b ff ff ff       	call   80099e <vsnprintf>
	va_end(ap);

	return rc;
}
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    
  800a25:	00 00                	add    %al,(%eax)
	...

00800a28 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a33:	eb 01                	jmp    800a36 <strlen+0xe>
		n++;
  800a35:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a36:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a3a:	75 f9                	jne    800a35 <strlen+0xd>
		n++;
	return n;
}
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a44:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4c:	eb 01                	jmp    800a4f <strnlen+0x11>
		n++;
  800a4e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	39 d0                	cmp    %edx,%eax
  800a51:	74 06                	je     800a59 <strnlen+0x1b>
  800a53:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a57:	75 f5                	jne    800a4e <strnlen+0x10>
		n++;
	return n;
}
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a65:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a6d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a70:	42                   	inc    %edx
  800a71:	84 c9                	test   %cl,%cl
  800a73:	75 f5                	jne    800a6a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a75:	5b                   	pop    %ebx
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	53                   	push   %ebx
  800a7c:	83 ec 08             	sub    $0x8,%esp
  800a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a82:	89 1c 24             	mov    %ebx,(%esp)
  800a85:	e8 9e ff ff ff       	call   800a28 <strlen>
	strcpy(dst + len, src);
  800a8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a91:	01 d8                	add    %ebx,%eax
  800a93:	89 04 24             	mov    %eax,(%esp)
  800a96:	e8 c0 ff ff ff       	call   800a5b <strcpy>
	return dst;
}
  800a9b:	89 d8                	mov    %ebx,%eax
  800a9d:	83 c4 08             	add    $0x8,%esp
  800aa0:	5b                   	pop    %ebx
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aae:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab6:	eb 0c                	jmp    800ac4 <strncpy+0x21>
		*dst++ = *src;
  800ab8:	8a 1a                	mov    (%edx),%bl
  800aba:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800abd:	80 3a 01             	cmpb   $0x1,(%edx)
  800ac0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac3:	41                   	inc    %ecx
  800ac4:	39 f1                	cmp    %esi,%ecx
  800ac6:	75 f0                	jne    800ab8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ada:	85 d2                	test   %edx,%edx
  800adc:	75 0a                	jne    800ae8 <strlcpy+0x1c>
  800ade:	89 f0                	mov    %esi,%eax
  800ae0:	eb 1a                	jmp    800afc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ae2:	88 18                	mov    %bl,(%eax)
  800ae4:	40                   	inc    %eax
  800ae5:	41                   	inc    %ecx
  800ae6:	eb 02                	jmp    800aea <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800aea:	4a                   	dec    %edx
  800aeb:	74 0a                	je     800af7 <strlcpy+0x2b>
  800aed:	8a 19                	mov    (%ecx),%bl
  800aef:	84 db                	test   %bl,%bl
  800af1:	75 ef                	jne    800ae2 <strlcpy+0x16>
  800af3:	89 c2                	mov    %eax,%edx
  800af5:	eb 02                	jmp    800af9 <strlcpy+0x2d>
  800af7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800af9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800afc:	29 f0                	sub    %esi,%eax
}
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b08:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b0b:	eb 02                	jmp    800b0f <strcmp+0xd>
		p++, q++;
  800b0d:	41                   	inc    %ecx
  800b0e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b0f:	8a 01                	mov    (%ecx),%al
  800b11:	84 c0                	test   %al,%al
  800b13:	74 04                	je     800b19 <strcmp+0x17>
  800b15:	3a 02                	cmp    (%edx),%al
  800b17:	74 f4                	je     800b0d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b19:	0f b6 c0             	movzbl %al,%eax
  800b1c:	0f b6 12             	movzbl (%edx),%edx
  800b1f:	29 d0                	sub    %edx,%eax
}
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	53                   	push   %ebx
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b30:	eb 03                	jmp    800b35 <strncmp+0x12>
		n--, p++, q++;
  800b32:	4a                   	dec    %edx
  800b33:	40                   	inc    %eax
  800b34:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b35:	85 d2                	test   %edx,%edx
  800b37:	74 14                	je     800b4d <strncmp+0x2a>
  800b39:	8a 18                	mov    (%eax),%bl
  800b3b:	84 db                	test   %bl,%bl
  800b3d:	74 04                	je     800b43 <strncmp+0x20>
  800b3f:	3a 19                	cmp    (%ecx),%bl
  800b41:	74 ef                	je     800b32 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b43:	0f b6 00             	movzbl (%eax),%eax
  800b46:	0f b6 11             	movzbl (%ecx),%edx
  800b49:	29 d0                	sub    %edx,%eax
  800b4b:	eb 05                	jmp    800b52 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b5e:	eb 05                	jmp    800b65 <strchr+0x10>
		if (*s == c)
  800b60:	38 ca                	cmp    %cl,%dl
  800b62:	74 0c                	je     800b70 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b64:	40                   	inc    %eax
  800b65:	8a 10                	mov    (%eax),%dl
  800b67:	84 d2                	test   %dl,%dl
  800b69:	75 f5                	jne    800b60 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b7b:	eb 05                	jmp    800b82 <strfind+0x10>
		if (*s == c)
  800b7d:	38 ca                	cmp    %cl,%dl
  800b7f:	74 07                	je     800b88 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b81:	40                   	inc    %eax
  800b82:	8a 10                	mov    (%eax),%dl
  800b84:	84 d2                	test   %dl,%dl
  800b86:	75 f5                	jne    800b7d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
  800b90:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b99:	85 c9                	test   %ecx,%ecx
  800b9b:	74 30                	je     800bcd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ba3:	75 25                	jne    800bca <memset+0x40>
  800ba5:	f6 c1 03             	test   $0x3,%cl
  800ba8:	75 20                	jne    800bca <memset+0x40>
		c &= 0xFF;
  800baa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	c1 e3 08             	shl    $0x8,%ebx
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	c1 e6 18             	shl    $0x18,%esi
  800bb7:	89 d0                	mov    %edx,%eax
  800bb9:	c1 e0 10             	shl    $0x10,%eax
  800bbc:	09 f0                	or     %esi,%eax
  800bbe:	09 d0                	or     %edx,%eax
  800bc0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bc2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bc5:	fc                   	cld    
  800bc6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc8:	eb 03                	jmp    800bcd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bca:	fc                   	cld    
  800bcb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bcd:	89 f8                	mov    %edi,%eax
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800be2:	39 c6                	cmp    %eax,%esi
  800be4:	73 34                	jae    800c1a <memmove+0x46>
  800be6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be9:	39 d0                	cmp    %edx,%eax
  800beb:	73 2d                	jae    800c1a <memmove+0x46>
		s += n;
		d += n;
  800bed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf0:	f6 c2 03             	test   $0x3,%dl
  800bf3:	75 1b                	jne    800c10 <memmove+0x3c>
  800bf5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bfb:	75 13                	jne    800c10 <memmove+0x3c>
  800bfd:	f6 c1 03             	test   $0x3,%cl
  800c00:	75 0e                	jne    800c10 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c02:	83 ef 04             	sub    $0x4,%edi
  800c05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c08:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c0b:	fd                   	std    
  800c0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0e:	eb 07                	jmp    800c17 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c10:	4f                   	dec    %edi
  800c11:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c14:	fd                   	std    
  800c15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c17:	fc                   	cld    
  800c18:	eb 20                	jmp    800c3a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c20:	75 13                	jne    800c35 <memmove+0x61>
  800c22:	a8 03                	test   $0x3,%al
  800c24:	75 0f                	jne    800c35 <memmove+0x61>
  800c26:	f6 c1 03             	test   $0x3,%cl
  800c29:	75 0a                	jne    800c35 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c2b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c2e:	89 c7                	mov    %eax,%edi
  800c30:	fc                   	cld    
  800c31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c33:	eb 05                	jmp    800c3a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c35:	89 c7                	mov    %eax,%edi
  800c37:	fc                   	cld    
  800c38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c44:	8b 45 10             	mov    0x10(%ebp),%eax
  800c47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	89 04 24             	mov    %eax,(%esp)
  800c58:	e8 77 ff ff ff       	call   800bd4 <memmove>
}
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c73:	eb 16                	jmp    800c8b <memcmp+0x2c>
		if (*s1 != *s2)
  800c75:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c78:	42                   	inc    %edx
  800c79:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c7d:	38 c8                	cmp    %cl,%al
  800c7f:	74 0a                	je     800c8b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c81:	0f b6 c0             	movzbl %al,%eax
  800c84:	0f b6 c9             	movzbl %cl,%ecx
  800c87:	29 c8                	sub    %ecx,%eax
  800c89:	eb 09                	jmp    800c94 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c8b:	39 da                	cmp    %ebx,%edx
  800c8d:	75 e6                	jne    800c75 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ca2:	89 c2                	mov    %eax,%edx
  800ca4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ca7:	eb 05                	jmp    800cae <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ca9:	38 08                	cmp    %cl,(%eax)
  800cab:	74 05                	je     800cb2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cad:	40                   	inc    %eax
  800cae:	39 d0                	cmp    %edx,%eax
  800cb0:	72 f7                	jb     800ca9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc0:	eb 01                	jmp    800cc3 <strtol+0xf>
		s++;
  800cc2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc3:	8a 02                	mov    (%edx),%al
  800cc5:	3c 20                	cmp    $0x20,%al
  800cc7:	74 f9                	je     800cc2 <strtol+0xe>
  800cc9:	3c 09                	cmp    $0x9,%al
  800ccb:	74 f5                	je     800cc2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ccd:	3c 2b                	cmp    $0x2b,%al
  800ccf:	75 08                	jne    800cd9 <strtol+0x25>
		s++;
  800cd1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cd2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd7:	eb 13                	jmp    800cec <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cd9:	3c 2d                	cmp    $0x2d,%al
  800cdb:	75 0a                	jne    800ce7 <strtol+0x33>
		s++, neg = 1;
  800cdd:	8d 52 01             	lea    0x1(%edx),%edx
  800ce0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ce5:	eb 05                	jmp    800cec <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cec:	85 db                	test   %ebx,%ebx
  800cee:	74 05                	je     800cf5 <strtol+0x41>
  800cf0:	83 fb 10             	cmp    $0x10,%ebx
  800cf3:	75 28                	jne    800d1d <strtol+0x69>
  800cf5:	8a 02                	mov    (%edx),%al
  800cf7:	3c 30                	cmp    $0x30,%al
  800cf9:	75 10                	jne    800d0b <strtol+0x57>
  800cfb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cff:	75 0a                	jne    800d0b <strtol+0x57>
		s += 2, base = 16;
  800d01:	83 c2 02             	add    $0x2,%edx
  800d04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d09:	eb 12                	jmp    800d1d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d0b:	85 db                	test   %ebx,%ebx
  800d0d:	75 0e                	jne    800d1d <strtol+0x69>
  800d0f:	3c 30                	cmp    $0x30,%al
  800d11:	75 05                	jne    800d18 <strtol+0x64>
		s++, base = 8;
  800d13:	42                   	inc    %edx
  800d14:	b3 08                	mov    $0x8,%bl
  800d16:	eb 05                	jmp    800d1d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d18:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d22:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d24:	8a 0a                	mov    (%edx),%cl
  800d26:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d29:	80 fb 09             	cmp    $0x9,%bl
  800d2c:	77 08                	ja     800d36 <strtol+0x82>
			dig = *s - '0';
  800d2e:	0f be c9             	movsbl %cl,%ecx
  800d31:	83 e9 30             	sub    $0x30,%ecx
  800d34:	eb 1e                	jmp    800d54 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d36:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d39:	80 fb 19             	cmp    $0x19,%bl
  800d3c:	77 08                	ja     800d46 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d3e:	0f be c9             	movsbl %cl,%ecx
  800d41:	83 e9 57             	sub    $0x57,%ecx
  800d44:	eb 0e                	jmp    800d54 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d46:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d49:	80 fb 19             	cmp    $0x19,%bl
  800d4c:	77 12                	ja     800d60 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d4e:	0f be c9             	movsbl %cl,%ecx
  800d51:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d54:	39 f1                	cmp    %esi,%ecx
  800d56:	7d 0c                	jge    800d64 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d58:	42                   	inc    %edx
  800d59:	0f af c6             	imul   %esi,%eax
  800d5c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d5e:	eb c4                	jmp    800d24 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d60:	89 c1                	mov    %eax,%ecx
  800d62:	eb 02                	jmp    800d66 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d64:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d6a:	74 05                	je     800d71 <strtol+0xbd>
		*endptr = (char *) s;
  800d6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d6f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d71:	85 ff                	test   %edi,%edi
  800d73:	74 04                	je     800d79 <strtol+0xc5>
  800d75:	89 c8                	mov    %ecx,%eax
  800d77:	f7 d8                	neg    %eax
}
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
	...

00800d80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	89 c3                	mov    %eax,%ebx
  800d93:	89 c7                	mov    %eax,%edi
  800d95:	89 c6                	mov    %eax,%esi
  800d97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	ba 00 00 00 00       	mov    $0x0,%edx
  800da9:	b8 01 00 00 00       	mov    $0x1,%eax
  800dae:	89 d1                	mov    %edx,%ecx
  800db0:	89 d3                	mov    %edx,%ebx
  800db2:	89 d7                	mov    %edx,%edi
  800db4:	89 d6                	mov    %edx,%esi
  800db6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dcb:	b8 03 00 00 00       	mov    $0x3,%eax
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	89 cb                	mov    %ecx,%ebx
  800dd5:	89 cf                	mov    %ecx,%edi
  800dd7:	89 ce                	mov    %ecx,%esi
  800dd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	7e 28                	jle    800e07 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dea:	00 
  800deb:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800df2:	00 
  800df3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfa:	00 
  800dfb:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800e02:	e8 91 f5 ff ff       	call   800398 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e07:	83 c4 2c             	add    $0x2c,%esp
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e15:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1a:	b8 02 00 00 00       	mov    $0x2,%eax
  800e1f:	89 d1                	mov    %edx,%ecx
  800e21:	89 d3                	mov    %edx,%ebx
  800e23:	89 d7                	mov    %edx,%edi
  800e25:	89 d6                	mov    %edx,%esi
  800e27:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <sys_yield>:

void
sys_yield(void)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e34:	ba 00 00 00 00       	mov    $0x0,%edx
  800e39:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e3e:	89 d1                	mov    %edx,%ecx
  800e40:	89 d3                	mov    %edx,%ebx
  800e42:	89 d7                	mov    %edx,%edi
  800e44:	89 d6                	mov    %edx,%esi
  800e46:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e56:	be 00 00 00 00       	mov    $0x0,%esi
  800e5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800e60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e66:	8b 55 08             	mov    0x8(%ebp),%edx
  800e69:	89 f7                	mov    %esi,%edi
  800e6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	7e 28                	jle    800e99 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e75:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800e84:	00 
  800e85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8c:	00 
  800e8d:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800e94:	e8 ff f4 ff ff       	call   800398 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e99:	83 c4 2c             	add    $0x2c,%esp
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
  800ea7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaa:	b8 05 00 00 00       	mov    $0x5,%eax
  800eaf:	8b 75 18             	mov    0x18(%ebp),%esi
  800eb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	7e 28                	jle    800eec <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ecf:	00 
  800ed0:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800ed7:	00 
  800ed8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edf:	00 
  800ee0:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800ee7:	e8 ac f4 ff ff       	call   800398 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800eec:	83 c4 2c             	add    $0x2c,%esp
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
  800efa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f02:	b8 06 00 00 00       	mov    $0x6,%eax
  800f07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0d:	89 df                	mov    %ebx,%edi
  800f0f:	89 de                	mov    %ebx,%esi
  800f11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f13:	85 c0                	test   %eax,%eax
  800f15:	7e 28                	jle    800f3f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f22:	00 
  800f23:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800f2a:	00 
  800f2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f32:	00 
  800f33:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800f3a:	e8 59 f4 ff ff       	call   800398 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f3f:	83 c4 2c             	add    $0x2c,%esp
  800f42:	5b                   	pop    %ebx
  800f43:	5e                   	pop    %esi
  800f44:	5f                   	pop    %edi
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f55:	b8 08 00 00 00       	mov    $0x8,%eax
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f60:	89 df                	mov    %ebx,%edi
  800f62:	89 de                	mov    %ebx,%esi
  800f64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	7e 28                	jle    800f92 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f75:	00 
  800f76:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800f7d:	00 
  800f7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f85:	00 
  800f86:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800f8d:	e8 06 f4 ff ff       	call   800398 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f92:	83 c4 2c             	add    $0x2c,%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	53                   	push   %ebx
  800fa0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa8:	b8 09 00 00 00       	mov    $0x9,%eax
  800fad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb3:	89 df                	mov    %ebx,%edi
  800fb5:	89 de                	mov    %ebx,%esi
  800fb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	7e 28                	jle    800fe5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fc8:	00 
  800fc9:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  800fd0:	00 
  800fd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd8:	00 
  800fd9:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  800fe0:	e8 b3 f3 ff ff       	call   800398 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fe5:	83 c4 2c             	add    $0x2c,%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    

00800fed <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	57                   	push   %edi
  800ff1:	56                   	push   %esi
  800ff2:	53                   	push   %ebx
  800ff3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffb:	b8 0a 00 00 00       	mov    $0xa,%eax
  801000:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801003:	8b 55 08             	mov    0x8(%ebp),%edx
  801006:	89 df                	mov    %ebx,%edi
  801008:	89 de                	mov    %ebx,%esi
  80100a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80100c:	85 c0                	test   %eax,%eax
  80100e:	7e 28                	jle    801038 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801010:	89 44 24 10          	mov    %eax,0x10(%esp)
  801014:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80101b:	00 
  80101c:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  801023:	00 
  801024:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80102b:	00 
  80102c:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  801033:	e8 60 f3 ff ff       	call   800398 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801038:	83 c4 2c             	add    $0x2c,%esp
  80103b:	5b                   	pop    %ebx
  80103c:	5e                   	pop    %esi
  80103d:	5f                   	pop    %edi
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801046:	be 00 00 00 00       	mov    $0x0,%esi
  80104b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801050:	8b 7d 14             	mov    0x14(%ebp),%edi
  801053:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801056:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801059:	8b 55 08             	mov    0x8(%ebp),%edx
  80105c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80105e:	5b                   	pop    %ebx
  80105f:	5e                   	pop    %esi
  801060:	5f                   	pop    %edi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	57                   	push   %edi
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
  801069:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801071:	b8 0d 00 00 00       	mov    $0xd,%eax
  801076:	8b 55 08             	mov    0x8(%ebp),%edx
  801079:	89 cb                	mov    %ecx,%ebx
  80107b:	89 cf                	mov    %ecx,%edi
  80107d:	89 ce                	mov    %ecx,%esi
  80107f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801081:	85 c0                	test   %eax,%eax
  801083:	7e 28                	jle    8010ad <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801085:	89 44 24 10          	mov    %eax,0x10(%esp)
  801089:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801090:	00 
  801091:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  801098:	00 
  801099:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010a0:	00 
  8010a1:	c7 04 24 5c 28 80 00 	movl   $0x80285c,(%esp)
  8010a8:	e8 eb f2 ff ff       	call   800398 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010ad:	83 c4 2c             	add    $0x2c,%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    
  8010b5:	00 00                	add    %al,(%eax)
	...

008010b8 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c1:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8010c4:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  8010c6:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  8010c9:	83 3a 01             	cmpl   $0x1,(%edx)
  8010cc:	7e 0b                	jle    8010d9 <argstart+0x21>
  8010ce:	85 c9                	test   %ecx,%ecx
  8010d0:	75 0e                	jne    8010e0 <argstart+0x28>
  8010d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d7:	eb 0c                	jmp    8010e5 <argstart+0x2d>
  8010d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010de:	eb 05                	jmp    8010e5 <argstart+0x2d>
  8010e0:	ba e8 24 80 00       	mov    $0x8024e8,%edx
  8010e5:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  8010e8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <argnext>:

int
argnext(struct Argstate *args)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	53                   	push   %ebx
  8010f5:	83 ec 14             	sub    $0x14,%esp
  8010f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  8010fb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801102:	8b 43 08             	mov    0x8(%ebx),%eax
  801105:	85 c0                	test   %eax,%eax
  801107:	74 6c                	je     801175 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  801109:	80 38 00             	cmpb   $0x0,(%eax)
  80110c:	75 4d                	jne    80115b <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  80110e:	8b 0b                	mov    (%ebx),%ecx
  801110:	83 39 01             	cmpl   $0x1,(%ecx)
  801113:	74 52                	je     801167 <argnext+0x76>
		    || args->argv[1][0] != '-'
  801115:	8b 53 04             	mov    0x4(%ebx),%edx
  801118:	8b 42 04             	mov    0x4(%edx),%eax
  80111b:	80 38 2d             	cmpb   $0x2d,(%eax)
  80111e:	75 47                	jne    801167 <argnext+0x76>
		    || args->argv[1][1] == '\0')
  801120:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801124:	74 41                	je     801167 <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801126:	40                   	inc    %eax
  801127:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80112a:	8b 01                	mov    (%ecx),%eax
  80112c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801133:	89 44 24 08          	mov    %eax,0x8(%esp)
  801137:	8d 42 08             	lea    0x8(%edx),%eax
  80113a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113e:	83 c2 04             	add    $0x4,%edx
  801141:	89 14 24             	mov    %edx,(%esp)
  801144:	e8 8b fa ff ff       	call   800bd4 <memmove>
		(*args->argc)--;
  801149:	8b 03                	mov    (%ebx),%eax
  80114b:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80114d:	8b 43 08             	mov    0x8(%ebx),%eax
  801150:	80 38 2d             	cmpb   $0x2d,(%eax)
  801153:	75 06                	jne    80115b <argnext+0x6a>
  801155:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801159:	74 0c                	je     801167 <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  80115b:	8b 53 08             	mov    0x8(%ebx),%edx
  80115e:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801161:	42                   	inc    %edx
  801162:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801165:	eb 13                	jmp    80117a <argnext+0x89>

    endofargs:
	args->curarg = 0;
  801167:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  80116e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801173:	eb 05                	jmp    80117a <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  80117a:	83 c4 14             	add    $0x14,%esp
  80117d:	5b                   	pop    %ebx
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	53                   	push   %ebx
  801184:	83 ec 14             	sub    $0x14,%esp
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  80118a:	8b 43 08             	mov    0x8(%ebx),%eax
  80118d:	85 c0                	test   %eax,%eax
  80118f:	74 59                	je     8011ea <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  801191:	80 38 00             	cmpb   $0x0,(%eax)
  801194:	74 0c                	je     8011a2 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801196:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801199:	c7 43 08 e8 24 80 00 	movl   $0x8024e8,0x8(%ebx)
  8011a0:	eb 43                	jmp    8011e5 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  8011a2:	8b 03                	mov    (%ebx),%eax
  8011a4:	83 38 01             	cmpl   $0x1,(%eax)
  8011a7:	7e 2e                	jle    8011d7 <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  8011a9:	8b 53 04             	mov    0x4(%ebx),%edx
  8011ac:	8b 4a 04             	mov    0x4(%edx),%ecx
  8011af:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8011b2:	8b 00                	mov    (%eax),%eax
  8011b4:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8011bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011bf:	8d 42 08             	lea    0x8(%edx),%eax
  8011c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c6:	83 c2 04             	add    $0x4,%edx
  8011c9:	89 14 24             	mov    %edx,(%esp)
  8011cc:	e8 03 fa ff ff       	call   800bd4 <memmove>
		(*args->argc)--;
  8011d1:	8b 03                	mov    (%ebx),%eax
  8011d3:	ff 08                	decl   (%eax)
  8011d5:	eb 0e                	jmp    8011e5 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  8011d7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8011de:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8011e5:	8b 43 0c             	mov    0xc(%ebx),%eax
  8011e8:	eb 05                	jmp    8011ef <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8011ea:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8011ef:	83 c4 14             	add    $0x14,%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    

008011f5 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	83 ec 18             	sub    $0x18,%esp
  8011fb:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8011fe:	8b 42 0c             	mov    0xc(%edx),%eax
  801201:	85 c0                	test   %eax,%eax
  801203:	75 08                	jne    80120d <argvalue+0x18>
  801205:	89 14 24             	mov    %edx,(%esp)
  801208:	e8 73 ff ff ff       	call   801180 <argnextvalue>
}
  80120d:	c9                   	leave  
  80120e:	c3                   	ret    
	...

00801210 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
  801216:	05 00 00 00 30       	add    $0x30000000,%eax
  80121b:	c1 e8 0c             	shr    $0xc,%eax
}
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	89 04 24             	mov    %eax,(%esp)
  80122c:	e8 df ff ff ff       	call   801210 <fd2num>
  801231:	05 20 00 0d 00       	add    $0xd0020,%eax
  801236:	c1 e0 0c             	shl    $0xc,%eax
}
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	53                   	push   %ebx
  80123f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801242:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801247:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801249:	89 c2                	mov    %eax,%edx
  80124b:	c1 ea 16             	shr    $0x16,%edx
  80124e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801255:	f6 c2 01             	test   $0x1,%dl
  801258:	74 11                	je     80126b <fd_alloc+0x30>
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	c1 ea 0c             	shr    $0xc,%edx
  80125f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801266:	f6 c2 01             	test   $0x1,%dl
  801269:	75 09                	jne    801274 <fd_alloc+0x39>
			*fd_store = fd;
  80126b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80126d:	b8 00 00 00 00       	mov    $0x0,%eax
  801272:	eb 17                	jmp    80128b <fd_alloc+0x50>
  801274:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801279:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80127e:	75 c7                	jne    801247 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801280:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801286:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80128b:	5b                   	pop    %ebx
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    

0080128e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801294:	83 f8 1f             	cmp    $0x1f,%eax
  801297:	77 36                	ja     8012cf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801299:	05 00 00 0d 00       	add    $0xd0000,%eax
  80129e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a1:	89 c2                	mov    %eax,%edx
  8012a3:	c1 ea 16             	shr    $0x16,%edx
  8012a6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ad:	f6 c2 01             	test   $0x1,%dl
  8012b0:	74 24                	je     8012d6 <fd_lookup+0x48>
  8012b2:	89 c2                	mov    %eax,%edx
  8012b4:	c1 ea 0c             	shr    $0xc,%edx
  8012b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012be:	f6 c2 01             	test   $0x1,%dl
  8012c1:	74 1a                	je     8012dd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c6:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cd:	eb 13                	jmp    8012e2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d4:	eb 0c                	jmp    8012e2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012db:	eb 05                	jmp    8012e2 <fd_lookup+0x54>
  8012dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    

008012e4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 14             	sub    $0x14,%esp
  8012eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8012f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f6:	eb 0e                	jmp    801306 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8012f8:	39 08                	cmp    %ecx,(%eax)
  8012fa:	75 09                	jne    801305 <dev_lookup+0x21>
			*dev = devtab[i];
  8012fc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	eb 33                	jmp    801338 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801305:	42                   	inc    %edx
  801306:	8b 04 95 ec 28 80 00 	mov    0x8028ec(,%edx,4),%eax
  80130d:	85 c0                	test   %eax,%eax
  80130f:	75 e7                	jne    8012f8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801311:	a1 20 44 80 00       	mov    0x804420,%eax
  801316:	8b 40 48             	mov    0x48(%eax),%eax
  801319:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80131d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801321:	c7 04 24 6c 28 80 00 	movl   $0x80286c,(%esp)
  801328:	e8 63 f1 ff ff       	call   800490 <cprintf>
	*dev = 0;
  80132d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801333:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801338:	83 c4 14             	add    $0x14,%esp
  80133b:	5b                   	pop    %ebx
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	56                   	push   %esi
  801342:	53                   	push   %ebx
  801343:	83 ec 30             	sub    $0x30,%esp
  801346:	8b 75 08             	mov    0x8(%ebp),%esi
  801349:	8a 45 0c             	mov    0xc(%ebp),%al
  80134c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134f:	89 34 24             	mov    %esi,(%esp)
  801352:	e8 b9 fe ff ff       	call   801210 <fd2num>
  801357:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80135a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80135e:	89 04 24             	mov    %eax,(%esp)
  801361:	e8 28 ff ff ff       	call   80128e <fd_lookup>
  801366:	89 c3                	mov    %eax,%ebx
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 05                	js     801371 <fd_close+0x33>
	    || fd != fd2)
  80136c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80136f:	74 0d                	je     80137e <fd_close+0x40>
		return (must_exist ? r : 0);
  801371:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801375:	75 46                	jne    8013bd <fd_close+0x7f>
  801377:	bb 00 00 00 00       	mov    $0x0,%ebx
  80137c:	eb 3f                	jmp    8013bd <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80137e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801381:	89 44 24 04          	mov    %eax,0x4(%esp)
  801385:	8b 06                	mov    (%esi),%eax
  801387:	89 04 24             	mov    %eax,(%esp)
  80138a:	e8 55 ff ff ff       	call   8012e4 <dev_lookup>
  80138f:	89 c3                	mov    %eax,%ebx
  801391:	85 c0                	test   %eax,%eax
  801393:	78 18                	js     8013ad <fd_close+0x6f>
		if (dev->dev_close)
  801395:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801398:	8b 40 10             	mov    0x10(%eax),%eax
  80139b:	85 c0                	test   %eax,%eax
  80139d:	74 09                	je     8013a8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80139f:	89 34 24             	mov    %esi,(%esp)
  8013a2:	ff d0                	call   *%eax
  8013a4:	89 c3                	mov    %eax,%ebx
  8013a6:	eb 05                	jmp    8013ad <fd_close+0x6f>
		else
			r = 0;
  8013a8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013b8:	e8 37 fb ff ff       	call   800ef4 <sys_page_unmap>
	return r;
}
  8013bd:	89 d8                	mov    %ebx,%eax
  8013bf:	83 c4 30             	add    $0x30,%esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5e                   	pop    %esi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    

008013c6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d6:	89 04 24             	mov    %eax,(%esp)
  8013d9:	e8 b0 fe ff ff       	call   80128e <fd_lookup>
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 13                	js     8013f5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8013e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013e9:	00 
  8013ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ed:	89 04 24             	mov    %eax,(%esp)
  8013f0:	e8 49 ff ff ff       	call   80133e <fd_close>
}
  8013f5:	c9                   	leave  
  8013f6:	c3                   	ret    

008013f7 <close_all>:

void
close_all(void)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	53                   	push   %ebx
  8013fb:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013fe:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801403:	89 1c 24             	mov    %ebx,(%esp)
  801406:	e8 bb ff ff ff       	call   8013c6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80140b:	43                   	inc    %ebx
  80140c:	83 fb 20             	cmp    $0x20,%ebx
  80140f:	75 f2                	jne    801403 <close_all+0xc>
		close(i);
}
  801411:	83 c4 14             	add    $0x14,%esp
  801414:	5b                   	pop    %ebx
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    

00801417 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	57                   	push   %edi
  80141b:	56                   	push   %esi
  80141c:	53                   	push   %ebx
  80141d:	83 ec 4c             	sub    $0x4c,%esp
  801420:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801423:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801426:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142a:	8b 45 08             	mov    0x8(%ebp),%eax
  80142d:	89 04 24             	mov    %eax,(%esp)
  801430:	e8 59 fe ff ff       	call   80128e <fd_lookup>
  801435:	89 c3                	mov    %eax,%ebx
  801437:	85 c0                	test   %eax,%eax
  801439:	0f 88 e1 00 00 00    	js     801520 <dup+0x109>
		return r;
	close(newfdnum);
  80143f:	89 3c 24             	mov    %edi,(%esp)
  801442:	e8 7f ff ff ff       	call   8013c6 <close>

	newfd = INDEX2FD(newfdnum);
  801447:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80144d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801450:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801453:	89 04 24             	mov    %eax,(%esp)
  801456:	e8 c5 fd ff ff       	call   801220 <fd2data>
  80145b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80145d:	89 34 24             	mov    %esi,(%esp)
  801460:	e8 bb fd ff ff       	call   801220 <fd2data>
  801465:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801468:	89 d8                	mov    %ebx,%eax
  80146a:	c1 e8 16             	shr    $0x16,%eax
  80146d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801474:	a8 01                	test   $0x1,%al
  801476:	74 46                	je     8014be <dup+0xa7>
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	c1 e8 0c             	shr    $0xc,%eax
  80147d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801484:	f6 c2 01             	test   $0x1,%dl
  801487:	74 35                	je     8014be <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801489:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801490:	25 07 0e 00 00       	and    $0xe07,%eax
  801495:	89 44 24 10          	mov    %eax,0x10(%esp)
  801499:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80149c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014a7:	00 
  8014a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014b3:	e8 e9 f9 ff ff       	call   800ea1 <sys_page_map>
  8014b8:	89 c3                	mov    %eax,%ebx
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 3b                	js     8014f9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014c1:	89 c2                	mov    %eax,%edx
  8014c3:	c1 ea 0c             	shr    $0xc,%edx
  8014c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014cd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014d3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014d7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014e2:	00 
  8014e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ee:	e8 ae f9 ff ff       	call   800ea1 <sys_page_map>
  8014f3:	89 c3                	mov    %eax,%ebx
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	79 25                	jns    80151e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801504:	e8 eb f9 ff ff       	call   800ef4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801509:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80150c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801510:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801517:	e8 d8 f9 ff ff       	call   800ef4 <sys_page_unmap>
	return r;
  80151c:	eb 02                	jmp    801520 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80151e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801520:	89 d8                	mov    %ebx,%eax
  801522:	83 c4 4c             	add    $0x4c,%esp
  801525:	5b                   	pop    %ebx
  801526:	5e                   	pop    %esi
  801527:	5f                   	pop    %edi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    

0080152a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 24             	sub    $0x24,%esp
  801531:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801534:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801537:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153b:	89 1c 24             	mov    %ebx,(%esp)
  80153e:	e8 4b fd ff ff       	call   80128e <fd_lookup>
  801543:	85 c0                	test   %eax,%eax
  801545:	78 6d                	js     8015b4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801547:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801551:	8b 00                	mov    (%eax),%eax
  801553:	89 04 24             	mov    %eax,(%esp)
  801556:	e8 89 fd ff ff       	call   8012e4 <dev_lookup>
  80155b:	85 c0                	test   %eax,%eax
  80155d:	78 55                	js     8015b4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801562:	8b 50 08             	mov    0x8(%eax),%edx
  801565:	83 e2 03             	and    $0x3,%edx
  801568:	83 fa 01             	cmp    $0x1,%edx
  80156b:	75 23                	jne    801590 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80156d:	a1 20 44 80 00       	mov    0x804420,%eax
  801572:	8b 40 48             	mov    0x48(%eax),%eax
  801575:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157d:	c7 04 24 b0 28 80 00 	movl   $0x8028b0,(%esp)
  801584:	e8 07 ef ff ff       	call   800490 <cprintf>
		return -E_INVAL;
  801589:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158e:	eb 24                	jmp    8015b4 <read+0x8a>
	}
	if (!dev->dev_read)
  801590:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801593:	8b 52 08             	mov    0x8(%edx),%edx
  801596:	85 d2                	test   %edx,%edx
  801598:	74 15                	je     8015af <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80159a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80159d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015a8:	89 04 24             	mov    %eax,(%esp)
  8015ab:	ff d2                	call   *%edx
  8015ad:	eb 05                	jmp    8015b4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015b4:	83 c4 24             	add    $0x24,%esp
  8015b7:	5b                   	pop    %ebx
  8015b8:	5d                   	pop    %ebp
  8015b9:	c3                   	ret    

008015ba <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	57                   	push   %edi
  8015be:	56                   	push   %esi
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 1c             	sub    $0x1c,%esp
  8015c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015c6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ce:	eb 23                	jmp    8015f3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d0:	89 f0                	mov    %esi,%eax
  8015d2:	29 d8                	sub    %ebx,%eax
  8015d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015db:	01 d8                	add    %ebx,%eax
  8015dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e1:	89 3c 24             	mov    %edi,(%esp)
  8015e4:	e8 41 ff ff ff       	call   80152a <read>
		if (m < 0)
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 10                	js     8015fd <readn+0x43>
			return m;
		if (m == 0)
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	74 0a                	je     8015fb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f1:	01 c3                	add    %eax,%ebx
  8015f3:	39 f3                	cmp    %esi,%ebx
  8015f5:	72 d9                	jb     8015d0 <readn+0x16>
  8015f7:	89 d8                	mov    %ebx,%eax
  8015f9:	eb 02                	jmp    8015fd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015fb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015fd:	83 c4 1c             	add    $0x1c,%esp
  801600:	5b                   	pop    %ebx
  801601:	5e                   	pop    %esi
  801602:	5f                   	pop    %edi
  801603:	5d                   	pop    %ebp
  801604:	c3                   	ret    

00801605 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	53                   	push   %ebx
  801609:	83 ec 24             	sub    $0x24,%esp
  80160c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801612:	89 44 24 04          	mov    %eax,0x4(%esp)
  801616:	89 1c 24             	mov    %ebx,(%esp)
  801619:	e8 70 fc ff ff       	call   80128e <fd_lookup>
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 68                	js     80168a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801622:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801625:	89 44 24 04          	mov    %eax,0x4(%esp)
  801629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162c:	8b 00                	mov    (%eax),%eax
  80162e:	89 04 24             	mov    %eax,(%esp)
  801631:	e8 ae fc ff ff       	call   8012e4 <dev_lookup>
  801636:	85 c0                	test   %eax,%eax
  801638:	78 50                	js     80168a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801641:	75 23                	jne    801666 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801643:	a1 20 44 80 00       	mov    0x804420,%eax
  801648:	8b 40 48             	mov    0x48(%eax),%eax
  80164b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80164f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801653:	c7 04 24 cc 28 80 00 	movl   $0x8028cc,(%esp)
  80165a:	e8 31 ee ff ff       	call   800490 <cprintf>
		return -E_INVAL;
  80165f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801664:	eb 24                	jmp    80168a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801666:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801669:	8b 52 0c             	mov    0xc(%edx),%edx
  80166c:	85 d2                	test   %edx,%edx
  80166e:	74 15                	je     801685 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801670:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801673:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801677:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80167a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80167e:	89 04 24             	mov    %eax,(%esp)
  801681:	ff d2                	call   *%edx
  801683:	eb 05                	jmp    80168a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801685:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80168a:	83 c4 24             	add    $0x24,%esp
  80168d:	5b                   	pop    %ebx
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <seek>:

int
seek(int fdnum, off_t offset)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801696:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169d:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a0:	89 04 24             	mov    %eax,(%esp)
  8016a3:	e8 e6 fb ff ff       	call   80128e <fd_lookup>
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	78 0e                	js     8016ba <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 24             	sub    $0x24,%esp
  8016c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cd:	89 1c 24             	mov    %ebx,(%esp)
  8016d0:	e8 b9 fb ff ff       	call   80128e <fd_lookup>
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 61                	js     80173a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e3:	8b 00                	mov    (%eax),%eax
  8016e5:	89 04 24             	mov    %eax,(%esp)
  8016e8:	e8 f7 fb ff ff       	call   8012e4 <dev_lookup>
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 49                	js     80173a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f8:	75 23                	jne    80171d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016fa:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ff:	8b 40 48             	mov    0x48(%eax),%eax
  801702:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801706:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170a:	c7 04 24 8c 28 80 00 	movl   $0x80288c,(%esp)
  801711:	e8 7a ed ff ff       	call   800490 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801716:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80171b:	eb 1d                	jmp    80173a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80171d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801720:	8b 52 18             	mov    0x18(%edx),%edx
  801723:	85 d2                	test   %edx,%edx
  801725:	74 0e                	je     801735 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801727:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80172e:	89 04 24             	mov    %eax,(%esp)
  801731:	ff d2                	call   *%edx
  801733:	eb 05                	jmp    80173a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801735:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80173a:	83 c4 24             	add    $0x24,%esp
  80173d:	5b                   	pop    %ebx
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	53                   	push   %ebx
  801744:	83 ec 24             	sub    $0x24,%esp
  801747:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801751:	8b 45 08             	mov    0x8(%ebp),%eax
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	e8 32 fb ff ff       	call   80128e <fd_lookup>
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 52                	js     8017b2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801760:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801763:	89 44 24 04          	mov    %eax,0x4(%esp)
  801767:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176a:	8b 00                	mov    (%eax),%eax
  80176c:	89 04 24             	mov    %eax,(%esp)
  80176f:	e8 70 fb ff ff       	call   8012e4 <dev_lookup>
  801774:	85 c0                	test   %eax,%eax
  801776:	78 3a                	js     8017b2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801778:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80177f:	74 2c                	je     8017ad <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801781:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801784:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80178b:	00 00 00 
	stat->st_isdir = 0;
  80178e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801795:	00 00 00 
	stat->st_dev = dev;
  801798:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80179e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017a5:	89 14 24             	mov    %edx,(%esp)
  8017a8:	ff 50 14             	call   *0x14(%eax)
  8017ab:	eb 05                	jmp    8017b2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017b2:	83 c4 24             	add    $0x24,%esp
  8017b5:	5b                   	pop    %ebx
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	56                   	push   %esi
  8017bc:	53                   	push   %ebx
  8017bd:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017c7:	00 
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	89 04 24             	mov    %eax,(%esp)
  8017ce:	e8 fe 01 00 00       	call   8019d1 <open>
  8017d3:	89 c3                	mov    %eax,%ebx
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 1b                	js     8017f4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8017d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e0:	89 1c 24             	mov    %ebx,(%esp)
  8017e3:	e8 58 ff ff ff       	call   801740 <fstat>
  8017e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ea:	89 1c 24             	mov    %ebx,(%esp)
  8017ed:	e8 d4 fb ff ff       	call   8013c6 <close>
	return r;
  8017f2:	89 f3                	mov    %esi,%ebx
}
  8017f4:	89 d8                	mov    %ebx,%eax
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	5b                   	pop    %ebx
  8017fa:	5e                   	pop    %esi
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    
  8017fd:	00 00                	add    %al,(%eax)
	...

00801800 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	56                   	push   %esi
  801804:	53                   	push   %ebx
  801805:	83 ec 10             	sub    $0x10,%esp
  801808:	89 c3                	mov    %eax,%ebx
  80180a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80180c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801813:	75 11                	jne    801826 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801815:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80181c:	e8 70 09 00 00       	call   802191 <ipc_find_env>
  801821:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801826:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80182d:	00 
  80182e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801835:	00 
  801836:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80183a:	a1 00 40 80 00       	mov    0x804000,%eax
  80183f:	89 04 24             	mov    %eax,(%esp)
  801842:	e8 e0 08 00 00       	call   802127 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801847:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80184e:	00 
  80184f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801853:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80185a:	e8 61 08 00 00       	call   8020c0 <ipc_recv>
}
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    

00801866 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	8b 40 0c             	mov    0xc(%eax),%eax
  801872:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80187f:	ba 00 00 00 00       	mov    $0x0,%edx
  801884:	b8 02 00 00 00       	mov    $0x2,%eax
  801889:	e8 72 ff ff ff       	call   801800 <fsipc>
}
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801896:	8b 45 08             	mov    0x8(%ebp),%eax
  801899:	8b 40 0c             	mov    0xc(%eax),%eax
  80189c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a6:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ab:	e8 50 ff ff ff       	call   801800 <fsipc>
}
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	53                   	push   %ebx
  8018b6:	83 ec 14             	sub    $0x14,%esp
  8018b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cc:	b8 05 00 00 00       	mov    $0x5,%eax
  8018d1:	e8 2a ff ff ff       	call   801800 <fsipc>
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	78 2b                	js     801905 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018da:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018e1:	00 
  8018e2:	89 1c 24             	mov    %ebx,(%esp)
  8018e5:	e8 71 f1 ff ff       	call   800a5b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ea:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018f5:	a1 84 50 80 00       	mov    0x805084,%eax
  8018fa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801900:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801905:	83 c4 14             	add    $0x14,%esp
  801908:	5b                   	pop    %ebx
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801911:	c7 44 24 08 fc 28 80 	movl   $0x8028fc,0x8(%esp)
  801918:	00 
  801919:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801920:	00 
  801921:	c7 04 24 1a 29 80 00 	movl   $0x80291a,(%esp)
  801928:	e8 6b ea ff ff       	call   800398 <_panic>

0080192d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	56                   	push   %esi
  801931:	53                   	push   %ebx
  801932:	83 ec 10             	sub    $0x10,%esp
  801935:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801938:	8b 45 08             	mov    0x8(%ebp),%eax
  80193b:	8b 40 0c             	mov    0xc(%eax),%eax
  80193e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801943:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801949:	ba 00 00 00 00       	mov    $0x0,%edx
  80194e:	b8 03 00 00 00       	mov    $0x3,%eax
  801953:	e8 a8 fe ff ff       	call   801800 <fsipc>
  801958:	89 c3                	mov    %eax,%ebx
  80195a:	85 c0                	test   %eax,%eax
  80195c:	78 6a                	js     8019c8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80195e:	39 c6                	cmp    %eax,%esi
  801960:	73 24                	jae    801986 <devfile_read+0x59>
  801962:	c7 44 24 0c 25 29 80 	movl   $0x802925,0xc(%esp)
  801969:	00 
  80196a:	c7 44 24 08 2c 29 80 	movl   $0x80292c,0x8(%esp)
  801971:	00 
  801972:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801979:	00 
  80197a:	c7 04 24 1a 29 80 00 	movl   $0x80291a,(%esp)
  801981:	e8 12 ea ff ff       	call   800398 <_panic>
	assert(r <= PGSIZE);
  801986:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80198b:	7e 24                	jle    8019b1 <devfile_read+0x84>
  80198d:	c7 44 24 0c 41 29 80 	movl   $0x802941,0xc(%esp)
  801994:	00 
  801995:	c7 44 24 08 2c 29 80 	movl   $0x80292c,0x8(%esp)
  80199c:	00 
  80199d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8019a4:	00 
  8019a5:	c7 04 24 1a 29 80 00 	movl   $0x80291a,(%esp)
  8019ac:	e8 e7 e9 ff ff       	call   800398 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019b5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019bc:	00 
  8019bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c0:	89 04 24             	mov    %eax,(%esp)
  8019c3:	e8 0c f2 ff ff       	call   800bd4 <memmove>
	return r;
}
  8019c8:	89 d8                	mov    %ebx,%eax
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	5b                   	pop    %ebx
  8019ce:	5e                   	pop    %esi
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    

008019d1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	56                   	push   %esi
  8019d5:	53                   	push   %ebx
  8019d6:	83 ec 20             	sub    $0x20,%esp
  8019d9:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019dc:	89 34 24             	mov    %esi,(%esp)
  8019df:	e8 44 f0 ff ff       	call   800a28 <strlen>
  8019e4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019e9:	7f 60                	jg     801a4b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ee:	89 04 24             	mov    %eax,(%esp)
  8019f1:	e8 45 f8 ff ff       	call   80123b <fd_alloc>
  8019f6:	89 c3                	mov    %eax,%ebx
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	78 54                	js     801a50 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a00:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a07:	e8 4f f0 ff ff       	call   800a5b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a17:	b8 01 00 00 00       	mov    $0x1,%eax
  801a1c:	e8 df fd ff ff       	call   801800 <fsipc>
  801a21:	89 c3                	mov    %eax,%ebx
  801a23:	85 c0                	test   %eax,%eax
  801a25:	79 15                	jns    801a3c <open+0x6b>
		fd_close(fd, 0);
  801a27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a2e:	00 
  801a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a32:	89 04 24             	mov    %eax,(%esp)
  801a35:	e8 04 f9 ff ff       	call   80133e <fd_close>
		return r;
  801a3a:	eb 14                	jmp    801a50 <open+0x7f>
	}

	return fd2num(fd);
  801a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3f:	89 04 24             	mov    %eax,(%esp)
  801a42:	e8 c9 f7 ff ff       	call   801210 <fd2num>
  801a47:	89 c3                	mov    %eax,%ebx
  801a49:	eb 05                	jmp    801a50 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a4b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a50:	89 d8                	mov    %ebx,%eax
  801a52:	83 c4 20             	add    $0x20,%esp
  801a55:	5b                   	pop    %ebx
  801a56:	5e                   	pop    %esi
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    

00801a59 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a64:	b8 08 00 00 00       	mov    $0x8,%eax
  801a69:	e8 92 fd ff ff       	call   801800 <fsipc>
}
  801a6e:	c9                   	leave  
  801a6f:	c3                   	ret    

00801a70 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	53                   	push   %ebx
  801a74:	83 ec 14             	sub    $0x14,%esp
  801a77:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801a79:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a7d:	7e 32                	jle    801ab1 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a7f:	8b 40 04             	mov    0x4(%eax),%eax
  801a82:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a86:	8d 43 10             	lea    0x10(%ebx),%eax
  801a89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8d:	8b 03                	mov    (%ebx),%eax
  801a8f:	89 04 24             	mov    %eax,(%esp)
  801a92:	e8 6e fb ff ff       	call   801605 <write>
		if (result > 0)
  801a97:	85 c0                	test   %eax,%eax
  801a99:	7e 03                	jle    801a9e <writebuf+0x2e>
			b->result += result;
  801a9b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a9e:	39 43 04             	cmp    %eax,0x4(%ebx)
  801aa1:	74 0e                	je     801ab1 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801aa3:	89 c2                	mov    %eax,%edx
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	7e 05                	jle    801aae <writebuf+0x3e>
  801aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  801aae:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801ab1:	83 c4 14             	add    $0x14,%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5d                   	pop    %ebp
  801ab6:	c3                   	ret    

00801ab7 <putch>:

static void
putch(int ch, void *thunk)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	53                   	push   %ebx
  801abb:	83 ec 04             	sub    $0x4,%esp
  801abe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801ac1:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac7:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801acb:	40                   	inc    %eax
  801acc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801acf:	3d 00 01 00 00       	cmp    $0x100,%eax
  801ad4:	75 0e                	jne    801ae4 <putch+0x2d>
		writebuf(b);
  801ad6:	89 d8                	mov    %ebx,%eax
  801ad8:	e8 93 ff ff ff       	call   801a70 <writebuf>
		b->idx = 0;
  801add:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801ae4:	83 c4 04             	add    $0x4,%esp
  801ae7:	5b                   	pop    %ebx
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801af3:	8b 45 08             	mov    0x8(%ebp),%eax
  801af6:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801afc:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801b03:	00 00 00 
	b.result = 0;
  801b06:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b0d:	00 00 00 
	b.error = 1;
  801b10:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801b17:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801b1a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b24:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b28:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b32:	c7 04 24 b7 1a 80 00 	movl   $0x801ab7,(%esp)
  801b39:	e8 b4 ea ff ff       	call   8005f2 <vprintfmt>
	if (b.idx > 0)
  801b3e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801b45:	7e 0b                	jle    801b52 <vfprintf+0x68>
		writebuf(&b);
  801b47:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b4d:	e8 1e ff ff ff       	call   801a70 <writebuf>

	return (b.result ? b.result : b.error);
  801b52:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	75 06                	jne    801b62 <vfprintf+0x78>
  801b5c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801b62:	c9                   	leave  
  801b63:	c3                   	ret    

00801b64 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b6a:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801b6d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b78:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7b:	89 04 24             	mov    %eax,(%esp)
  801b7e:	e8 67 ff ff ff       	call   801aea <vfprintf>
	va_end(ap);

	return cnt;
}
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    

00801b85 <printf>:

int
printf(const char *fmt, ...)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b8b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b92:	8b 45 08             	mov    0x8(%ebp),%eax
  801b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801ba0:	e8 45 ff ff ff       	call   801aea <vfprintf>
	va_end(ap);

	return cnt;
}
  801ba5:	c9                   	leave  
  801ba6:	c3                   	ret    
	...

00801ba8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	56                   	push   %esi
  801bac:	53                   	push   %ebx
  801bad:	83 ec 10             	sub    $0x10,%esp
  801bb0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb6:	89 04 24             	mov    %eax,(%esp)
  801bb9:	e8 62 f6 ff ff       	call   801220 <fd2data>
  801bbe:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801bc0:	c7 44 24 04 4d 29 80 	movl   $0x80294d,0x4(%esp)
  801bc7:	00 
  801bc8:	89 34 24             	mov    %esi,(%esp)
  801bcb:	e8 8b ee ff ff       	call   800a5b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bd0:	8b 43 04             	mov    0x4(%ebx),%eax
  801bd3:	2b 03                	sub    (%ebx),%eax
  801bd5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801bdb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801be2:	00 00 00 
	stat->st_dev = &devpipe;
  801be5:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801bec:	30 80 00 
	return 0;
}
  801bef:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	5b                   	pop    %ebx
  801bf8:	5e                   	pop    %esi
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	53                   	push   %ebx
  801bff:	83 ec 14             	sub    $0x14,%esp
  801c02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c10:	e8 df f2 ff ff       	call   800ef4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c15:	89 1c 24             	mov    %ebx,(%esp)
  801c18:	e8 03 f6 ff ff       	call   801220 <fd2data>
  801c1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c28:	e8 c7 f2 ff ff       	call   800ef4 <sys_page_unmap>
}
  801c2d:	83 c4 14             	add    $0x14,%esp
  801c30:	5b                   	pop    %ebx
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	57                   	push   %edi
  801c37:	56                   	push   %esi
  801c38:	53                   	push   %ebx
  801c39:	83 ec 2c             	sub    $0x2c,%esp
  801c3c:	89 c7                	mov    %eax,%edi
  801c3e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c41:	a1 20 44 80 00       	mov    0x804420,%eax
  801c46:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c49:	89 3c 24             	mov    %edi,(%esp)
  801c4c:	e8 87 05 00 00       	call   8021d8 <pageref>
  801c51:	89 c6                	mov    %eax,%esi
  801c53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c56:	89 04 24             	mov    %eax,(%esp)
  801c59:	e8 7a 05 00 00       	call   8021d8 <pageref>
  801c5e:	39 c6                	cmp    %eax,%esi
  801c60:	0f 94 c0             	sete   %al
  801c63:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c66:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801c6c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c6f:	39 cb                	cmp    %ecx,%ebx
  801c71:	75 08                	jne    801c7b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c73:	83 c4 2c             	add    $0x2c,%esp
  801c76:	5b                   	pop    %ebx
  801c77:	5e                   	pop    %esi
  801c78:	5f                   	pop    %edi
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c7b:	83 f8 01             	cmp    $0x1,%eax
  801c7e:	75 c1                	jne    801c41 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c80:	8b 42 58             	mov    0x58(%edx),%eax
  801c83:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c8a:	00 
  801c8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c93:	c7 04 24 54 29 80 00 	movl   $0x802954,(%esp)
  801c9a:	e8 f1 e7 ff ff       	call   800490 <cprintf>
  801c9f:	eb a0                	jmp    801c41 <_pipeisclosed+0xe>

00801ca1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	57                   	push   %edi
  801ca5:	56                   	push   %esi
  801ca6:	53                   	push   %ebx
  801ca7:	83 ec 1c             	sub    $0x1c,%esp
  801caa:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cad:	89 34 24             	mov    %esi,(%esp)
  801cb0:	e8 6b f5 ff ff       	call   801220 <fd2data>
  801cb5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb7:	bf 00 00 00 00       	mov    $0x0,%edi
  801cbc:	eb 3c                	jmp    801cfa <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cbe:	89 da                	mov    %ebx,%edx
  801cc0:	89 f0                	mov    %esi,%eax
  801cc2:	e8 6c ff ff ff       	call   801c33 <_pipeisclosed>
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	75 38                	jne    801d03 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ccb:	e8 5e f1 ff ff       	call   800e2e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cd0:	8b 43 04             	mov    0x4(%ebx),%eax
  801cd3:	8b 13                	mov    (%ebx),%edx
  801cd5:	83 c2 20             	add    $0x20,%edx
  801cd8:	39 d0                	cmp    %edx,%eax
  801cda:	73 e2                	jae    801cbe <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cdf:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801cea:	79 05                	jns    801cf1 <devpipe_write+0x50>
  801cec:	4a                   	dec    %edx
  801ced:	83 ca e0             	or     $0xffffffe0,%edx
  801cf0:	42                   	inc    %edx
  801cf1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cf5:	40                   	inc    %eax
  801cf6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cf9:	47                   	inc    %edi
  801cfa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cfd:	75 d1                	jne    801cd0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cff:	89 f8                	mov    %edi,%eax
  801d01:	eb 05                	jmp    801d08 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d03:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d08:	83 c4 1c             	add    $0x1c,%esp
  801d0b:	5b                   	pop    %ebx
  801d0c:	5e                   	pop    %esi
  801d0d:	5f                   	pop    %edi
  801d0e:	5d                   	pop    %ebp
  801d0f:	c3                   	ret    

00801d10 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	57                   	push   %edi
  801d14:	56                   	push   %esi
  801d15:	53                   	push   %ebx
  801d16:	83 ec 1c             	sub    $0x1c,%esp
  801d19:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d1c:	89 3c 24             	mov    %edi,(%esp)
  801d1f:	e8 fc f4 ff ff       	call   801220 <fd2data>
  801d24:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d26:	be 00 00 00 00       	mov    $0x0,%esi
  801d2b:	eb 3a                	jmp    801d67 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d2d:	85 f6                	test   %esi,%esi
  801d2f:	74 04                	je     801d35 <devpipe_read+0x25>
				return i;
  801d31:	89 f0                	mov    %esi,%eax
  801d33:	eb 40                	jmp    801d75 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d35:	89 da                	mov    %ebx,%edx
  801d37:	89 f8                	mov    %edi,%eax
  801d39:	e8 f5 fe ff ff       	call   801c33 <_pipeisclosed>
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	75 2e                	jne    801d70 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d42:	e8 e7 f0 ff ff       	call   800e2e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d47:	8b 03                	mov    (%ebx),%eax
  801d49:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d4c:	74 df                	je     801d2d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d4e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d53:	79 05                	jns    801d5a <devpipe_read+0x4a>
  801d55:	48                   	dec    %eax
  801d56:	83 c8 e0             	or     $0xffffffe0,%eax
  801d59:	40                   	inc    %eax
  801d5a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d61:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d64:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d66:	46                   	inc    %esi
  801d67:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d6a:	75 db                	jne    801d47 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d6c:	89 f0                	mov    %esi,%eax
  801d6e:	eb 05                	jmp    801d75 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d70:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d75:	83 c4 1c             	add    $0x1c,%esp
  801d78:	5b                   	pop    %ebx
  801d79:	5e                   	pop    %esi
  801d7a:	5f                   	pop    %edi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    

00801d7d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	57                   	push   %edi
  801d81:	56                   	push   %esi
  801d82:	53                   	push   %ebx
  801d83:	83 ec 3c             	sub    $0x3c,%esp
  801d86:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d89:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d8c:	89 04 24             	mov    %eax,(%esp)
  801d8f:	e8 a7 f4 ff ff       	call   80123b <fd_alloc>
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	85 c0                	test   %eax,%eax
  801d98:	0f 88 45 01 00 00    	js     801ee3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d9e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801da5:	00 
  801da6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801da9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db4:	e8 94 f0 ff ff       	call   800e4d <sys_page_alloc>
  801db9:	89 c3                	mov    %eax,%ebx
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	0f 88 20 01 00 00    	js     801ee3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dc3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801dc6:	89 04 24             	mov    %eax,(%esp)
  801dc9:	e8 6d f4 ff ff       	call   80123b <fd_alloc>
  801dce:	89 c3                	mov    %eax,%ebx
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	0f 88 f8 00 00 00    	js     801ed0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ddf:	00 
  801de0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801de3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dee:	e8 5a f0 ff ff       	call   800e4d <sys_page_alloc>
  801df3:	89 c3                	mov    %eax,%ebx
  801df5:	85 c0                	test   %eax,%eax
  801df7:	0f 88 d3 00 00 00    	js     801ed0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e00:	89 04 24             	mov    %eax,(%esp)
  801e03:	e8 18 f4 ff ff       	call   801220 <fd2data>
  801e08:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e11:	00 
  801e12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e1d:	e8 2b f0 ff ff       	call   800e4d <sys_page_alloc>
  801e22:	89 c3                	mov    %eax,%ebx
  801e24:	85 c0                	test   %eax,%eax
  801e26:	0f 88 91 00 00 00    	js     801ebd <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e2f:	89 04 24             	mov    %eax,(%esp)
  801e32:	e8 e9 f3 ff ff       	call   801220 <fd2data>
  801e37:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e3e:	00 
  801e3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e43:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e4a:	00 
  801e4b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e56:	e8 46 f0 ff ff       	call   800ea1 <sys_page_map>
  801e5b:	89 c3                	mov    %eax,%ebx
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	78 4c                	js     801ead <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e61:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e6a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e6f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e76:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e7f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e81:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e84:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e8e:	89 04 24             	mov    %eax,(%esp)
  801e91:	e8 7a f3 ff ff       	call   801210 <fd2num>
  801e96:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e98:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e9b:	89 04 24             	mov    %eax,(%esp)
  801e9e:	e8 6d f3 ff ff       	call   801210 <fd2num>
  801ea3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ea6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eab:	eb 36                	jmp    801ee3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801ead:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb8:	e8 37 f0 ff ff       	call   800ef4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801ebd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ec0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ecb:	e8 24 f0 ff ff       	call   800ef4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ed0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ede:	e8 11 f0 ff ff       	call   800ef4 <sys_page_unmap>
    err:
	return r;
}
  801ee3:	89 d8                	mov    %ebx,%eax
  801ee5:	83 c4 3c             	add    $0x3c,%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5e                   	pop    %esi
  801eea:	5f                   	pop    %edi
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    

00801eed <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ef3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efa:	8b 45 08             	mov    0x8(%ebp),%eax
  801efd:	89 04 24             	mov    %eax,(%esp)
  801f00:	e8 89 f3 ff ff       	call   80128e <fd_lookup>
  801f05:	85 c0                	test   %eax,%eax
  801f07:	78 15                	js     801f1e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0c:	89 04 24             	mov    %eax,(%esp)
  801f0f:	e8 0c f3 ff ff       	call   801220 <fd2data>
	return _pipeisclosed(fd, p);
  801f14:	89 c2                	mov    %eax,%edx
  801f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f19:	e8 15 fd ff ff       	call   801c33 <_pipeisclosed>
}
  801f1e:	c9                   	leave  
  801f1f:	c3                   	ret    

00801f20 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    

00801f2a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f30:	c7 44 24 04 6c 29 80 	movl   $0x80296c,0x4(%esp)
  801f37:	00 
  801f38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3b:	89 04 24             	mov    %eax,(%esp)
  801f3e:	e8 18 eb ff ff       	call   800a5b <strcpy>
	return 0;
}
  801f43:	b8 00 00 00 00       	mov    $0x0,%eax
  801f48:	c9                   	leave  
  801f49:	c3                   	ret    

00801f4a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	57                   	push   %edi
  801f4e:	56                   	push   %esi
  801f4f:	53                   	push   %ebx
  801f50:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f56:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f5b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f61:	eb 30                	jmp    801f93 <devcons_write+0x49>
		m = n - tot;
  801f63:	8b 75 10             	mov    0x10(%ebp),%esi
  801f66:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f68:	83 fe 7f             	cmp    $0x7f,%esi
  801f6b:	76 05                	jbe    801f72 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f6d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f72:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f76:	03 45 0c             	add    0xc(%ebp),%eax
  801f79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7d:	89 3c 24             	mov    %edi,(%esp)
  801f80:	e8 4f ec ff ff       	call   800bd4 <memmove>
		sys_cputs(buf, m);
  801f85:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f89:	89 3c 24             	mov    %edi,(%esp)
  801f8c:	e8 ef ed ff ff       	call   800d80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f91:	01 f3                	add    %esi,%ebx
  801f93:	89 d8                	mov    %ebx,%eax
  801f95:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f98:	72 c9                	jb     801f63 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f9a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801fa0:	5b                   	pop    %ebx
  801fa1:	5e                   	pop    %esi
  801fa2:	5f                   	pop    %edi
  801fa3:	5d                   	pop    %ebp
  801fa4:	c3                   	ret    

00801fa5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801fab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801faf:	75 07                	jne    801fb8 <devcons_read+0x13>
  801fb1:	eb 25                	jmp    801fd8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fb3:	e8 76 ee ff ff       	call   800e2e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fb8:	e8 e1 ed ff ff       	call   800d9e <sys_cgetc>
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	74 f2                	je     801fb3 <devcons_read+0xe>
  801fc1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	78 1d                	js     801fe4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fc7:	83 f8 04             	cmp    $0x4,%eax
  801fca:	74 13                	je     801fdf <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcf:	88 10                	mov    %dl,(%eax)
	return 1;
  801fd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd6:	eb 0c                	jmp    801fe4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801fd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fdd:	eb 05                	jmp    801fe4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fdf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fe4:	c9                   	leave  
  801fe5:	c3                   	ret    

00801fe6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801fec:	8b 45 08             	mov    0x8(%ebp),%eax
  801fef:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ff2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ff9:	00 
  801ffa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ffd:	89 04 24             	mov    %eax,(%esp)
  802000:	e8 7b ed ff ff       	call   800d80 <sys_cputs>
}
  802005:	c9                   	leave  
  802006:	c3                   	ret    

00802007 <getchar>:

int
getchar(void)
{
  802007:	55                   	push   %ebp
  802008:	89 e5                	mov    %esp,%ebp
  80200a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80200d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802014:	00 
  802015:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802018:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802023:	e8 02 f5 ff ff       	call   80152a <read>
	if (r < 0)
  802028:	85 c0                	test   %eax,%eax
  80202a:	78 0f                	js     80203b <getchar+0x34>
		return r;
	if (r < 1)
  80202c:	85 c0                	test   %eax,%eax
  80202e:	7e 06                	jle    802036 <getchar+0x2f>
		return -E_EOF;
	return c;
  802030:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802034:	eb 05                	jmp    80203b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802036:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80203b:	c9                   	leave  
  80203c:	c3                   	ret    

0080203d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
  802040:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802043:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204a:	8b 45 08             	mov    0x8(%ebp),%eax
  80204d:	89 04 24             	mov    %eax,(%esp)
  802050:	e8 39 f2 ff ff       	call   80128e <fd_lookup>
  802055:	85 c0                	test   %eax,%eax
  802057:	78 11                	js     80206a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802059:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802062:	39 10                	cmp    %edx,(%eax)
  802064:	0f 94 c0             	sete   %al
  802067:	0f b6 c0             	movzbl %al,%eax
}
  80206a:	c9                   	leave  
  80206b:	c3                   	ret    

0080206c <opencons>:

int
opencons(void)
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802072:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802075:	89 04 24             	mov    %eax,(%esp)
  802078:	e8 be f1 ff ff       	call   80123b <fd_alloc>
  80207d:	85 c0                	test   %eax,%eax
  80207f:	78 3c                	js     8020bd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802081:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802088:	00 
  802089:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802090:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802097:	e8 b1 ed ff ff       	call   800e4d <sys_page_alloc>
  80209c:	85 c0                	test   %eax,%eax
  80209e:	78 1d                	js     8020bd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020a0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020b5:	89 04 24             	mov    %eax,(%esp)
  8020b8:	e8 53 f1 ff ff       	call   801210 <fd2num>
}
  8020bd:	c9                   	leave  
  8020be:	c3                   	ret    
	...

008020c0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	56                   	push   %esi
  8020c4:	53                   	push   %ebx
  8020c5:	83 ec 10             	sub    $0x10,%esp
  8020c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8020cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  8020d1:	85 c0                	test   %eax,%eax
  8020d3:	75 05                	jne    8020da <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  8020d5:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8020da:	89 04 24             	mov    %eax,(%esp)
  8020dd:	e8 81 ef ff ff       	call   801063 <sys_ipc_recv>
	if (!err) {
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	75 26                	jne    80210c <ipc_recv+0x4c>
		if (from_env_store) {
  8020e6:	85 f6                	test   %esi,%esi
  8020e8:	74 0a                	je     8020f4 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8020ea:	a1 20 44 80 00       	mov    0x804420,%eax
  8020ef:	8b 40 74             	mov    0x74(%eax),%eax
  8020f2:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8020f4:	85 db                	test   %ebx,%ebx
  8020f6:	74 0a                	je     802102 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  8020f8:	a1 20 44 80 00       	mov    0x804420,%eax
  8020fd:	8b 40 78             	mov    0x78(%eax),%eax
  802100:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  802102:	a1 20 44 80 00       	mov    0x804420,%eax
  802107:	8b 40 70             	mov    0x70(%eax),%eax
  80210a:	eb 14                	jmp    802120 <ipc_recv+0x60>
	}
	if (from_env_store) {
  80210c:	85 f6                	test   %esi,%esi
  80210e:	74 06                	je     802116 <ipc_recv+0x56>
		*from_env_store = 0;
  802110:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  802116:	85 db                	test   %ebx,%ebx
  802118:	74 06                	je     802120 <ipc_recv+0x60>
		*perm_store = 0;
  80211a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5d                   	pop    %ebp
  802126:	c3                   	ret    

00802127 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802127:	55                   	push   %ebp
  802128:	89 e5                	mov    %esp,%ebp
  80212a:	57                   	push   %edi
  80212b:	56                   	push   %esi
  80212c:	53                   	push   %ebx
  80212d:	83 ec 1c             	sub    $0x1c,%esp
  802130:	8b 75 10             	mov    0x10(%ebp),%esi
  802133:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  802136:	85 f6                	test   %esi,%esi
  802138:	75 05                	jne    80213f <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  80213a:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  80213f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802143:	89 74 24 08          	mov    %esi,0x8(%esp)
  802147:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80214e:	8b 45 08             	mov    0x8(%ebp),%eax
  802151:	89 04 24             	mov    %eax,(%esp)
  802154:	e8 e7 ee ff ff       	call   801040 <sys_ipc_try_send>
  802159:	89 c3                	mov    %eax,%ebx
		sys_yield();
  80215b:	e8 ce ec ff ff       	call   800e2e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  802160:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802163:	74 da                	je     80213f <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  802165:	85 db                	test   %ebx,%ebx
  802167:	74 20                	je     802189 <ipc_send+0x62>
		panic("send fail: %e", err);
  802169:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80216d:	c7 44 24 08 78 29 80 	movl   $0x802978,0x8(%esp)
  802174:	00 
  802175:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  80217c:	00 
  80217d:	c7 04 24 86 29 80 00 	movl   $0x802986,(%esp)
  802184:	e8 0f e2 ff ff       	call   800398 <_panic>
	}
	return;
}
  802189:	83 c4 1c             	add    $0x1c,%esp
  80218c:	5b                   	pop    %ebx
  80218d:	5e                   	pop    %esi
  80218e:	5f                   	pop    %edi
  80218f:	5d                   	pop    %ebp
  802190:	c3                   	ret    

00802191 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802191:	55                   	push   %ebp
  802192:	89 e5                	mov    %esp,%ebp
  802194:	53                   	push   %ebx
  802195:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802198:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80219d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021a4:	89 c2                	mov    %eax,%edx
  8021a6:	c1 e2 07             	shl    $0x7,%edx
  8021a9:	29 ca                	sub    %ecx,%edx
  8021ab:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021b1:	8b 52 50             	mov    0x50(%edx),%edx
  8021b4:	39 da                	cmp    %ebx,%edx
  8021b6:	75 0f                	jne    8021c7 <ipc_find_env+0x36>
			return envs[i].env_id;
  8021b8:	c1 e0 07             	shl    $0x7,%eax
  8021bb:	29 c8                	sub    %ecx,%eax
  8021bd:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021c2:	8b 40 40             	mov    0x40(%eax),%eax
  8021c5:	eb 0c                	jmp    8021d3 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021c7:	40                   	inc    %eax
  8021c8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021cd:	75 ce                	jne    80219d <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021cf:	66 b8 00 00          	mov    $0x0,%ax
}
  8021d3:	5b                   	pop    %ebx
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    
	...

008021d8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
  8021db:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021de:	89 c2                	mov    %eax,%edx
  8021e0:	c1 ea 16             	shr    $0x16,%edx
  8021e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021ea:	f6 c2 01             	test   $0x1,%dl
  8021ed:	74 1e                	je     80220d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021ef:	c1 e8 0c             	shr    $0xc,%eax
  8021f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021f9:	a8 01                	test   $0x1,%al
  8021fb:	74 17                	je     802214 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021fd:	c1 e8 0c             	shr    $0xc,%eax
  802200:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802207:	ef 
  802208:	0f b7 c0             	movzwl %ax,%eax
  80220b:	eb 0c                	jmp    802219 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80220d:	b8 00 00 00 00       	mov    $0x0,%eax
  802212:	eb 05                	jmp    802219 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802214:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    
	...

0080221c <__udivdi3>:
  80221c:	55                   	push   %ebp
  80221d:	57                   	push   %edi
  80221e:	56                   	push   %esi
  80221f:	83 ec 10             	sub    $0x10,%esp
  802222:	8b 74 24 20          	mov    0x20(%esp),%esi
  802226:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80222a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80222e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802232:	89 cd                	mov    %ecx,%ebp
  802234:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802238:	85 c0                	test   %eax,%eax
  80223a:	75 2c                	jne    802268 <__udivdi3+0x4c>
  80223c:	39 f9                	cmp    %edi,%ecx
  80223e:	77 68                	ja     8022a8 <__udivdi3+0x8c>
  802240:	85 c9                	test   %ecx,%ecx
  802242:	75 0b                	jne    80224f <__udivdi3+0x33>
  802244:	b8 01 00 00 00       	mov    $0x1,%eax
  802249:	31 d2                	xor    %edx,%edx
  80224b:	f7 f1                	div    %ecx
  80224d:	89 c1                	mov    %eax,%ecx
  80224f:	31 d2                	xor    %edx,%edx
  802251:	89 f8                	mov    %edi,%eax
  802253:	f7 f1                	div    %ecx
  802255:	89 c7                	mov    %eax,%edi
  802257:	89 f0                	mov    %esi,%eax
  802259:	f7 f1                	div    %ecx
  80225b:	89 c6                	mov    %eax,%esi
  80225d:	89 f0                	mov    %esi,%eax
  80225f:	89 fa                	mov    %edi,%edx
  802261:	83 c4 10             	add    $0x10,%esp
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	39 f8                	cmp    %edi,%eax
  80226a:	77 2c                	ja     802298 <__udivdi3+0x7c>
  80226c:	0f bd f0             	bsr    %eax,%esi
  80226f:	83 f6 1f             	xor    $0x1f,%esi
  802272:	75 4c                	jne    8022c0 <__udivdi3+0xa4>
  802274:	39 f8                	cmp    %edi,%eax
  802276:	bf 00 00 00 00       	mov    $0x0,%edi
  80227b:	72 0a                	jb     802287 <__udivdi3+0x6b>
  80227d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802281:	0f 87 ad 00 00 00    	ja     802334 <__udivdi3+0x118>
  802287:	be 01 00 00 00       	mov    $0x1,%esi
  80228c:	89 f0                	mov    %esi,%eax
  80228e:	89 fa                	mov    %edi,%edx
  802290:	83 c4 10             	add    $0x10,%esp
  802293:	5e                   	pop    %esi
  802294:	5f                   	pop    %edi
  802295:	5d                   	pop    %ebp
  802296:	c3                   	ret    
  802297:	90                   	nop
  802298:	31 ff                	xor    %edi,%edi
  80229a:	31 f6                	xor    %esi,%esi
  80229c:	89 f0                	mov    %esi,%eax
  80229e:	89 fa                	mov    %edi,%edx
  8022a0:	83 c4 10             	add    $0x10,%esp
  8022a3:	5e                   	pop    %esi
  8022a4:	5f                   	pop    %edi
  8022a5:	5d                   	pop    %ebp
  8022a6:	c3                   	ret    
  8022a7:	90                   	nop
  8022a8:	89 fa                	mov    %edi,%edx
  8022aa:	89 f0                	mov    %esi,%eax
  8022ac:	f7 f1                	div    %ecx
  8022ae:	89 c6                	mov    %eax,%esi
  8022b0:	31 ff                	xor    %edi,%edi
  8022b2:	89 f0                	mov    %esi,%eax
  8022b4:	89 fa                	mov    %edi,%edx
  8022b6:	83 c4 10             	add    $0x10,%esp
  8022b9:	5e                   	pop    %esi
  8022ba:	5f                   	pop    %edi
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    
  8022bd:	8d 76 00             	lea    0x0(%esi),%esi
  8022c0:	89 f1                	mov    %esi,%ecx
  8022c2:	d3 e0                	shl    %cl,%eax
  8022c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022c8:	b8 20 00 00 00       	mov    $0x20,%eax
  8022cd:	29 f0                	sub    %esi,%eax
  8022cf:	89 ea                	mov    %ebp,%edx
  8022d1:	88 c1                	mov    %al,%cl
  8022d3:	d3 ea                	shr    %cl,%edx
  8022d5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022d9:	09 ca                	or     %ecx,%edx
  8022db:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022df:	89 f1                	mov    %esi,%ecx
  8022e1:	d3 e5                	shl    %cl,%ebp
  8022e3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8022e7:	89 fd                	mov    %edi,%ebp
  8022e9:	88 c1                	mov    %al,%cl
  8022eb:	d3 ed                	shr    %cl,%ebp
  8022ed:	89 fa                	mov    %edi,%edx
  8022ef:	89 f1                	mov    %esi,%ecx
  8022f1:	d3 e2                	shl    %cl,%edx
  8022f3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8022f7:	88 c1                	mov    %al,%cl
  8022f9:	d3 ef                	shr    %cl,%edi
  8022fb:	09 d7                	or     %edx,%edi
  8022fd:	89 f8                	mov    %edi,%eax
  8022ff:	89 ea                	mov    %ebp,%edx
  802301:	f7 74 24 08          	divl   0x8(%esp)
  802305:	89 d1                	mov    %edx,%ecx
  802307:	89 c7                	mov    %eax,%edi
  802309:	f7 64 24 0c          	mull   0xc(%esp)
  80230d:	39 d1                	cmp    %edx,%ecx
  80230f:	72 17                	jb     802328 <__udivdi3+0x10c>
  802311:	74 09                	je     80231c <__udivdi3+0x100>
  802313:	89 fe                	mov    %edi,%esi
  802315:	31 ff                	xor    %edi,%edi
  802317:	e9 41 ff ff ff       	jmp    80225d <__udivdi3+0x41>
  80231c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802320:	89 f1                	mov    %esi,%ecx
  802322:	d3 e2                	shl    %cl,%edx
  802324:	39 c2                	cmp    %eax,%edx
  802326:	73 eb                	jae    802313 <__udivdi3+0xf7>
  802328:	8d 77 ff             	lea    -0x1(%edi),%esi
  80232b:	31 ff                	xor    %edi,%edi
  80232d:	e9 2b ff ff ff       	jmp    80225d <__udivdi3+0x41>
  802332:	66 90                	xchg   %ax,%ax
  802334:	31 f6                	xor    %esi,%esi
  802336:	e9 22 ff ff ff       	jmp    80225d <__udivdi3+0x41>
	...

0080233c <__umoddi3>:
  80233c:	55                   	push   %ebp
  80233d:	57                   	push   %edi
  80233e:	56                   	push   %esi
  80233f:	83 ec 20             	sub    $0x20,%esp
  802342:	8b 44 24 30          	mov    0x30(%esp),%eax
  802346:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80234a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80234e:	8b 74 24 34          	mov    0x34(%esp),%esi
  802352:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802356:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80235a:	89 c7                	mov    %eax,%edi
  80235c:	89 f2                	mov    %esi,%edx
  80235e:	85 ed                	test   %ebp,%ebp
  802360:	75 16                	jne    802378 <__umoddi3+0x3c>
  802362:	39 f1                	cmp    %esi,%ecx
  802364:	0f 86 a6 00 00 00    	jbe    802410 <__umoddi3+0xd4>
  80236a:	f7 f1                	div    %ecx
  80236c:	89 d0                	mov    %edx,%eax
  80236e:	31 d2                	xor    %edx,%edx
  802370:	83 c4 20             	add    $0x20,%esp
  802373:	5e                   	pop    %esi
  802374:	5f                   	pop    %edi
  802375:	5d                   	pop    %ebp
  802376:	c3                   	ret    
  802377:	90                   	nop
  802378:	39 f5                	cmp    %esi,%ebp
  80237a:	0f 87 ac 00 00 00    	ja     80242c <__umoddi3+0xf0>
  802380:	0f bd c5             	bsr    %ebp,%eax
  802383:	83 f0 1f             	xor    $0x1f,%eax
  802386:	89 44 24 10          	mov    %eax,0x10(%esp)
  80238a:	0f 84 a8 00 00 00    	je     802438 <__umoddi3+0xfc>
  802390:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802394:	d3 e5                	shl    %cl,%ebp
  802396:	bf 20 00 00 00       	mov    $0x20,%edi
  80239b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80239f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023a3:	89 f9                	mov    %edi,%ecx
  8023a5:	d3 e8                	shr    %cl,%eax
  8023a7:	09 e8                	or     %ebp,%eax
  8023a9:	89 44 24 18          	mov    %eax,0x18(%esp)
  8023ad:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023b1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023b5:	d3 e0                	shl    %cl,%eax
  8023b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023bb:	89 f2                	mov    %esi,%edx
  8023bd:	d3 e2                	shl    %cl,%edx
  8023bf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023c3:	d3 e0                	shl    %cl,%eax
  8023c5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8023c9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023cd:	89 f9                	mov    %edi,%ecx
  8023cf:	d3 e8                	shr    %cl,%eax
  8023d1:	09 d0                	or     %edx,%eax
  8023d3:	d3 ee                	shr    %cl,%esi
  8023d5:	89 f2                	mov    %esi,%edx
  8023d7:	f7 74 24 18          	divl   0x18(%esp)
  8023db:	89 d6                	mov    %edx,%esi
  8023dd:	f7 64 24 0c          	mull   0xc(%esp)
  8023e1:	89 c5                	mov    %eax,%ebp
  8023e3:	89 d1                	mov    %edx,%ecx
  8023e5:	39 d6                	cmp    %edx,%esi
  8023e7:	72 67                	jb     802450 <__umoddi3+0x114>
  8023e9:	74 75                	je     802460 <__umoddi3+0x124>
  8023eb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8023ef:	29 e8                	sub    %ebp,%eax
  8023f1:	19 ce                	sbb    %ecx,%esi
  8023f3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 f2                	mov    %esi,%edx
  8023fb:	89 f9                	mov    %edi,%ecx
  8023fd:	d3 e2                	shl    %cl,%edx
  8023ff:	09 d0                	or     %edx,%eax
  802401:	89 f2                	mov    %esi,%edx
  802403:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802407:	d3 ea                	shr    %cl,%edx
  802409:	83 c4 20             	add    $0x20,%esp
  80240c:	5e                   	pop    %esi
  80240d:	5f                   	pop    %edi
  80240e:	5d                   	pop    %ebp
  80240f:	c3                   	ret    
  802410:	85 c9                	test   %ecx,%ecx
  802412:	75 0b                	jne    80241f <__umoddi3+0xe3>
  802414:	b8 01 00 00 00       	mov    $0x1,%eax
  802419:	31 d2                	xor    %edx,%edx
  80241b:	f7 f1                	div    %ecx
  80241d:	89 c1                	mov    %eax,%ecx
  80241f:	89 f0                	mov    %esi,%eax
  802421:	31 d2                	xor    %edx,%edx
  802423:	f7 f1                	div    %ecx
  802425:	89 f8                	mov    %edi,%eax
  802427:	e9 3e ff ff ff       	jmp    80236a <__umoddi3+0x2e>
  80242c:	89 f2                	mov    %esi,%edx
  80242e:	83 c4 20             	add    $0x20,%esp
  802431:	5e                   	pop    %esi
  802432:	5f                   	pop    %edi
  802433:	5d                   	pop    %ebp
  802434:	c3                   	ret    
  802435:	8d 76 00             	lea    0x0(%esi),%esi
  802438:	39 f5                	cmp    %esi,%ebp
  80243a:	72 04                	jb     802440 <__umoddi3+0x104>
  80243c:	39 f9                	cmp    %edi,%ecx
  80243e:	77 06                	ja     802446 <__umoddi3+0x10a>
  802440:	89 f2                	mov    %esi,%edx
  802442:	29 cf                	sub    %ecx,%edi
  802444:	19 ea                	sbb    %ebp,%edx
  802446:	89 f8                	mov    %edi,%eax
  802448:	83 c4 20             	add    $0x20,%esp
  80244b:	5e                   	pop    %esi
  80244c:	5f                   	pop    %edi
  80244d:	5d                   	pop    %ebp
  80244e:	c3                   	ret    
  80244f:	90                   	nop
  802450:	89 d1                	mov    %edx,%ecx
  802452:	89 c5                	mov    %eax,%ebp
  802454:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802458:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80245c:	eb 8d                	jmp    8023eb <__umoddi3+0xaf>
  80245e:	66 90                	xchg   %ax,%ax
  802460:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802464:	72 ea                	jb     802450 <__umoddi3+0x114>
  802466:	89 f1                	mov    %esi,%ecx
  802468:	eb 81                	jmp    8023eb <__umoddi3+0xaf>
