
_usertests:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
  return randstate;
}

int
main(int argc, char *argv[])
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 e4 f0             	and    $0xfffffff0,%esp
       6:	83 ec 10             	sub    $0x10,%esp
  printf(1, "usertests starting\n");
       9:	c7 44 24 04 e2 4d 00 	movl   $0x4de2,0x4(%esp)
      10:	00 
      11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      18:	e8 43 3b 00 00       	call   3b60 <printf>

  if(open("usertests.ran", 0) >= 0){
      1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      24:	00 
      25:	c7 04 24 f6 4d 00 00 	movl   $0x4df6,(%esp)
      2c:	e8 3f 3a 00 00       	call   3a70 <open>
      31:	85 c0                	test   %eax,%eax
      33:	78 19                	js     4e <main+0x4e>
    printf(1, "already ran user tests -- rebuild fs.img\n");
      35:	c7 44 24 04 60 55 00 	movl   $0x5560,0x4(%esp)
      3c:	00 
      3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
      44:	e8 17 3b 00 00       	call   3b60 <printf>
    exit();
      49:	e8 e2 39 00 00       	call   3a30 <exit>
  }
  close(open("usertests.ran", O_CREATE));
      4e:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
      55:	00 
      56:	c7 04 24 f6 4d 00 00 	movl   $0x4df6,(%esp)
      5d:	e8 0e 3a 00 00       	call   3a70 <open>
      62:	89 04 24             	mov    %eax,(%esp)
      65:	e8 ee 39 00 00       	call   3a58 <close>

  argptest();
      6a:	e8 51 37 00 00       	call   37c0 <argptest>
  createdelete();
      6f:	e8 84 11 00 00       	call   11f8 <createdelete>
  linkunlink();
      74:	e8 6f 1a 00 00       	call   1ae8 <linkunlink>
  concreate();
      79:	e8 8e 17 00 00       	call   180c <concreate>
  fourfiles();
      7e:	e8 89 0f 00 00       	call   100c <fourfiles>
  sharedfd();
      83:	e8 d0 0d 00 00       	call   e58 <sharedfd>

  bigargtest();
      88:	e8 6f 33 00 00       	call   33fc <bigargtest>
  bigwrite();
      8d:	e8 32 24 00 00       	call   24c4 <bigwrite>
  bigargtest();
      92:	e8 65 33 00 00       	call   33fc <bigargtest>
  bsstest();
      97:	e8 f0 32 00 00       	call   338c <bsstest>
  sbrktest();
      9c:	e8 f7 2d 00 00       	call   2e98 <sbrktest>
  validatetest();
      a1:	e8 3e 32 00 00       	call   32e4 <validatetest>

  opentest();
      a6:	e8 39 03 00 00       	call   3e4 <opentest>
  writetest();
      ab:	e8 d4 03 00 00       	call   484 <writetest>
  writetest1();
      b0:	e8 cf 05 00 00       	call   684 <writetest1>
  createtest();
      b5:	e8 aa 07 00 00       	call   864 <createtest>

  openiputtest();
      ba:	e8 25 02 00 00       	call   2e4 <openiputtest>
  exitiputtest();
      bf:	e8 3c 01 00 00       	call   200 <exitiputtest>
  iputtest();
      c4:	e8 57 00 00 00       	call   120 <iputtest>

  mem();
      c9:	e8 c6 0c 00 00       	call   d94 <mem>
  pipe1();
      ce:	e8 59 09 00 00       	call   a2c <pipe1>
  preempt();
      d3:	e8 ec 0a 00 00       	call   bc4 <preempt>
  exitwait();
      d8:	e8 33 0c 00 00       	call   d10 <exitwait>

  rmdot();
      dd:	e8 26 28 00 00       	call   2908 <rmdot>
  fourteen();
      e2:	e8 c9 26 00 00       	call   27b0 <fourteen>
  bigfile();
      e7:	e8 d0 24 00 00       	call   25bc <bigfile>
  subdir();
      ec:	e8 4b 1c 00 00       	call   1d3c <subdir>
  linktest();
      f1:	e8 be 14 00 00       	call   15b4 <linktest>
  unlinkread();
      f6:	e8 e9 12 00 00       	call   13e4 <unlinkread>
  dirfile();
      fb:	e8 98 29 00 00       	call   2a98 <dirfile>
  iref();
     100:	e8 c7 2b 00 00       	call   2ccc <iref>
  forktest();
     105:	e8 d6 2c 00 00       	call   2de0 <forktest>
  bigdir(); // slow
     10a:	e8 f1 1a 00 00       	call   1c00 <bigdir>

  uio();
     10f:	e8 2c 36 00 00       	call   3740 <uio>

  exectest();
     114:	e8 c3 08 00 00       	call   9dc <exectest>

  exit();
     119:	e8 12 39 00 00       	call   3a30 <exit>
     11e:	90                   	nop
     11f:	90                   	nop

00000120 <iputtest>:
int stdout = 1;

// does chdir() call iput(p->cwd) in a transaction?
void
iputtest(void)
{
     120:	55                   	push   %ebp
     121:	89 e5                	mov    %esp,%ebp
     123:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "iput test\n");
     126:	c7 44 24 04 88 3e 00 	movl   $0x3e88,0x4(%esp)
     12d:	00 
     12e:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     133:	89 04 24             	mov    %eax,(%esp)
     136:	e8 25 3a 00 00       	call   3b60 <printf>

  if(mkdir("iputdir") < 0){
     13b:	c7 04 24 1b 3e 00 00 	movl   $0x3e1b,(%esp)
     142:	e8 51 39 00 00       	call   3a98 <mkdir>
     147:	85 c0                	test   %eax,%eax
     149:	78 4b                	js     196 <iputtest+0x76>
    printf(stdout, "mkdir failed\n");
    exit();
  }
  if(chdir("iputdir") < 0){
     14b:	c7 04 24 1b 3e 00 00 	movl   $0x3e1b,(%esp)
     152:	e8 49 39 00 00       	call   3aa0 <chdir>
     157:	85 c0                	test   %eax,%eax
     159:	0f 88 85 00 00 00    	js     1e4 <iputtest+0xc4>
    printf(stdout, "chdir iputdir failed\n");
    exit();
  }
  if(unlink("../iputdir") < 0){
     15f:	c7 04 24 18 3e 00 00 	movl   $0x3e18,(%esp)
     166:	e8 15 39 00 00       	call   3a80 <unlink>
     16b:	85 c0                	test   %eax,%eax
     16d:	78 5b                	js     1ca <iputtest+0xaa>
    printf(stdout, "unlink ../iputdir failed\n");
    exit();
  }
  if(chdir("/") < 0){
     16f:	c7 04 24 3d 3e 00 00 	movl   $0x3e3d,(%esp)
     176:	e8 25 39 00 00       	call   3aa0 <chdir>
     17b:	85 c0                	test   %eax,%eax
     17d:	78 31                	js     1b0 <iputtest+0x90>
    printf(stdout, "chdir / failed\n");
    exit();
  }
  printf(stdout, "iput test ok\n");
     17f:	c7 44 24 04 c0 3e 00 	movl   $0x3ec0,0x4(%esp)
     186:	00 
     187:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     18c:	89 04 24             	mov    %eax,(%esp)
     18f:	e8 cc 39 00 00       	call   3b60 <printf>
}
     194:	c9                   	leave  
     195:	c3                   	ret    
iputtest(void)
{
  printf(stdout, "iput test\n");

  if(mkdir("iputdir") < 0){
    printf(stdout, "mkdir failed\n");
     196:	c7 44 24 04 f4 3d 00 	movl   $0x3df4,0x4(%esp)
     19d:	00 
     19e:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     1a3:	89 04 24             	mov    %eax,(%esp)
     1a6:	e8 b5 39 00 00       	call   3b60 <printf>
    exit();
     1ab:	e8 80 38 00 00       	call   3a30 <exit>
  if(unlink("../iputdir") < 0){
    printf(stdout, "unlink ../iputdir failed\n");
    exit();
  }
  if(chdir("/") < 0){
    printf(stdout, "chdir / failed\n");
     1b0:	c7 44 24 04 3f 3e 00 	movl   $0x3e3f,0x4(%esp)
     1b7:	00 
     1b8:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     1bd:	89 04 24             	mov    %eax,(%esp)
     1c0:	e8 9b 39 00 00       	call   3b60 <printf>
    exit();
     1c5:	e8 66 38 00 00       	call   3a30 <exit>
  if(chdir("iputdir") < 0){
    printf(stdout, "chdir iputdir failed\n");
    exit();
  }
  if(unlink("../iputdir") < 0){
    printf(stdout, "unlink ../iputdir failed\n");
     1ca:	c7 44 24 04 23 3e 00 	movl   $0x3e23,0x4(%esp)
     1d1:	00 
     1d2:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     1d7:	89 04 24             	mov    %eax,(%esp)
     1da:	e8 81 39 00 00       	call   3b60 <printf>
    exit();
     1df:	e8 4c 38 00 00       	call   3a30 <exit>
  if(mkdir("iputdir") < 0){
    printf(stdout, "mkdir failed\n");
    exit();
  }
  if(chdir("iputdir") < 0){
    printf(stdout, "chdir iputdir failed\n");
     1e4:	c7 44 24 04 02 3e 00 	movl   $0x3e02,0x4(%esp)
     1eb:	00 
     1ec:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     1f1:	89 04 24             	mov    %eax,(%esp)
     1f4:	e8 67 39 00 00       	call   3b60 <printf>
    exit();
     1f9:	e8 32 38 00 00       	call   3a30 <exit>
     1fe:	66 90                	xchg   %ax,%ax

00000200 <exitiputtest>:
}

// does exit() call iput(p->cwd) in a transaction?
void
exitiputtest(void)
{
     200:	55                   	push   %ebp
     201:	89 e5                	mov    %esp,%ebp
     203:	83 ec 18             	sub    $0x18,%esp
  int pid;

  printf(stdout, "exitiput test\n");
     206:	c7 44 24 04 4f 3e 00 	movl   $0x3e4f,0x4(%esp)
     20d:	00 
     20e:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     213:	89 04 24             	mov    %eax,(%esp)
     216:	e8 45 39 00 00       	call   3b60 <printf>

  pid = fork();
     21b:	e8 08 38 00 00       	call   3a28 <fork>
  if(pid < 0){
     220:	83 f8 00             	cmp    $0x0,%eax
     223:	7c 71                	jl     296 <exitiputtest+0x96>
    printf(stdout, "fork failed\n");
    exit();
  }
  if(pid == 0){
     225:	75 39                	jne    260 <exitiputtest+0x60>
    if(mkdir("iputdir") < 0){
     227:	c7 04 24 1b 3e 00 00 	movl   $0x3e1b,(%esp)
     22e:	e8 65 38 00 00       	call   3a98 <mkdir>
     233:	85 c0                	test   %eax,%eax
     235:	0f 88 8f 00 00 00    	js     2ca <exitiputtest+0xca>
      printf(stdout, "mkdir failed\n");
      exit();
    }
    if(chdir("iputdir") < 0){
     23b:	c7 04 24 1b 3e 00 00 	movl   $0x3e1b,(%esp)
     242:	e8 59 38 00 00       	call   3aa0 <chdir>
     247:	85 c0                	test   %eax,%eax
     249:	78 65                	js     2b0 <exitiputtest+0xb0>
      printf(stdout, "child chdir failed\n");
      exit();
    }
    if(unlink("../iputdir") < 0){
     24b:	c7 04 24 18 3e 00 00 	movl   $0x3e18,(%esp)
     252:	e8 29 38 00 00       	call   3a80 <unlink>
     257:	85 c0                	test   %eax,%eax
     259:	78 21                	js     27c <exitiputtest+0x7c>
      printf(stdout, "unlink ../iputdir failed\n");
      exit();
    }
    exit();
     25b:	e8 d0 37 00 00       	call   3a30 <exit>
  }
  wait();
     260:	e8 d3 37 00 00       	call   3a38 <wait>
  printf(stdout, "exitiput test ok\n");
     265:	c7 44 24 04 72 3e 00 	movl   $0x3e72,0x4(%esp)
     26c:	00 
     26d:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     272:	89 04 24             	mov    %eax,(%esp)
     275:	e8 e6 38 00 00       	call   3b60 <printf>
}
     27a:	c9                   	leave  
     27b:	c3                   	ret    
    if(chdir("iputdir") < 0){
      printf(stdout, "child chdir failed\n");
      exit();
    }
    if(unlink("../iputdir") < 0){
      printf(stdout, "unlink ../iputdir failed\n");
     27c:	c7 44 24 04 23 3e 00 	movl   $0x3e23,0x4(%esp)
     283:	00 
     284:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     289:	89 04 24             	mov    %eax,(%esp)
     28c:	e8 cf 38 00 00       	call   3b60 <printf>
      exit();
     291:	e8 9a 37 00 00       	call   3a30 <exit>

  printf(stdout, "exitiput test\n");

  pid = fork();
  if(pid < 0){
    printf(stdout, "fork failed\n");
     296:	c7 44 24 04 35 4d 00 	movl   $0x4d35,0x4(%esp)
     29d:	00 
     29e:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     2a3:	89 04 24             	mov    %eax,(%esp)
     2a6:	e8 b5 38 00 00       	call   3b60 <printf>
    exit();
     2ab:	e8 80 37 00 00       	call   3a30 <exit>
    if(mkdir("iputdir") < 0){
      printf(stdout, "mkdir failed\n");
      exit();
    }
    if(chdir("iputdir") < 0){
      printf(stdout, "child chdir failed\n");
     2b0:	c7 44 24 04 5e 3e 00 	movl   $0x3e5e,0x4(%esp)
     2b7:	00 
     2b8:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     2bd:	89 04 24             	mov    %eax,(%esp)
     2c0:	e8 9b 38 00 00       	call   3b60 <printf>
      exit();
     2c5:	e8 66 37 00 00       	call   3a30 <exit>
    printf(stdout, "fork failed\n");
    exit();
  }
  if(pid == 0){
    if(mkdir("iputdir") < 0){
      printf(stdout, "mkdir failed\n");
     2ca:	c7 44 24 04 f4 3d 00 	movl   $0x3df4,0x4(%esp)
     2d1:	00 
     2d2:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     2d7:	89 04 24             	mov    %eax,(%esp)
     2da:	e8 81 38 00 00       	call   3b60 <printf>
      exit();
     2df:	e8 4c 37 00 00       	call   3a30 <exit>

000002e4 <openiputtest>:
//      for(i = 0; i < 10000; i++)
//        yield();
//    }
void
openiputtest(void)
{
     2e4:	55                   	push   %ebp
     2e5:	89 e5                	mov    %esp,%ebp
     2e7:	83 ec 18             	sub    $0x18,%esp
  int pid;

  printf(stdout, "openiput test\n");
     2ea:	c7 44 24 04 84 3e 00 	movl   $0x3e84,0x4(%esp)
     2f1:	00 
     2f2:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     2f7:	89 04 24             	mov    %eax,(%esp)
     2fa:	e8 61 38 00 00       	call   3b60 <printf>
  if(mkdir("oidir") < 0){
     2ff:	c7 04 24 93 3e 00 00 	movl   $0x3e93,(%esp)
     306:	e8 8d 37 00 00       	call   3a98 <mkdir>
     30b:	85 c0                	test   %eax,%eax
     30d:	0f 88 9a 00 00 00    	js     3ad <openiputtest+0xc9>
    printf(stdout, "mkdir oidir failed\n");
    exit();
  }
  pid = fork();
     313:	e8 10 37 00 00       	call   3a28 <fork>
  if(pid < 0){
     318:	83 f8 00             	cmp    $0x0,%eax
     31b:	0f 8c a6 00 00 00    	jl     3c7 <openiputtest+0xe3>
    printf(stdout, "fork failed\n");
    exit();
  }
  if(pid == 0){
     321:	75 35                	jne    358 <openiputtest+0x74>
    int fd = open("oidir", O_RDWR);
     323:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     32a:	00 
     32b:	c7 04 24 93 3e 00 00 	movl   $0x3e93,(%esp)
     332:	e8 39 37 00 00       	call   3a70 <open>
    if(fd >= 0){
     337:	85 c0                	test   %eax,%eax
     339:	78 6d                	js     3a8 <openiputtest+0xc4>
      printf(stdout, "open directory for write succeeded\n");
     33b:	c7 44 24 04 18 4e 00 	movl   $0x4e18,0x4(%esp)
     342:	00 
     343:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     348:	89 04 24             	mov    %eax,(%esp)
     34b:	e8 10 38 00 00       	call   3b60 <printf>
      exit();
     350:	e8 db 36 00 00       	call   3a30 <exit>
     355:	8d 76 00             	lea    0x0(%esi),%esi
    }
    exit();
  }
  sleep(1);
     358:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     35f:	e8 5c 37 00 00       	call   3ac0 <sleep>
  if(unlink("oidir") != 0){
     364:	c7 04 24 93 3e 00 00 	movl   $0x3e93,(%esp)
     36b:	e8 10 37 00 00       	call   3a80 <unlink>
     370:	85 c0                	test   %eax,%eax
     372:	75 1c                	jne    390 <openiputtest+0xac>
    printf(stdout, "unlink failed\n");
    exit();
  }
  wait();
     374:	e8 bf 36 00 00       	call   3a38 <wait>
  printf(stdout, "openiput test ok\n");
     379:	c7 44 24 04 bc 3e 00 	movl   $0x3ebc,0x4(%esp)
     380:	00 
     381:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     386:	89 04 24             	mov    %eax,(%esp)
     389:	e8 d2 37 00 00       	call   3b60 <printf>
}
     38e:	c9                   	leave  
     38f:	c3                   	ret    
    }
    exit();
  }
  sleep(1);
  if(unlink("oidir") != 0){
    printf(stdout, "unlink failed\n");
     390:	c7 44 24 04 ad 3e 00 	movl   $0x3ead,0x4(%esp)
     397:	00 
     398:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     39d:	89 04 24             	mov    %eax,(%esp)
     3a0:	e8 bb 37 00 00       	call   3b60 <printf>
     3a5:	8d 76 00             	lea    0x0(%esi),%esi
    exit();
     3a8:	e8 83 36 00 00       	call   3a30 <exit>
{
  int pid;

  printf(stdout, "openiput test\n");
  if(mkdir("oidir") < 0){
    printf(stdout, "mkdir oidir failed\n");
     3ad:	c7 44 24 04 99 3e 00 	movl   $0x3e99,0x4(%esp)
     3b4:	00 
     3b5:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     3ba:	89 04 24             	mov    %eax,(%esp)
     3bd:	e8 9e 37 00 00       	call   3b60 <printf>
    exit();
     3c2:	e8 69 36 00 00       	call   3a30 <exit>
  }
  pid = fork();
  if(pid < 0){
    printf(stdout, "fork failed\n");
     3c7:	c7 44 24 04 35 4d 00 	movl   $0x4d35,0x4(%esp)
     3ce:	00 
     3cf:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     3d4:	89 04 24             	mov    %eax,(%esp)
     3d7:	e8 84 37 00 00       	call   3b60 <printf>
    exit();
     3dc:	e8 4f 36 00 00       	call   3a30 <exit>
     3e1:	8d 76 00             	lea    0x0(%esi),%esi

000003e4 <opentest>:

// simple file system tests

void
opentest(void)
{
     3e4:	55                   	push   %ebp
     3e5:	89 e5                	mov    %esp,%ebp
     3e7:	83 ec 18             	sub    $0x18,%esp
  int fd;

  printf(stdout, "open test\n");
     3ea:	c7 44 24 04 ce 3e 00 	movl   $0x3ece,0x4(%esp)
     3f1:	00 
     3f2:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     3f7:	89 04 24             	mov    %eax,(%esp)
     3fa:	e8 61 37 00 00       	call   3b60 <printf>
  fd = open("echo", 0);
     3ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     406:	00 
     407:	c7 04 24 d9 3e 00 00 	movl   $0x3ed9,(%esp)
     40e:	e8 5d 36 00 00       	call   3a70 <open>
  if(fd < 0){
     413:	85 c0                	test   %eax,%eax
     415:	78 37                	js     44e <opentest+0x6a>
    printf(stdout, "open echo failed!\n");
    exit();
  }
  close(fd);
     417:	89 04 24             	mov    %eax,(%esp)
     41a:	e8 39 36 00 00       	call   3a58 <close>
  fd = open("doesnotexist", 0);
     41f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     426:	00 
     427:	c7 04 24 f1 3e 00 00 	movl   $0x3ef1,(%esp)
     42e:	e8 3d 36 00 00       	call   3a70 <open>
  if(fd >= 0){
     433:	85 c0                	test   %eax,%eax
     435:	79 31                	jns    468 <opentest+0x84>
    printf(stdout, "open doesnotexist succeeded!\n");
    exit();
  }
  printf(stdout, "open test ok\n");
     437:	c7 44 24 04 1c 3f 00 	movl   $0x3f1c,0x4(%esp)
     43e:	00 
     43f:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     444:	89 04 24             	mov    %eax,(%esp)
     447:	e8 14 37 00 00       	call   3b60 <printf>
}
     44c:	c9                   	leave  
     44d:	c3                   	ret    
  int fd;

  printf(stdout, "open test\n");
  fd = open("echo", 0);
  if(fd < 0){
    printf(stdout, "open echo failed!\n");
     44e:	c7 44 24 04 de 3e 00 	movl   $0x3ede,0x4(%esp)
     455:	00 
     456:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     45b:	89 04 24             	mov    %eax,(%esp)
     45e:	e8 fd 36 00 00       	call   3b60 <printf>
    exit();
     463:	e8 c8 35 00 00       	call   3a30 <exit>
  }
  close(fd);
  fd = open("doesnotexist", 0);
  if(fd >= 0){
    printf(stdout, "open doesnotexist succeeded!\n");
     468:	c7 44 24 04 fe 3e 00 	movl   $0x3efe,0x4(%esp)
     46f:	00 
     470:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     475:	89 04 24             	mov    %eax,(%esp)
     478:	e8 e3 36 00 00       	call   3b60 <printf>
    exit();
     47d:	e8 ae 35 00 00       	call   3a30 <exit>
     482:	66 90                	xchg   %ax,%ax

00000484 <writetest>:
  printf(stdout, "open test ok\n");
}

void
writetest(void)
{
     484:	55                   	push   %ebp
     485:	89 e5                	mov    %esp,%ebp
     487:	56                   	push   %esi
     488:	53                   	push   %ebx
     489:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int i;

  printf(stdout, "small file test\n");
     48c:	c7 44 24 04 2a 3f 00 	movl   $0x3f2a,0x4(%esp)
     493:	00 
     494:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     499:	89 04 24             	mov    %eax,(%esp)
     49c:	e8 bf 36 00 00       	call   3b60 <printf>
  fd = open("small", O_CREATE|O_RDWR);
     4a1:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     4a8:	00 
     4a9:	c7 04 24 3b 3f 00 00 	movl   $0x3f3b,(%esp)
     4b0:	e8 bb 35 00 00       	call   3a70 <open>
     4b5:	89 c6                	mov    %eax,%esi
  if(fd >= 0){
     4b7:	85 c0                	test   %eax,%eax
     4b9:	0f 88 ab 01 00 00    	js     66a <writetest+0x1e6>
    printf(stdout, "creat small succeeded; ok\n");
     4bf:	c7 44 24 04 41 3f 00 	movl   $0x3f41,0x4(%esp)
     4c6:	00 
     4c7:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     4cc:	89 04 24             	mov    %eax,(%esp)
     4cf:	e8 8c 36 00 00       	call   3b60 <printf>
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     4d4:	31 db                	xor    %ebx,%ebx
     4d6:	66 90                	xchg   %ax,%ax
    if(write(fd, "aaaaaaaaaa", 10) != 10){
     4d8:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     4df:	00 
     4e0:	c7 44 24 04 78 3f 00 	movl   $0x3f78,0x4(%esp)
     4e7:	00 
     4e8:	89 34 24             	mov    %esi,(%esp)
     4eb:	e8 60 35 00 00       	call   3a50 <write>
     4f0:	83 f8 0a             	cmp    $0xa,%eax
     4f3:	0f 85 e7 00 00 00    	jne    5e0 <writetest+0x15c>
      printf(stdout, "error: write aa %d new file failed\n", i);
      exit();
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
     4f9:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     500:	00 
     501:	c7 44 24 04 83 3f 00 	movl   $0x3f83,0x4(%esp)
     508:	00 
     509:	89 34 24             	mov    %esi,(%esp)
     50c:	e8 3f 35 00 00       	call   3a50 <write>
     511:	83 f8 0a             	cmp    $0xa,%eax
     514:	0f 85 e4 00 00 00    	jne    5fe <writetest+0x17a>
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     51a:	43                   	inc    %ebx
     51b:	83 fb 64             	cmp    $0x64,%ebx
     51e:	75 b8                	jne    4d8 <writetest+0x54>
    if(write(fd, "bbbbbbbbbb", 10) != 10){
      printf(stdout, "error: write bb %d new file failed\n", i);
      exit();
    }
  }
  printf(stdout, "writes ok\n");
     520:	c7 44 24 04 8e 3f 00 	movl   $0x3f8e,0x4(%esp)
     527:	00 
     528:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     52d:	89 04 24             	mov    %eax,(%esp)
     530:	e8 2b 36 00 00       	call   3b60 <printf>
  close(fd);
     535:	89 34 24             	mov    %esi,(%esp)
     538:	e8 1b 35 00 00       	call   3a58 <close>
  fd = open("small", O_RDONLY);
     53d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     544:	00 
     545:	c7 04 24 3b 3f 00 00 	movl   $0x3f3b,(%esp)
     54c:	e8 1f 35 00 00       	call   3a70 <open>
     551:	89 c3                	mov    %eax,%ebx
  if(fd >= 0){
     553:	85 c0                	test   %eax,%eax
     555:	0f 88 c1 00 00 00    	js     61c <writetest+0x198>
    printf(stdout, "open small succeeded ok\n");
     55b:	c7 44 24 04 99 3f 00 	movl   $0x3f99,0x4(%esp)
     562:	00 
     563:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     568:	89 04 24             	mov    %eax,(%esp)
     56b:	e8 f0 35 00 00       	call   3b60 <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit();
  }
  i = read(fd, buf, 2000);
     570:	c7 44 24 08 d0 07 00 	movl   $0x7d0,0x8(%esp)
     577:	00 
     578:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
     57f:	00 
     580:	89 1c 24             	mov    %ebx,(%esp)
     583:	e8 c0 34 00 00       	call   3a48 <read>
  if(i == 2000){
     588:	3d d0 07 00 00       	cmp    $0x7d0,%eax
     58d:	0f 85 a3 00 00 00    	jne    636 <writetest+0x1b2>
    printf(stdout, "read succeeded ok\n");
     593:	c7 44 24 04 cd 3f 00 	movl   $0x3fcd,0x4(%esp)
     59a:	00 
     59b:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     5a0:	89 04 24             	mov    %eax,(%esp)
     5a3:	e8 b8 35 00 00       	call   3b60 <printf>
  } else {
    printf(stdout, "read failed\n");
    exit();
  }
  close(fd);
     5a8:	89 1c 24             	mov    %ebx,(%esp)
     5ab:	e8 a8 34 00 00       	call   3a58 <close>

  if(unlink("small") < 0){
     5b0:	c7 04 24 3b 3f 00 00 	movl   $0x3f3b,(%esp)
     5b7:	e8 c4 34 00 00       	call   3a80 <unlink>
     5bc:	85 c0                	test   %eax,%eax
     5be:	0f 88 8c 00 00 00    	js     650 <writetest+0x1cc>
    printf(stdout, "unlink small failed\n");
    exit();
  }
  printf(stdout, "small file test ok\n");
     5c4:	c7 44 24 04 f5 3f 00 	movl   $0x3ff5,0x4(%esp)
     5cb:	00 
     5cc:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     5d1:	89 04 24             	mov    %eax,(%esp)
     5d4:	e8 87 35 00 00       	call   3b60 <printf>
}
     5d9:	83 c4 10             	add    $0x10,%esp
     5dc:	5b                   	pop    %ebx
     5dd:	5e                   	pop    %esi
     5de:	5d                   	pop    %ebp
     5df:	c3                   	ret    
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
    if(write(fd, "aaaaaaaaaa", 10) != 10){
      printf(stdout, "error: write aa %d new file failed\n", i);
     5e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     5e4:	c7 44 24 04 3c 4e 00 	movl   $0x4e3c,0x4(%esp)
     5eb:	00 
     5ec:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     5f1:	89 04 24             	mov    %eax,(%esp)
     5f4:	e8 67 35 00 00       	call   3b60 <printf>
      exit();
     5f9:	e8 32 34 00 00       	call   3a30 <exit>
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
      printf(stdout, "error: write bb %d new file failed\n", i);
     5fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     602:	c7 44 24 04 60 4e 00 	movl   $0x4e60,0x4(%esp)
     609:	00 
     60a:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     60f:	89 04 24             	mov    %eax,(%esp)
     612:	e8 49 35 00 00       	call   3b60 <printf>
      exit();
     617:	e8 14 34 00 00       	call   3a30 <exit>
  close(fd);
  fd = open("small", O_RDONLY);
  if(fd >= 0){
    printf(stdout, "open small succeeded ok\n");
  } else {
    printf(stdout, "error: open small failed!\n");
     61c:	c7 44 24 04 b2 3f 00 	movl   $0x3fb2,0x4(%esp)
     623:	00 
     624:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     629:	89 04 24             	mov    %eax,(%esp)
     62c:	e8 2f 35 00 00       	call   3b60 <printf>
    exit();
     631:	e8 fa 33 00 00       	call   3a30 <exit>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
  } else {
    printf(stdout, "read failed\n");
     636:	c7 44 24 04 f9 42 00 	movl   $0x42f9,0x4(%esp)
     63d:	00 
     63e:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     643:	89 04 24             	mov    %eax,(%esp)
     646:	e8 15 35 00 00       	call   3b60 <printf>
    exit();
     64b:	e8 e0 33 00 00       	call   3a30 <exit>
  }
  close(fd);

  if(unlink("small") < 0){
    printf(stdout, "unlink small failed\n");
     650:	c7 44 24 04 e0 3f 00 	movl   $0x3fe0,0x4(%esp)
     657:	00 
     658:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     65d:	89 04 24             	mov    %eax,(%esp)
     660:	e8 fb 34 00 00       	call   3b60 <printf>
    exit();
     665:	e8 c6 33 00 00       	call   3a30 <exit>
  printf(stdout, "small file test\n");
  fd = open("small", O_CREATE|O_RDWR);
  if(fd >= 0){
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
     66a:	c7 44 24 04 5c 3f 00 	movl   $0x3f5c,0x4(%esp)
     671:	00 
     672:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     677:	89 04 24             	mov    %eax,(%esp)
     67a:	e8 e1 34 00 00       	call   3b60 <printf>
    exit();
     67f:	e8 ac 33 00 00       	call   3a30 <exit>

00000684 <writetest1>:
  printf(stdout, "small file test ok\n");
}

void
writetest1(void)
{
     684:	55                   	push   %ebp
     685:	89 e5                	mov    %esp,%ebp
     687:	56                   	push   %esi
     688:	53                   	push   %ebx
     689:	83 ec 10             	sub    $0x10,%esp
  int i, fd, n;

  printf(stdout, "big files test\n");
     68c:	c7 44 24 04 09 40 00 	movl   $0x4009,0x4(%esp)
     693:	00 
     694:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     699:	89 04 24             	mov    %eax,(%esp)
     69c:	e8 bf 34 00 00       	call   3b60 <printf>

  fd = open("big", O_CREATE|O_RDWR);
     6a1:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     6a8:	00 
     6a9:	c7 04 24 83 40 00 00 	movl   $0x4083,(%esp)
     6b0:	e8 bb 33 00 00       	call   3a70 <open>
     6b5:	89 c6                	mov    %eax,%esi
  if(fd < 0){
     6b7:	85 c0                	test   %eax,%eax
     6b9:	0f 88 70 01 00 00    	js     82f <writetest1+0x1ab>
     6bf:	31 db                	xor    %ebx,%ebx
     6c1:	8d 76 00             	lea    0x0(%esi),%esi
    printf(stdout, "error: creat big failed!\n");
    exit();
  }

  for(i = 0; i < MAXFILE; i++){
    ((int*)buf)[0] = i;
     6c4:	89 1d 80 86 00 00    	mov    %ebx,0x8680
    if(write(fd, buf, 512) != 512){
     6ca:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     6d1:	00 
     6d2:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
     6d9:	00 
     6da:	89 34 24             	mov    %esi,(%esp)
     6dd:	e8 6e 33 00 00       	call   3a50 <write>
     6e2:	3d 00 02 00 00       	cmp    $0x200,%eax
     6e7:	0f 85 a8 00 00 00    	jne    795 <writetest1+0x111>
  if(fd < 0){
    printf(stdout, "error: creat big failed!\n");
    exit();
  }

  for(i = 0; i < MAXFILE; i++){
     6ed:	43                   	inc    %ebx
     6ee:	81 fb 8c 00 00 00    	cmp    $0x8c,%ebx
     6f4:	75 ce                	jne    6c4 <writetest1+0x40>
      printf(stdout, "error: write big file failed\n", i);
      exit();
    }
  }

  close(fd);
     6f6:	89 34 24             	mov    %esi,(%esp)
     6f9:	e8 5a 33 00 00       	call   3a58 <close>

  fd = open("big", O_RDONLY);
     6fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     705:	00 
     706:	c7 04 24 83 40 00 00 	movl   $0x4083,(%esp)
     70d:	e8 5e 33 00 00       	call   3a70 <open>
     712:	89 c6                	mov    %eax,%esi
  if(fd < 0){
     714:	85 c0                	test   %eax,%eax
     716:	0f 88 f9 00 00 00    	js     815 <writetest1+0x191>
     71c:	31 db                	xor    %ebx,%ebx
     71e:	eb 15                	jmp    735 <writetest1+0xb1>
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
        exit();
      }
      break;
    } else if(i != 512){
     720:	3d 00 02 00 00       	cmp    $0x200,%eax
     725:	0f 85 aa 00 00 00    	jne    7d5 <writetest1+0x151>
      printf(stdout, "read failed %d\n", i);
      exit();
    }
    if(((int*)buf)[0] != n){
     72b:	a1 80 86 00 00       	mov    0x8680,%eax
     730:	39 d8                	cmp    %ebx,%eax
     732:	75 7f                	jne    7b3 <writetest1+0x12f>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
      exit();
    }
    n++;
     734:	43                   	inc    %ebx
    exit();
  }

  n = 0;
  for(;;){
    i = read(fd, buf, 512);
     735:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     73c:	00 
     73d:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
     744:	00 
     745:	89 34 24             	mov    %esi,(%esp)
     748:	e8 fb 32 00 00       	call   3a48 <read>
    if(i == 0){
     74d:	85 c0                	test   %eax,%eax
     74f:	75 cf                	jne    720 <writetest1+0x9c>
      if(n == MAXFILE - 1){
     751:	81 fb 8b 00 00 00    	cmp    $0x8b,%ebx
     757:	0f 84 96 00 00 00    	je     7f3 <writetest1+0x16f>
             n, ((int*)buf)[0]);
      exit();
    }
    n++;
  }
  close(fd);
     75d:	89 34 24             	mov    %esi,(%esp)
     760:	e8 f3 32 00 00       	call   3a58 <close>
  if(unlink("big") < 0){
     765:	c7 04 24 83 40 00 00 	movl   $0x4083,(%esp)
     76c:	e8 0f 33 00 00       	call   3a80 <unlink>
     771:	85 c0                	test   %eax,%eax
     773:	0f 88 d0 00 00 00    	js     849 <writetest1+0x1c5>
    printf(stdout, "unlink big failed\n");
    exit();
  }
  printf(stdout, "big files ok\n");
     779:	c7 44 24 04 aa 40 00 	movl   $0x40aa,0x4(%esp)
     780:	00 
     781:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     786:	89 04 24             	mov    %eax,(%esp)
     789:	e8 d2 33 00 00       	call   3b60 <printf>
}
     78e:	83 c4 10             	add    $0x10,%esp
     791:	5b                   	pop    %ebx
     792:	5e                   	pop    %esi
     793:	5d                   	pop    %ebp
     794:	c3                   	ret    
  }

  for(i = 0; i < MAXFILE; i++){
    ((int*)buf)[0] = i;
    if(write(fd, buf, 512) != 512){
      printf(stdout, "error: write big file failed\n", i);
     795:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     799:	c7 44 24 04 33 40 00 	movl   $0x4033,0x4(%esp)
     7a0:	00 
     7a1:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     7a6:	89 04 24             	mov    %eax,(%esp)
     7a9:	e8 b2 33 00 00       	call   3b60 <printf>
      exit();
     7ae:	e8 7d 32 00 00       	call   3a30 <exit>
    } else if(i != 512){
      printf(stdout, "read failed %d\n", i);
      exit();
    }
    if(((int*)buf)[0] != n){
      printf(stdout, "read content of block %d is %d\n",
     7b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
     7b7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
     7bb:	c7 44 24 04 84 4e 00 	movl   $0x4e84,0x4(%esp)
     7c2:	00 
     7c3:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     7c8:	89 04 24             	mov    %eax,(%esp)
     7cb:	e8 90 33 00 00       	call   3b60 <printf>
             n, ((int*)buf)[0]);
      exit();
     7d0:	e8 5b 32 00 00       	call   3a30 <exit>
        printf(stdout, "read only %d blocks from big", n);
        exit();
      }
      break;
    } else if(i != 512){
      printf(stdout, "read failed %d\n", i);
     7d5:	89 44 24 08          	mov    %eax,0x8(%esp)
     7d9:	c7 44 24 04 87 40 00 	movl   $0x4087,0x4(%esp)
     7e0:	00 
     7e1:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     7e6:	89 04 24             	mov    %eax,(%esp)
     7e9:	e8 72 33 00 00       	call   3b60 <printf>
      exit();
     7ee:	e8 3d 32 00 00       	call   3a30 <exit>
  n = 0;
  for(;;){
    i = read(fd, buf, 512);
    if(i == 0){
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
     7f3:	c7 44 24 08 8b 00 00 	movl   $0x8b,0x8(%esp)
     7fa:	00 
     7fb:	c7 44 24 04 6a 40 00 	movl   $0x406a,0x4(%esp)
     802:	00 
     803:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     808:	89 04 24             	mov    %eax,(%esp)
     80b:	e8 50 33 00 00       	call   3b60 <printf>
        exit();
     810:	e8 1b 32 00 00       	call   3a30 <exit>

  close(fd);

  fd = open("big", O_RDONLY);
  if(fd < 0){
    printf(stdout, "error: open big failed!\n");
     815:	c7 44 24 04 51 40 00 	movl   $0x4051,0x4(%esp)
     81c:	00 
     81d:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     822:	89 04 24             	mov    %eax,(%esp)
     825:	e8 36 33 00 00       	call   3b60 <printf>
    exit();
     82a:	e8 01 32 00 00       	call   3a30 <exit>

  printf(stdout, "big files test\n");

  fd = open("big", O_CREATE|O_RDWR);
  if(fd < 0){
    printf(stdout, "error: creat big failed!\n");
     82f:	c7 44 24 04 19 40 00 	movl   $0x4019,0x4(%esp)
     836:	00 
     837:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     83c:	89 04 24             	mov    %eax,(%esp)
     83f:	e8 1c 33 00 00       	call   3b60 <printf>
    exit();
     844:	e8 e7 31 00 00       	call   3a30 <exit>
    }
    n++;
  }
  close(fd);
  if(unlink("big") < 0){
    printf(stdout, "unlink big failed\n");
     849:	c7 44 24 04 97 40 00 	movl   $0x4097,0x4(%esp)
     850:	00 
     851:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     856:	89 04 24             	mov    %eax,(%esp)
     859:	e8 02 33 00 00       	call   3b60 <printf>
    exit();
     85e:	e8 cd 31 00 00       	call   3a30 <exit>
     863:	90                   	nop

00000864 <createtest>:
  printf(stdout, "big files ok\n");
}

void
createtest(void)
{
     864:	55                   	push   %ebp
     865:	89 e5                	mov    %esp,%ebp
     867:	53                   	push   %ebx
     868:	83 ec 14             	sub    $0x14,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
     86b:	c7 44 24 04 a4 4e 00 	movl   $0x4ea4,0x4(%esp)
     872:	00 
     873:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     878:	89 04 24             	mov    %eax,(%esp)
     87b:	e8 e0 32 00 00       	call   3b60 <printf>

  name[0] = 'a';
     880:	c6 05 80 a6 00 00 61 	movb   $0x61,0xa680
  name[2] = '\0';
     887:	c6 05 82 a6 00 00 00 	movb   $0x0,0xa682
     88e:	b3 30                	mov    $0x30,%bl
  for(i = 0; i < 52; i++){
    name[1] = '0' + i;
     890:	88 1d 81 a6 00 00    	mov    %bl,0xa681
    fd = open(name, O_CREATE|O_RDWR);
     896:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     89d:	00 
     89e:	c7 04 24 80 a6 00 00 	movl   $0xa680,(%esp)
     8a5:	e8 c6 31 00 00       	call   3a70 <open>
    close(fd);
     8aa:	89 04 24             	mov    %eax,(%esp)
     8ad:	e8 a6 31 00 00       	call   3a58 <close>
     8b2:	43                   	inc    %ebx

  printf(stdout, "many creates, followed by unlink test\n");

  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     8b3:	80 fb 64             	cmp    $0x64,%bl
     8b6:	75 d8                	jne    890 <createtest+0x2c>
    name[1] = '0' + i;
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
     8b8:	c6 05 80 a6 00 00 61 	movb   $0x61,0xa680
  name[2] = '\0';
     8bf:	c6 05 82 a6 00 00 00 	movb   $0x0,0xa682
     8c6:	b3 30                	mov    $0x30,%bl
  for(i = 0; i < 52; i++){
    name[1] = '0' + i;
     8c8:	88 1d 81 a6 00 00    	mov    %bl,0xa681
    unlink(name);
     8ce:	c7 04 24 80 a6 00 00 	movl   $0xa680,(%esp)
     8d5:	e8 a6 31 00 00       	call   3a80 <unlink>
     8da:	43                   	inc    %ebx
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     8db:	80 fb 64             	cmp    $0x64,%bl
     8de:	75 e8                	jne    8c8 <createtest+0x64>
    name[1] = '0' + i;
    unlink(name);
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
     8e0:	c7 44 24 04 cc 4e 00 	movl   $0x4ecc,0x4(%esp)
     8e7:	00 
     8e8:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     8ed:	89 04 24             	mov    %eax,(%esp)
     8f0:	e8 6b 32 00 00       	call   3b60 <printf>
}
     8f5:	83 c4 14             	add    $0x14,%esp
     8f8:	5b                   	pop    %ebx
     8f9:	5d                   	pop    %ebp
     8fa:	c3                   	ret    
     8fb:	90                   	nop

000008fc <dirtest>:

void dirtest(void)
{
     8fc:	55                   	push   %ebp
     8fd:	89 e5                	mov    %esp,%ebp
     8ff:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "mkdir test\n");
     902:	c7 44 24 04 b8 40 00 	movl   $0x40b8,0x4(%esp)
     909:	00 
     90a:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     90f:	89 04 24             	mov    %eax,(%esp)
     912:	e8 49 32 00 00       	call   3b60 <printf>

  if(mkdir("dir0") < 0){
     917:	c7 04 24 c4 40 00 00 	movl   $0x40c4,(%esp)
     91e:	e8 75 31 00 00       	call   3a98 <mkdir>
     923:	85 c0                	test   %eax,%eax
     925:	78 4b                	js     972 <dirtest+0x76>
    printf(stdout, "mkdir failed\n");
    exit();
  }

  if(chdir("dir0") < 0){
     927:	c7 04 24 c4 40 00 00 	movl   $0x40c4,(%esp)
     92e:	e8 6d 31 00 00       	call   3aa0 <chdir>
     933:	85 c0                	test   %eax,%eax
     935:	0f 88 85 00 00 00    	js     9c0 <dirtest+0xc4>
    printf(stdout, "chdir dir0 failed\n");
    exit();
  }

  if(chdir("..") < 0){
     93b:	c7 04 24 69 46 00 00 	movl   $0x4669,(%esp)
     942:	e8 59 31 00 00       	call   3aa0 <chdir>
     947:	85 c0                	test   %eax,%eax
     949:	78 5b                	js     9a6 <dirtest+0xaa>
    printf(stdout, "chdir .. failed\n");
    exit();
  }

  if(unlink("dir0") < 0){
     94b:	c7 04 24 c4 40 00 00 	movl   $0x40c4,(%esp)
     952:	e8 29 31 00 00       	call   3a80 <unlink>
     957:	85 c0                	test   %eax,%eax
     959:	78 31                	js     98c <dirtest+0x90>
    printf(stdout, "unlink dir0 failed\n");
    exit();
  }
  printf(stdout, "mkdir test ok\n");
     95b:	c7 44 24 04 01 41 00 	movl   $0x4101,0x4(%esp)
     962:	00 
     963:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     968:	89 04 24             	mov    %eax,(%esp)
     96b:	e8 f0 31 00 00       	call   3b60 <printf>
}
     970:	c9                   	leave  
     971:	c3                   	ret    
void dirtest(void)
{
  printf(stdout, "mkdir test\n");

  if(mkdir("dir0") < 0){
    printf(stdout, "mkdir failed\n");
     972:	c7 44 24 04 f4 3d 00 	movl   $0x3df4,0x4(%esp)
     979:	00 
     97a:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     97f:	89 04 24             	mov    %eax,(%esp)
     982:	e8 d9 31 00 00       	call   3b60 <printf>
    exit();
     987:	e8 a4 30 00 00       	call   3a30 <exit>
    printf(stdout, "chdir .. failed\n");
    exit();
  }

  if(unlink("dir0") < 0){
    printf(stdout, "unlink dir0 failed\n");
     98c:	c7 44 24 04 ed 40 00 	movl   $0x40ed,0x4(%esp)
     993:	00 
     994:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     999:	89 04 24             	mov    %eax,(%esp)
     99c:	e8 bf 31 00 00       	call   3b60 <printf>
    exit();
     9a1:	e8 8a 30 00 00       	call   3a30 <exit>
    printf(stdout, "chdir dir0 failed\n");
    exit();
  }

  if(chdir("..") < 0){
    printf(stdout, "chdir .. failed\n");
     9a6:	c7 44 24 04 dc 40 00 	movl   $0x40dc,0x4(%esp)
     9ad:	00 
     9ae:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     9b3:	89 04 24             	mov    %eax,(%esp)
     9b6:	e8 a5 31 00 00       	call   3b60 <printf>
    exit();
     9bb:	e8 70 30 00 00       	call   3a30 <exit>
    printf(stdout, "mkdir failed\n");
    exit();
  }

  if(chdir("dir0") < 0){
    printf(stdout, "chdir dir0 failed\n");
     9c0:	c7 44 24 04 c9 40 00 	movl   $0x40c9,0x4(%esp)
     9c7:	00 
     9c8:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     9cd:	89 04 24             	mov    %eax,(%esp)
     9d0:	e8 8b 31 00 00       	call   3b60 <printf>
    exit();
     9d5:	e8 56 30 00 00       	call   3a30 <exit>
     9da:	66 90                	xchg   %ax,%ax

000009dc <exectest>:
  printf(stdout, "mkdir test ok\n");
}

void
exectest(void)
{
     9dc:	55                   	push   %ebp
     9dd:	89 e5                	mov    %esp,%ebp
     9df:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "exec test\n");
     9e2:	c7 44 24 04 10 41 00 	movl   $0x4110,0x4(%esp)
     9e9:	00 
     9ea:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     9ef:	89 04 24             	mov    %eax,(%esp)
     9f2:	e8 69 31 00 00       	call   3b60 <printf>
  if(exec("echo", echoargv) < 0){
     9f7:	c7 44 24 04 a8 5e 00 	movl   $0x5ea8,0x4(%esp)
     9fe:	00 
     9ff:	c7 04 24 d9 3e 00 00 	movl   $0x3ed9,(%esp)
     a06:	e8 5d 30 00 00       	call   3a68 <exec>
     a0b:	85 c0                	test   %eax,%eax
     a0d:	78 02                	js     a11 <exectest+0x35>
    printf(stdout, "exec echo failed\n");
    exit();
  }
}
     a0f:	c9                   	leave  
     a10:	c3                   	ret    
void
exectest(void)
{
  printf(stdout, "exec test\n");
  if(exec("echo", echoargv) < 0){
    printf(stdout, "exec echo failed\n");
     a11:	c7 44 24 04 1b 41 00 	movl   $0x411b,0x4(%esp)
     a18:	00 
     a19:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
     a1e:	89 04 24             	mov    %eax,(%esp)
     a21:	e8 3a 31 00 00       	call   3b60 <printf>
    exit();
     a26:	e8 05 30 00 00       	call   3a30 <exit>
     a2b:	90                   	nop

00000a2c <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     a2c:	55                   	push   %ebp
     a2d:	89 e5                	mov    %esp,%ebp
     a2f:	57                   	push   %edi
     a30:	56                   	push   %esi
     a31:	53                   	push   %ebx
     a32:	83 ec 2c             	sub    $0x2c,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     a35:	8d 45 e0             	lea    -0x20(%ebp),%eax
     a38:	89 04 24             	mov    %eax,(%esp)
     a3b:	e8 00 30 00 00       	call   3a40 <pipe>
     a40:	85 c0                	test   %eax,%eax
     a42:	0f 85 30 01 00 00    	jne    b78 <pipe1+0x14c>
    printf(1, "pipe() failed\n");
    exit();
  }
  pid = fork();
     a48:	e8 db 2f 00 00       	call   3a28 <fork>
  seq = 0;
  if(pid == 0){
     a4d:	83 f8 00             	cmp    $0x0,%eax
     a50:	74 7f                	je     ad1 <pipe1+0xa5>
        printf(1, "pipe1 oops 1\n");
        exit();
      }
    }
    exit();
  } else if(pid > 0){
     a52:	0f 8e 39 01 00 00    	jle    b91 <pipe1+0x165>
    close(fds[1]);
     a58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     a5b:	89 04 24             	mov    %eax,(%esp)
     a5e:	e8 f5 2f 00 00       	call   3a58 <close>
    total = 0;
     a63:	31 ff                	xor    %edi,%edi
    cc = 1;
     a65:	be 01 00 00 00       	mov    $0x1,%esi
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit();
  }
  pid = fork();
  seq = 0;
     a6a:	31 db                	xor    %ebx,%ebx
    exit();
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
     a6c:	89 74 24 08          	mov    %esi,0x8(%esp)
     a70:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
     a77:	00 
     a78:	8b 45 e0             	mov    -0x20(%ebp),%eax
     a7b:	89 04 24             	mov    %eax,(%esp)
     a7e:	e8 c5 2f 00 00       	call   3a48 <read>
     a83:	85 c0                	test   %eax,%eax
     a85:	0f 8e a2 00 00 00    	jle    b2d <pipe1+0x101>
}

// simple fork and pipe read/write

void
pipe1(void)
     a8b:	8d 0c 03             	lea    (%ebx,%eax,1),%ecx
     a8e:	89 da                	mov    %ebx,%edx
     a90:	f7 da                	neg    %edx
     a92:	66 90                	xchg   %ax,%ax
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     a94:	38 9c 13 80 86 00 00 	cmp    %bl,0x8680(%ebx,%edx,1)
     a9b:	75 18                	jne    ab5 <pipe1+0x89>
     a9d:	43                   	inc    %ebx
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
     a9e:	39 cb                	cmp    %ecx,%ebx
     aa0:	75 f2                	jne    a94 <pipe1+0x68>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
          printf(1, "pipe1 oops 2\n");
          return;
        }
      }
      total += n;
     aa2:	01 c7                	add    %eax,%edi
      cc = cc * 2;
     aa4:	d1 e6                	shl    %esi
      if(cc > sizeof(buf))
     aa6:	81 fe 00 20 00 00    	cmp    $0x2000,%esi
     aac:	76 be                	jbe    a6c <pipe1+0x40>
        cc = sizeof(buf);
     aae:	be 00 20 00 00       	mov    $0x2000,%esi
     ab3:	eb b7                	jmp    a6c <pipe1+0x40>
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
        if((buf[i] & 0xff) != (seq++ & 0xff)){
          printf(1, "pipe1 oops 2\n");
     ab5:	c7 44 24 04 4a 41 00 	movl   $0x414a,0x4(%esp)
     abc:	00 
     abd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ac4:	e8 97 30 00 00       	call   3b60 <printf>
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
}
     ac9:	83 c4 2c             	add    $0x2c,%esp
     acc:	5b                   	pop    %ebx
     acd:	5e                   	pop    %esi
     ace:	5f                   	pop    %edi
     acf:	5d                   	pop    %ebp
     ad0:	c3                   	ret    
    exit();
  }
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
     ad1:	8b 45 e0             	mov    -0x20(%ebp),%eax
     ad4:	89 04 24             	mov    %eax,(%esp)
     ad7:	e8 7c 2f 00 00       	call   3a58 <close>
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit();
  }
  pid = fork();
  seq = 0;
     adc:	31 f6                	xor    %esi,%esi
}

// simple fork and pipe read/write

void
pipe1(void)
     ade:	8d 96 09 04 00 00    	lea    0x409(%esi),%edx
     ae4:	89 f3                	mov    %esi,%ebx
     ae6:	89 f0                	mov    %esi,%eax
     ae8:	f7 d8                	neg    %eax
     aea:	66 90                	xchg   %ax,%ax
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
        buf[i] = seq++;
     aec:	88 9c 18 80 86 00 00 	mov    %bl,0x8680(%eax,%ebx,1)
     af3:	43                   	inc    %ebx
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
     af4:	39 d3                	cmp    %edx,%ebx
     af6:	75 f4                	jne    aec <pipe1+0xc0>
     af8:	89 de                	mov    %ebx,%esi
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
     afa:	c7 44 24 08 09 04 00 	movl   $0x409,0x8(%esp)
     b01:	00 
     b02:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
     b09:	00 
     b0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     b0d:	89 04 24             	mov    %eax,(%esp)
     b10:	e8 3b 2f 00 00       	call   3a50 <write>
     b15:	3d 09 04 00 00       	cmp    $0x409,%eax
     b1a:	0f 85 8a 00 00 00    	jne    baa <pipe1+0x17e>
  }
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
     b20:	81 fb 2d 14 00 00    	cmp    $0x142d,%ebx
     b26:	75 b6                	jne    ade <pipe1+0xb2>
      if(cc > sizeof(buf))
        cc = sizeof(buf);
    }
    if(total != 5 * 1033){
      printf(1, "pipe1 oops 3 total %d\n", total);
      exit();
     b28:	e8 03 2f 00 00       	call   3a30 <exit>
      total += n;
      cc = cc * 2;
      if(cc > sizeof(buf))
        cc = sizeof(buf);
    }
    if(total != 5 * 1033){
     b2d:	81 ff 2d 14 00 00    	cmp    $0x142d,%edi
     b33:	75 29                	jne    b5e <pipe1+0x132>
      printf(1, "pipe1 oops 3 total %d\n", total);
      exit();
    }
    close(fds[0]);
     b35:	8b 45 e0             	mov    -0x20(%ebp),%eax
     b38:	89 04 24             	mov    %eax,(%esp)
     b3b:	e8 18 2f 00 00       	call   3a58 <close>
    wait();
     b40:	e8 f3 2e 00 00       	call   3a38 <wait>
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
     b45:	c7 44 24 04 6f 41 00 	movl   $0x416f,0x4(%esp)
     b4c:	00 
     b4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b54:	e8 07 30 00 00       	call   3b60 <printf>
     b59:	e9 6b ff ff ff       	jmp    ac9 <pipe1+0x9d>
      cc = cc * 2;
      if(cc > sizeof(buf))
        cc = sizeof(buf);
    }
    if(total != 5 * 1033){
      printf(1, "pipe1 oops 3 total %d\n", total);
     b5e:	89 7c 24 08          	mov    %edi,0x8(%esp)
     b62:	c7 44 24 04 58 41 00 	movl   $0x4158,0x4(%esp)
     b69:	00 
     b6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b71:	e8 ea 2f 00 00       	call   3b60 <printf>
     b76:	eb b0                	jmp    b28 <pipe1+0xfc>
{
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
     b78:	c7 44 24 04 2d 41 00 	movl   $0x412d,0x4(%esp)
     b7f:	00 
     b80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b87:	e8 d4 2f 00 00       	call   3b60 <printf>
    exit();
     b8c:	e8 9f 2e 00 00       	call   3a30 <exit>
      exit();
    }
    close(fds[0]);
    wait();
  } else {
    printf(1, "fork() failed\n");
     b91:	c7 44 24 04 79 41 00 	movl   $0x4179,0x4(%esp)
     b98:	00 
     b99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ba0:	e8 bb 2f 00 00       	call   3b60 <printf>
    exit();
     ba5:	e8 86 2e 00 00       	call   3a30 <exit>
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
        printf(1, "pipe1 oops 1\n");
     baa:	c7 44 24 04 3c 41 00 	movl   $0x413c,0x4(%esp)
     bb1:	00 
     bb2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     bb9:	e8 a2 2f 00 00       	call   3b60 <printf>
        exit();
     bbe:	e8 6d 2e 00 00       	call   3a30 <exit>
     bc3:	90                   	nop

00000bc4 <preempt>:
}

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     bc4:	55                   	push   %ebp
     bc5:	89 e5                	mov    %esp,%ebp
     bc7:	57                   	push   %edi
     bc8:	56                   	push   %esi
     bc9:	53                   	push   %ebx
     bca:	83 ec 2c             	sub    $0x2c,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     bcd:	c7 44 24 04 88 41 00 	movl   $0x4188,0x4(%esp)
     bd4:	00 
     bd5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     bdc:	e8 7f 2f 00 00       	call   3b60 <printf>
  pid1 = fork();
     be1:	e8 42 2e 00 00       	call   3a28 <fork>
     be6:	89 c7                	mov    %eax,%edi
  if(pid1 == 0)
     be8:	85 c0                	test   %eax,%eax
     bea:	75 02                	jne    bee <preempt+0x2a>
     bec:	eb fe                	jmp    bec <preempt+0x28>
    for(;;)
      ;

  pid2 = fork();
     bee:	e8 35 2e 00 00       	call   3a28 <fork>
     bf3:	89 c6                	mov    %eax,%esi
  if(pid2 == 0)
     bf5:	85 c0                	test   %eax,%eax
     bf7:	75 02                	jne    bfb <preempt+0x37>
     bf9:	eb fe                	jmp    bf9 <preempt+0x35>
    for(;;)
      ;

  pipe(pfds);
     bfb:	8d 45 e0             	lea    -0x20(%ebp),%eax
     bfe:	89 04 24             	mov    %eax,(%esp)
     c01:	e8 3a 2e 00 00       	call   3a40 <pipe>
  pid3 = fork();
     c06:	e8 1d 2e 00 00       	call   3a28 <fork>
     c0b:	89 c3                	mov    %eax,%ebx
  if(pid3 == 0){
     c0d:	85 c0                	test   %eax,%eax
     c0f:	75 4a                	jne    c5b <preempt+0x97>
    close(pfds[0]);
     c11:	8b 45 e0             	mov    -0x20(%ebp),%eax
     c14:	89 04 24             	mov    %eax,(%esp)
     c17:	e8 3c 2e 00 00       	call   3a58 <close>
    if(write(pfds[1], "x", 1) != 1)
     c1c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     c23:	00 
     c24:	c7 44 24 04 4d 47 00 	movl   $0x474d,0x4(%esp)
     c2b:	00 
     c2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c2f:	89 04 24             	mov    %eax,(%esp)
     c32:	e8 19 2e 00 00       	call   3a50 <write>
     c37:	48                   	dec    %eax
     c38:	74 14                	je     c4e <preempt+0x8a>
      printf(1, "preempt write error");
     c3a:	c7 44 24 04 92 41 00 	movl   $0x4192,0x4(%esp)
     c41:	00 
     c42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c49:	e8 12 2f 00 00       	call   3b60 <printf>
    close(pfds[1]);
     c4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c51:	89 04 24             	mov    %eax,(%esp)
     c54:	e8 ff 2d 00 00       	call   3a58 <close>
     c59:	eb fe                	jmp    c59 <preempt+0x95>
    for(;;)
      ;
  }

  close(pfds[1]);
     c5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c5e:	89 04 24             	mov    %eax,(%esp)
     c61:	e8 f2 2d 00 00       	call   3a58 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     c66:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
     c6d:	00 
     c6e:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
     c75:	00 
     c76:	8b 45 e0             	mov    -0x20(%ebp),%eax
     c79:	89 04 24             	mov    %eax,(%esp)
     c7c:	e8 c7 2d 00 00       	call   3a48 <read>
     c81:	48                   	dec    %eax
     c82:	74 1c                	je     ca0 <preempt+0xdc>
    printf(1, "preempt read error");
     c84:	c7 44 24 04 a6 41 00 	movl   $0x41a6,0x4(%esp)
     c8b:	00 
     c8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c93:	e8 c8 2e 00 00       	call   3b60 <printf>
  printf(1, "wait... ");
  wait();
  wait();
  wait();
  printf(1, "preempt ok\n");
}
     c98:	83 c4 2c             	add    $0x2c,%esp
     c9b:	5b                   	pop    %ebx
     c9c:	5e                   	pop    %esi
     c9d:	5f                   	pop    %edi
     c9e:	5d                   	pop    %ebp
     c9f:	c3                   	ret    
  close(pfds[1]);
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    printf(1, "preempt read error");
    return;
  }
  close(pfds[0]);
     ca0:	8b 45 e0             	mov    -0x20(%ebp),%eax
     ca3:	89 04 24             	mov    %eax,(%esp)
     ca6:	e8 ad 2d 00 00       	call   3a58 <close>
  printf(1, "kill... ");
     cab:	c7 44 24 04 b9 41 00 	movl   $0x41b9,0x4(%esp)
     cb2:	00 
     cb3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     cba:	e8 a1 2e 00 00       	call   3b60 <printf>
  kill(pid1);
     cbf:	89 3c 24             	mov    %edi,(%esp)
     cc2:	e8 99 2d 00 00       	call   3a60 <kill>
  kill(pid2);
     cc7:	89 34 24             	mov    %esi,(%esp)
     cca:	e8 91 2d 00 00       	call   3a60 <kill>
  kill(pid3);
     ccf:	89 1c 24             	mov    %ebx,(%esp)
     cd2:	e8 89 2d 00 00       	call   3a60 <kill>
  printf(1, "wait... ");
     cd7:	c7 44 24 04 c2 41 00 	movl   $0x41c2,0x4(%esp)
     cde:	00 
     cdf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ce6:	e8 75 2e 00 00       	call   3b60 <printf>
  wait();
     ceb:	e8 48 2d 00 00       	call   3a38 <wait>
  wait();
     cf0:	e8 43 2d 00 00       	call   3a38 <wait>
  wait();
     cf5:	e8 3e 2d 00 00       	call   3a38 <wait>
  printf(1, "preempt ok\n");
     cfa:	c7 44 24 04 cb 41 00 	movl   $0x41cb,0x4(%esp)
     d01:	00 
     d02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d09:	e8 52 2e 00 00       	call   3b60 <printf>
     d0e:	eb 88                	jmp    c98 <preempt+0xd4>

00000d10 <exitwait>:
}

// try to find any races between exit and wait
void
exitwait(void)
{
     d10:	55                   	push   %ebp
     d11:	89 e5                	mov    %esp,%ebp
     d13:	56                   	push   %esi
     d14:	53                   	push   %ebx
     d15:	83 ec 10             	sub    $0x10,%esp
     d18:	be 64 00 00 00       	mov    $0x64,%esi
     d1d:	eb 0f                	jmp    d2e <exitwait+0x1e>
     d1f:	90                   	nop
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
      return;
    }
    if(pid){
     d20:	74 6d                	je     d8f <exitwait+0x7f>
      if(wait() != pid){
     d22:	e8 11 2d 00 00       	call   3a38 <wait>
     d27:	39 d8                	cmp    %ebx,%eax
     d29:	75 2d                	jne    d58 <exitwait+0x48>
void
exitwait(void)
{
  int i, pid;

  for(i = 0; i < 100; i++){
     d2b:	4e                   	dec    %esi
     d2c:	74 46                	je     d74 <exitwait+0x64>
    pid = fork();
     d2e:	e8 f5 2c 00 00       	call   3a28 <fork>
     d33:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
     d35:	83 f8 00             	cmp    $0x0,%eax
     d38:	7d e6                	jge    d20 <exitwait+0x10>
      printf(1, "fork failed\n");
     d3a:	c7 44 24 04 35 4d 00 	movl   $0x4d35,0x4(%esp)
     d41:	00 
     d42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d49:	e8 12 2e 00 00       	call   3b60 <printf>
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
}
     d4e:	83 c4 10             	add    $0x10,%esp
     d51:	5b                   	pop    %ebx
     d52:	5e                   	pop    %esi
     d53:	5d                   	pop    %ebp
     d54:	c3                   	ret    
     d55:	8d 76 00             	lea    0x0(%esi),%esi
      printf(1, "fork failed\n");
      return;
    }
    if(pid){
      if(wait() != pid){
        printf(1, "wait wrong pid\n");
     d58:	c7 44 24 04 d7 41 00 	movl   $0x41d7,0x4(%esp)
     d5f:	00 
     d60:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d67:	e8 f4 2d 00 00       	call   3b60 <printf>
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
}
     d6c:	83 c4 10             	add    $0x10,%esp
     d6f:	5b                   	pop    %ebx
     d70:	5e                   	pop    %esi
     d71:	5d                   	pop    %ebp
     d72:	c3                   	ret    
     d73:	90                   	nop
      }
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
     d74:	c7 44 24 04 e7 41 00 	movl   $0x41e7,0x4(%esp)
     d7b:	00 
     d7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d83:	e8 d8 2d 00 00       	call   3b60 <printf>
}
     d88:	83 c4 10             	add    $0x10,%esp
     d8b:	5b                   	pop    %ebx
     d8c:	5e                   	pop    %esi
     d8d:	5d                   	pop    %ebp
     d8e:	c3                   	ret    
      if(wait() != pid){
        printf(1, "wait wrong pid\n");
        return;
      }
    } else {
      exit();
     d8f:	e8 9c 2c 00 00       	call   3a30 <exit>

00000d94 <mem>:
  printf(1, "exitwait ok\n");
}

void
mem(void)
{
     d94:	55                   	push   %ebp
     d95:	89 e5                	mov    %esp,%ebp
     d97:	57                   	push   %edi
     d98:	56                   	push   %esi
     d99:	53                   	push   %ebx
     d9a:	83 ec 1c             	sub    $0x1c,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
     d9d:	c7 44 24 04 f4 41 00 	movl   $0x41f4,0x4(%esp)
     da4:	00 
     da5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     dac:	e8 af 2d 00 00       	call   3b60 <printf>
  ppid = getpid();
     db1:	e8 fa 2c 00 00       	call   3ab0 <getpid>
     db6:	89 c6                	mov    %eax,%esi
  if((pid = fork()) == 0){
     db8:	e8 6b 2c 00 00       	call   3a28 <fork>
     dbd:	85 c0                	test   %eax,%eax
     dbf:	75 67                	jne    e28 <mem+0x94>
     dc1:	31 db                	xor    %ebx,%ebx
     dc3:	eb 07                	jmp    dcc <mem+0x38>
     dc5:	8d 76 00             	lea    0x0(%esi),%esi
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
     dc8:	89 18                	mov    %ebx,(%eax)
     dca:	89 c3                	mov    %eax,%ebx

  printf(1, "mem test\n");
  ppid = getpid();
  if((pid = fork()) == 0){
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
     dcc:	c7 04 24 11 27 00 00 	movl   $0x2711,(%esp)
     dd3:	e8 3c 2f 00 00       	call   3d14 <malloc>
     dd8:	85 c0                	test   %eax,%eax
     dda:	75 ec                	jne    dc8 <mem+0x34>
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     ddc:	85 db                	test   %ebx,%ebx
     dde:	75 06                	jne    de6 <mem+0x52>
     de0:	eb 12                	jmp    df4 <mem+0x60>
     de2:	66 90                	xchg   %ax,%ax
      m2 = *(char**)m1;
      free(m1);
      m1 = m2;
     de4:	89 fb                	mov    %edi,%ebx
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
      m2 = *(char**)m1;
     de6:	8b 3b                	mov    (%ebx),%edi
      free(m1);
     de8:	89 1c 24             	mov    %ebx,(%esp)
     deb:	e8 a4 2e 00 00       	call   3c94 <free>
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     df0:	85 ff                	test   %edi,%edi
     df2:	75 f0                	jne    de4 <mem+0x50>
      m2 = *(char**)m1;
      free(m1);
      m1 = m2;
    }
    m1 = malloc(1024*20);
     df4:	c7 04 24 00 50 00 00 	movl   $0x5000,(%esp)
     dfb:	e8 14 2f 00 00       	call   3d14 <malloc>
    if(m1 == 0){
     e00:	85 c0                	test   %eax,%eax
     e02:	74 30                	je     e34 <mem+0xa0>
      printf(1, "couldn't allocate mem?!!\n");
      kill(ppid);
      exit();
    }
    free(m1);
     e04:	89 04 24             	mov    %eax,(%esp)
     e07:	e8 88 2e 00 00       	call   3c94 <free>
    printf(1, "mem ok\n");
     e0c:	c7 44 24 04 18 42 00 	movl   $0x4218,0x4(%esp)
     e13:	00 
     e14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e1b:	e8 40 2d 00 00       	call   3b60 <printf>
    exit();
     e20:	e8 0b 2c 00 00       	call   3a30 <exit>
     e25:	8d 76 00             	lea    0x0(%esi),%esi
  } else {
    wait();
  }
}
     e28:	83 c4 1c             	add    $0x1c,%esp
     e2b:	5b                   	pop    %ebx
     e2c:	5e                   	pop    %esi
     e2d:	5f                   	pop    %edi
     e2e:	5d                   	pop    %ebp
    }
    free(m1);
    printf(1, "mem ok\n");
    exit();
  } else {
    wait();
     e2f:	e9 04 2c 00 00       	jmp    3a38 <wait>
      free(m1);
      m1 = m2;
    }
    m1 = malloc(1024*20);
    if(m1 == 0){
      printf(1, "couldn't allocate mem?!!\n");
     e34:	c7 44 24 04 fe 41 00 	movl   $0x41fe,0x4(%esp)
     e3b:	00 
     e3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e43:	e8 18 2d 00 00       	call   3b60 <printf>
      kill(ppid);
     e48:	89 34 24             	mov    %esi,(%esp)
     e4b:	e8 10 2c 00 00       	call   3a60 <kill>
      exit();
     e50:	e8 db 2b 00 00       	call   3a30 <exit>
     e55:	8d 76 00             	lea    0x0(%esi),%esi

00000e58 <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
     e58:	55                   	push   %ebp
     e59:	89 e5                	mov    %esp,%ebp
     e5b:	57                   	push   %edi
     e5c:	56                   	push   %esi
     e5d:	53                   	push   %ebx
     e5e:	83 ec 3c             	sub    $0x3c,%esp
  int fd, pid, i, n, nc, np;
  char buf[10];

  printf(1, "sharedfd test\n");
     e61:	c7 44 24 04 20 42 00 	movl   $0x4220,0x4(%esp)
     e68:	00 
     e69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e70:	e8 eb 2c 00 00       	call   3b60 <printf>

  unlink("sharedfd");
     e75:	c7 04 24 2f 42 00 00 	movl   $0x422f,(%esp)
     e7c:	e8 ff 2b 00 00       	call   3a80 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
     e81:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     e88:	00 
     e89:	c7 04 24 2f 42 00 00 	movl   $0x422f,(%esp)
     e90:	e8 db 2b 00 00       	call   3a70 <open>
     e95:	89 c7                	mov    %eax,%edi
  if(fd < 0){
     e97:	85 c0                	test   %eax,%eax
     e99:	0f 88 17 01 00 00    	js     fb6 <sharedfd+0x15e>
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
     e9f:	e8 84 2b 00 00       	call   3a28 <fork>
     ea4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  memset(buf, pid==0?'c':'p', sizeof(buf));
     ea7:	83 f8 01             	cmp    $0x1,%eax
     eaa:	19 c0                	sbb    %eax,%eax
     eac:	83 e0 f3             	and    $0xfffffff3,%eax
     eaf:	83 c0 70             	add    $0x70,%eax
     eb2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     eb9:	00 
     eba:	89 44 24 04          	mov    %eax,0x4(%esp)
     ebe:	8d 5d de             	lea    -0x22(%ebp),%ebx
     ec1:	89 1c 24             	mov    %ebx,(%esp)
     ec4:	e8 27 2a 00 00       	call   38f0 <memset>
     ec9:	be e8 03 00 00       	mov    $0x3e8,%esi
     ece:	eb 03                	jmp    ed3 <sharedfd+0x7b>
  for(i = 0; i < 1000; i++){
     ed0:	4e                   	dec    %esi
     ed1:	74 2d                	je     f00 <sharedfd+0xa8>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
     ed3:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     eda:	00 
     edb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     edf:	89 3c 24             	mov    %edi,(%esp)
     ee2:	e8 69 2b 00 00       	call   3a50 <write>
     ee7:	83 f8 0a             	cmp    $0xa,%eax
     eea:	74 e4                	je     ed0 <sharedfd+0x78>
      printf(1, "fstests: write sharedfd failed\n");
     eec:	c7 44 24 04 20 4f 00 	movl   $0x4f20,0x4(%esp)
     ef3:	00 
     ef4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     efb:	e8 60 2c 00 00       	call   3b60 <printf>
      break;
    }
  }
  if(pid == 0)
     f00:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     f03:	85 c0                	test   %eax,%eax
     f05:	0f 84 f9 00 00 00    	je     1004 <sharedfd+0x1ac>
    exit();
  else
    wait();
     f0b:	e8 28 2b 00 00       	call   3a38 <wait>
  close(fd);
     f10:	89 3c 24             	mov    %edi,(%esp)
     f13:	e8 40 2b 00 00       	call   3a58 <close>
  fd = open("sharedfd", 0);
     f18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     f1f:	00 
     f20:	c7 04 24 2f 42 00 00 	movl   $0x422f,(%esp)
     f27:	e8 44 2b 00 00       	call   3a70 <open>
     f2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  if(fd < 0){
     f2f:	85 c0                	test   %eax,%eax
     f31:	0f 88 9b 00 00 00    	js     fd2 <sharedfd+0x17a>
     f37:	31 ff                	xor    %edi,%edi
     f39:	31 f6                	xor    %esi,%esi
     f3b:	90                   	nop
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
     f3c:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     f43:	00 
     f44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     f48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     f4b:	89 04 24             	mov    %eax,(%esp)
     f4e:	e8 f5 2a 00 00       	call   3a48 <read>
     f53:	85 c0                	test   %eax,%eax
     f55:	7e 1c                	jle    f73 <sharedfd+0x11b>
     f57:	31 c0                	xor    %eax,%eax
     f59:	eb 0d                	jmp    f68 <sharedfd+0x110>
     f5b:	90                   	nop
    for(i = 0; i < sizeof(buf); i++){
      if(buf[i] == 'c')
        nc++;
      if(buf[i] == 'p')
     f5c:	80 fa 70             	cmp    $0x70,%dl
     f5f:	75 01                	jne    f62 <sharedfd+0x10a>
        np++;
     f61:	47                   	inc    %edi
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i = 0; i < sizeof(buf); i++){
     f62:	40                   	inc    %eax
     f63:	83 f8 0a             	cmp    $0xa,%eax
     f66:	74 d4                	je     f3c <sharedfd+0xe4>
      if(buf[i] == 'c')
     f68:	8a 14 03             	mov    (%ebx,%eax,1),%dl
     f6b:	80 fa 63             	cmp    $0x63,%dl
     f6e:	75 ec                	jne    f5c <sharedfd+0x104>
        nc++;
     f70:	46                   	inc    %esi
     f71:	eb ef                	jmp    f62 <sharedfd+0x10a>
      if(buf[i] == 'p')
        np++;
    }
  }
  close(fd);
     f73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     f76:	89 04 24             	mov    %eax,(%esp)
     f79:	e8 da 2a 00 00       	call   3a58 <close>
  unlink("sharedfd");
     f7e:	c7 04 24 2f 42 00 00 	movl   $0x422f,(%esp)
     f85:	e8 f6 2a 00 00       	call   3a80 <unlink>
  if(nc == 10000 && np == 10000){
     f8a:	81 fe 10 27 00 00    	cmp    $0x2710,%esi
     f90:	75 56                	jne    fe8 <sharedfd+0x190>
     f92:	81 ff 10 27 00 00    	cmp    $0x2710,%edi
     f98:	75 4e                	jne    fe8 <sharedfd+0x190>
    printf(1, "sharedfd ok\n");
     f9a:	c7 44 24 04 38 42 00 	movl   $0x4238,0x4(%esp)
     fa1:	00 
     fa2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fa9:	e8 b2 2b 00 00       	call   3b60 <printf>
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
    exit();
  }
}
     fae:	83 c4 3c             	add    $0x3c,%esp
     fb1:	5b                   	pop    %ebx
     fb2:	5e                   	pop    %esi
     fb3:	5f                   	pop    %edi
     fb4:	5d                   	pop    %ebp
     fb5:	c3                   	ret    
  printf(1, "sharedfd test\n");

  unlink("sharedfd");
  fd = open("sharedfd", O_CREATE|O_RDWR);
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for writing");
     fb6:	c7 44 24 04 f4 4e 00 	movl   $0x4ef4,0x4(%esp)
     fbd:	00 
     fbe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fc5:	e8 96 2b 00 00       	call   3b60 <printf>
    printf(1, "sharedfd ok\n");
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
    exit();
  }
}
     fca:	83 c4 3c             	add    $0x3c,%esp
     fcd:	5b                   	pop    %ebx
     fce:	5e                   	pop    %esi
     fcf:	5f                   	pop    %edi
     fd0:	5d                   	pop    %ebp
     fd1:	c3                   	ret    
  else
    wait();
  close(fd);
  fd = open("sharedfd", 0);
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for reading\n");
     fd2:	c7 44 24 04 40 4f 00 	movl   $0x4f40,0x4(%esp)
     fd9:	00 
     fda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fe1:	e8 7a 2b 00 00       	call   3b60 <printf>
    return;
     fe6:	eb c6                	jmp    fae <sharedfd+0x156>
  close(fd);
  unlink("sharedfd");
  if(nc == 10000 && np == 10000){
    printf(1, "sharedfd ok\n");
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
     fe8:	89 7c 24 0c          	mov    %edi,0xc(%esp)
     fec:	89 74 24 08          	mov    %esi,0x8(%esp)
     ff0:	c7 44 24 04 45 42 00 	movl   $0x4245,0x4(%esp)
     ff7:	00 
     ff8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fff:	e8 5c 2b 00 00       	call   3b60 <printf>
    exit();
    1004:	e8 27 2a 00 00       	call   3a30 <exit>
    1009:	8d 76 00             	lea    0x0(%esi),%esi

0000100c <fourfiles>:

// four processes write different files at the same
// time, to test block allocation.
void
fourfiles(void)
{
    100c:	55                   	push   %ebp
    100d:	89 e5                	mov    %esp,%ebp
    100f:	57                   	push   %edi
    1010:	56                   	push   %esi
    1011:	53                   	push   %ebx
    1012:	83 ec 3c             	sub    $0x3c,%esp
  int fd, pid, i, j, n, total, pi;
  char *names[] = { "f0", "f1", "f2", "f3" };
    1015:	8d 7d d8             	lea    -0x28(%ebp),%edi
    1018:	89 7d d4             	mov    %edi,-0x2c(%ebp)
    101b:	be 8c 55 00 00       	mov    $0x558c,%esi
    1020:	b9 04 00 00 00       	mov    $0x4,%ecx
    1025:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  char *fname;

  printf(1, "fourfiles test\n");
    1027:	c7 44 24 04 5a 42 00 	movl   $0x425a,0x4(%esp)
    102e:	00 
    102f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1036:	e8 25 2b 00 00       	call   3b60 <printf>

  for(pi = 0; pi < 4; pi++){
    103b:	31 db                	xor    %ebx,%ebx
    fname = names[pi];
    103d:	8b 74 9d d8          	mov    -0x28(%ebp,%ebx,4),%esi
    unlink(fname);
    1041:	89 34 24             	mov    %esi,(%esp)
    1044:	e8 37 2a 00 00       	call   3a80 <unlink>

    pid = fork();
    1049:	e8 da 29 00 00       	call   3a28 <fork>
    if(pid < 0){
    104e:	83 f8 00             	cmp    $0x0,%eax
    1051:	0f 8c 6d 01 00 00    	jl     11c4 <fourfiles+0x1b8>
      printf(1, "fork failed\n");
      exit();
    }

    if(pid == 0){
    1057:	0f 84 cd 00 00 00    	je     112a <fourfiles+0x11e>
  char *names[] = { "f0", "f1", "f2", "f3" };
  char *fname;

  printf(1, "fourfiles test\n");

  for(pi = 0; pi < 4; pi++){
    105d:	43                   	inc    %ebx
    105e:	83 fb 04             	cmp    $0x4,%ebx
    1061:	75 da                	jne    103d <fourfiles+0x31>
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    wait();
    1063:	e8 d0 29 00 00       	call   3a38 <wait>
    1068:	e8 cb 29 00 00       	call   3a38 <wait>
    106d:	e8 c6 29 00 00       	call   3a38 <wait>
    1072:	e8 c1 29 00 00       	call   3a38 <wait>
    1077:	be 30 00 00 00       	mov    $0x30,%esi
  }

  for(i = 0; i < 2; i++){
    fname = names[i];
    107c:	8b bc b5 18 ff ff ff 	mov    -0xe8(%ebp,%esi,4),%edi
    1083:	89 7d d0             	mov    %edi,-0x30(%ebp)
    fd = open(fname, 0);
    1086:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    108d:	00 
    108e:	89 3c 24             	mov    %edi,(%esp)
    1091:	e8 da 29 00 00       	call   3a70 <open>
    1096:	89 c7                	mov    %eax,%edi
    total = 0;
    1098:	31 db                	xor    %ebx,%ebx
    109a:	66 90                	xchg   %ax,%ax
    while((n = read(fd, buf, sizeof(buf))) > 0){
    109c:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    10a3:	00 
    10a4:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
    10ab:	00 
    10ac:	89 3c 24             	mov    %edi,(%esp)
    10af:	e8 94 29 00 00       	call   3a48 <read>
    10b4:	85 c0                	test   %eax,%eax
    10b6:	7e 18                	jle    10d0 <fourfiles+0xc4>
    10b8:	31 d2                	xor    %edx,%edx
    10ba:	66 90                	xchg   %ax,%ax
      for(j = 0; j < n; j++){
        if(buf[j] != '0'+i){
    10bc:	0f be 8a 80 86 00 00 	movsbl 0x8680(%edx),%ecx
    10c3:	39 ce                	cmp    %ecx,%esi
    10c5:	75 4a                	jne    1111 <fourfiles+0x105>
  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
    10c7:	42                   	inc    %edx
    10c8:	39 c2                	cmp    %eax,%edx
    10ca:	75 f0                	jne    10bc <fourfiles+0xb0>
        if(buf[j] != '0'+i){
          printf(1, "wrong char\n");
          exit();
        }
      }
      total += n;
    10cc:	01 d3                	add    %edx,%ebx
    10ce:	eb cc                	jmp    109c <fourfiles+0x90>
    }
    close(fd);
    10d0:	89 3c 24             	mov    %edi,(%esp)
    10d3:	e8 80 29 00 00       	call   3a58 <close>
    if(total != 12*500){
    10d8:	81 fb 70 17 00 00    	cmp    $0x1770,%ebx
    10de:	0f 85 c3 00 00 00    	jne    11a7 <fourfiles+0x19b>
      printf(1, "wrong length %d\n", total);
      exit();
    }
    unlink(fname);
    10e4:	8b 7d d0             	mov    -0x30(%ebp),%edi
    10e7:	89 3c 24             	mov    %edi,(%esp)
    10ea:	e8 91 29 00 00       	call   3a80 <unlink>
    10ef:	46                   	inc    %esi

  for(pi = 0; pi < 4; pi++){
    wait();
  }

  for(i = 0; i < 2; i++){
    10f0:	83 fe 32             	cmp    $0x32,%esi
    10f3:	75 87                	jne    107c <fourfiles+0x70>
      exit();
    }
    unlink(fname);
  }

  printf(1, "fourfiles ok\n");
    10f5:	c7 44 24 04 98 42 00 	movl   $0x4298,0x4(%esp)
    10fc:	00 
    10fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1104:	e8 57 2a 00 00       	call   3b60 <printf>
}
    1109:	83 c4 3c             	add    $0x3c,%esp
    110c:	5b                   	pop    %ebx
    110d:	5e                   	pop    %esi
    110e:	5f                   	pop    %edi
    110f:	5d                   	pop    %ebp
    1110:	c3                   	ret    
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
        if(buf[j] != '0'+i){
          printf(1, "wrong char\n");
    1111:	c7 44 24 04 7b 42 00 	movl   $0x427b,0x4(%esp)
    1118:	00 
    1119:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1120:	e8 3b 2a 00 00       	call   3b60 <printf>
          exit();
    1125:	e8 06 29 00 00       	call   3a30 <exit>
      printf(1, "fork failed\n");
      exit();
    }

    if(pid == 0){
      fd = open(fname, O_CREATE | O_RDWR);
    112a:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1131:	00 
    1132:	89 34 24             	mov    %esi,(%esp)
    1135:	e8 36 29 00 00       	call   3a70 <open>
    113a:	89 c6                	mov    %eax,%esi
      if(fd < 0){
    113c:	85 c0                	test   %eax,%eax
    113e:	0f 88 99 00 00 00    	js     11dd <fourfiles+0x1d1>
        printf(1, "create failed\n");
        exit();
      }

      memset(buf, '0'+pi, 512);
    1144:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    114b:	00 
    114c:	83 c3 30             	add    $0x30,%ebx
    114f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    1153:	c7 04 24 80 86 00 00 	movl   $0x8680,(%esp)
    115a:	e8 91 27 00 00       	call   38f0 <memset>
    115f:	bb 0c 00 00 00       	mov    $0xc,%ebx
    1164:	eb 05                	jmp    116b <fourfiles+0x15f>
    1166:	66 90                	xchg   %ax,%ax
      for(i = 0; i < 12; i++){
    1168:	4b                   	dec    %ebx
    1169:	74 ba                	je     1125 <fourfiles+0x119>
        if((n = write(fd, buf, 500)) != 500){
    116b:	c7 44 24 08 f4 01 00 	movl   $0x1f4,0x8(%esp)
    1172:	00 
    1173:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
    117a:	00 
    117b:	89 34 24             	mov    %esi,(%esp)
    117e:	e8 cd 28 00 00       	call   3a50 <write>
    1183:	3d f4 01 00 00       	cmp    $0x1f4,%eax
    1188:	74 de                	je     1168 <fourfiles+0x15c>
          printf(1, "write failed %d\n", n);
    118a:	89 44 24 08          	mov    %eax,0x8(%esp)
    118e:	c7 44 24 04 6a 42 00 	movl   $0x426a,0x4(%esp)
    1195:	00 
    1196:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    119d:	e8 be 29 00 00       	call   3b60 <printf>
          exit();
    11a2:	e8 89 28 00 00       	call   3a30 <exit>
      }
      total += n;
    }
    close(fd);
    if(total != 12*500){
      printf(1, "wrong length %d\n", total);
    11a7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    11ab:	c7 44 24 04 87 42 00 	movl   $0x4287,0x4(%esp)
    11b2:	00 
    11b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11ba:	e8 a1 29 00 00       	call   3b60 <printf>
      exit();
    11bf:	e8 6c 28 00 00       	call   3a30 <exit>
    fname = names[pi];
    unlink(fname);

    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
    11c4:	c7 44 24 04 35 4d 00 	movl   $0x4d35,0x4(%esp)
    11cb:	00 
    11cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11d3:	e8 88 29 00 00       	call   3b60 <printf>
      exit();
    11d8:	e8 53 28 00 00       	call   3a30 <exit>
    }

    if(pid == 0){
      fd = open(fname, O_CREATE | O_RDWR);
      if(fd < 0){
        printf(1, "create failed\n");
    11dd:	c7 44 24 04 fb 44 00 	movl   $0x44fb,0x4(%esp)
    11e4:	00 
    11e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11ec:	e8 6f 29 00 00       	call   3b60 <printf>
        exit();
    11f1:	e8 3a 28 00 00       	call   3a30 <exit>
    11f6:	66 90                	xchg   %ax,%ax

000011f8 <createdelete>:
}

// four processes create and delete different files in same directory
void
createdelete(void)
{
    11f8:	55                   	push   %ebp
    11f9:	89 e5                	mov    %esp,%ebp
    11fb:	57                   	push   %edi
    11fc:	56                   	push   %esi
    11fd:	53                   	push   %ebx
    11fe:	83 ec 4c             	sub    $0x4c,%esp
  enum { N = 20 };
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");
    1201:	c7 44 24 04 ac 42 00 	movl   $0x42ac,0x4(%esp)
    1208:	00 
    1209:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1210:	e8 4b 29 00 00       	call   3b60 <printf>

  for(pi = 0; pi < 4; pi++){
    1215:	31 db                	xor    %ebx,%ebx
    pid = fork();
    1217:	e8 0c 28 00 00       	call   3a28 <fork>
    if(pid < 0){
    121c:	83 f8 00             	cmp    $0x0,%eax
    121f:	0f 8c 8c 01 00 00    	jl     13b1 <createdelete+0x1b9>
      printf(1, "fork failed\n");
      exit();
    }

    if(pid == 0){
    1225:	0f 84 cf 00 00 00    	je     12fa <createdelete+0x102>
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");

  for(pi = 0; pi < 4; pi++){
    122b:	43                   	inc    %ebx
    122c:	83 fb 04             	cmp    $0x4,%ebx
    122f:	75 e6                	jne    1217 <createdelete+0x1f>
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    wait();
    1231:	e8 02 28 00 00       	call   3a38 <wait>
    1236:	e8 fd 27 00 00       	call   3a38 <wait>
    123b:	e8 f8 27 00 00       	call   3a38 <wait>
    1240:	e8 f3 27 00 00       	call   3a38 <wait>
  }

  name[0] = name[1] = name[2] = 0;
    1245:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
  for(i = 0; i < N; i++){
    1249:	31 f6                	xor    %esi,%esi
    124b:	8d 7d c8             	lea    -0x38(%ebp),%edi
    124e:	66 90                	xchg   %ax,%ax
  printf(1, "fourfiles ok\n");
}

// four processes create and delete different files in same directory
void
createdelete(void)
    1250:	8d 46 30             	lea    0x30(%esi),%eax
    1253:	88 45 c7             	mov    %al,-0x39(%ebp)
    1256:	b3 70                	mov    $0x70,%bl
      name[1] = '0' + i;
      fd = open(name, 0);
      if((i == 0 || i >= N/2) && fd < 0){
        printf(1, "oops createdelete %s didn't exist\n", name);
        exit();
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1258:	8d 46 ff             	lea    -0x1(%esi),%eax
    125b:	89 45 c0             	mov    %eax,-0x40(%ebp)
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
      name[0] = 'p' + pi;
    125e:	88 5d c8             	mov    %bl,-0x38(%ebp)
      name[1] = '0' + i;
    1261:	8a 45 c7             	mov    -0x39(%ebp),%al
    1264:	88 45 c9             	mov    %al,-0x37(%ebp)
      fd = open(name, 0);
    1267:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    126e:	00 
    126f:	89 3c 24             	mov    %edi,(%esp)
    1272:	e8 f9 27 00 00       	call   3a70 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1277:	85 f6                	test   %esi,%esi
    1279:	74 05                	je     1280 <createdelete+0x88>
    127b:	83 fe 09             	cmp    $0x9,%esi
    127e:	7e 08                	jle    1288 <createdelete+0x90>
    1280:	85 c0                	test   %eax,%eax
    1282:	0f 88 c0 00 00 00    	js     1348 <createdelete+0x150>
        printf(1, "oops createdelete %s didn't exist\n", name);
        exit();
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1288:	83 7d c0 08          	cmpl   $0x8,-0x40(%ebp)
    128c:	77 5e                	ja     12ec <createdelete+0xf4>
    128e:	85 c0                	test   %eax,%eax
    1290:	0f 89 fe 00 00 00    	jns    1394 <createdelete+0x19c>
        printf(1, "oops createdelete %s did exist\n", name);
        exit();
      }
      if(fd >= 0)
        close(fd);
    1296:	43                   	inc    %ebx
    wait();
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    1297:	80 fb 74             	cmp    $0x74,%bl
    129a:	75 c2                	jne    125e <createdelete+0x66>
  for(pi = 0; pi < 4; pi++){
    wait();
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    129c:	46                   	inc    %esi
    129d:	83 fe 14             	cmp    $0x14,%esi
    12a0:	75 ae                	jne    1250 <createdelete+0x58>
    12a2:	be 70 00 00 00       	mov    $0x70,%esi
    12a7:	90                   	nop
  printf(1, "fourfiles ok\n");
}

// four processes create and delete different files in same directory
void
createdelete(void)
    12a8:	8d 46 c0             	lea    -0x40(%esi),%eax
    12ab:	88 45 c7             	mov    %al,-0x39(%ebp)
    12ae:	bb 04 00 00 00       	mov    $0x4,%ebx
    }
  }

  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
      name[0] = 'p' + i;
    12b3:	89 f0                	mov    %esi,%eax
    12b5:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    12b8:	8a 45 c7             	mov    -0x39(%ebp),%al
    12bb:	88 45 c9             	mov    %al,-0x37(%ebp)
      unlink(name);
    12be:	89 3c 24             	mov    %edi,(%esp)
    12c1:	e8 ba 27 00 00       	call   3a80 <unlink>
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    12c6:	4b                   	dec    %ebx
    12c7:	75 ea                	jne    12b3 <createdelete+0xbb>
    12c9:	46                   	inc    %esi
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    12ca:	89 f0                	mov    %esi,%eax
    12cc:	3c 84                	cmp    $0x84,%al
    12ce:	75 d8                	jne    12a8 <createdelete+0xb0>
      name[1] = '0' + i;
      unlink(name);
    }
  }

  printf(1, "createdelete ok\n");
    12d0:	c7 44 24 04 bf 42 00 	movl   $0x42bf,0x4(%esp)
    12d7:	00 
    12d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    12df:	e8 7c 28 00 00       	call   3b60 <printf>
}
    12e4:	83 c4 4c             	add    $0x4c,%esp
    12e7:	5b                   	pop    %ebx
    12e8:	5e                   	pop    %esi
    12e9:	5f                   	pop    %edi
    12ea:	5d                   	pop    %ebp
    12eb:	c3                   	ret    
        exit();
      } else if((i >= 1 && i < N/2) && fd >= 0){
        printf(1, "oops createdelete %s did exist\n", name);
        exit();
      }
      if(fd >= 0)
    12ec:	85 c0                	test   %eax,%eax
    12ee:	78 a6                	js     1296 <createdelete+0x9e>
        close(fd);
    12f0:	89 04 24             	mov    %eax,(%esp)
    12f3:	e8 60 27 00 00       	call   3a58 <close>
    12f8:	eb 9c                	jmp    1296 <createdelete+0x9e>
      printf(1, "fork failed\n");
      exit();
    }

    if(pid == 0){
      name[0] = 'p' + pi;
    12fa:	83 c3 70             	add    $0x70,%ebx
    12fd:	88 5d c8             	mov    %bl,-0x38(%ebp)
      name[2] = '\0';
    1300:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
    1304:	be 01 00 00 00       	mov    $0x1,%esi
    1309:	31 db                	xor    %ebx,%ebx
    130b:	8d 7d c8             	lea    -0x38(%ebp),%edi
    130e:	66 90                	xchg   %ax,%ax
  printf(1, "fourfiles ok\n");
}

// four processes create and delete different files in same directory
void
createdelete(void)
    1310:	8d 43 30             	lea    0x30(%ebx),%eax
    1313:	88 45 c9             	mov    %al,-0x37(%ebp)
    if(pid == 0){
      name[0] = 'p' + pi;
      name[2] = '\0';
      for(i = 0; i < N; i++){
        name[1] = '0' + i;
        fd = open(name, O_CREATE | O_RDWR);
    1316:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    131d:	00 
    131e:	89 3c 24             	mov    %edi,(%esp)
    1321:	e8 4a 27 00 00       	call   3a70 <open>
        if(fd < 0){
    1326:	85 c0                	test   %eax,%eax
    1328:	0f 88 9c 00 00 00    	js     13ca <createdelete+0x1d2>
          printf(1, "create failed\n");
          exit();
        }
        close(fd);
    132e:	89 04 24             	mov    %eax,(%esp)
    1331:	e8 22 27 00 00       	call   3a58 <close>
        if(i > 0 && (i % 2 ) == 0){
    1336:	85 db                	test   %ebx,%ebx
    1338:	74 0a                	je     1344 <createdelete+0x14c>
    133a:	f6 c3 01             	test   $0x1,%bl
    133d:	74 26                	je     1365 <createdelete+0x16d>
    }

    if(pid == 0){
      name[0] = 'p' + pi;
      name[2] = '\0';
      for(i = 0; i < N; i++){
    133f:	83 fe 14             	cmp    $0x14,%esi
    1342:	74 1c                	je     1360 <createdelete+0x168>
      exit();
    }

    if(pid == 0){
      name[0] = 'p' + pi;
      name[2] = '\0';
    1344:	43                   	inc    %ebx
    1345:	46                   	inc    %esi
    1346:	eb c8                	jmp    1310 <createdelete+0x118>
    for(pi = 0; pi < 4; pi++){
      name[0] = 'p' + pi;
      name[1] = '0' + i;
      fd = open(name, 0);
      if((i == 0 || i >= N/2) && fd < 0){
        printf(1, "oops createdelete %s didn't exist\n", name);
    1348:	89 7c 24 08          	mov    %edi,0x8(%esp)
    134c:	c7 44 24 04 6c 4f 00 	movl   $0x4f6c,0x4(%esp)
    1353:	00 
    1354:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    135b:	e8 00 28 00 00       	call   3b60 <printf>
        exit();
    1360:	e8 cb 26 00 00       	call   3a30 <exit>
          printf(1, "create failed\n");
          exit();
        }
        close(fd);
        if(i > 0 && (i % 2 ) == 0){
          name[1] = '0' + (i / 2);
    1365:	89 d8                	mov    %ebx,%eax
    1367:	d1 f8                	sar    %eax
    1369:	83 c0 30             	add    $0x30,%eax
    136c:	88 45 c9             	mov    %al,-0x37(%ebp)
          if(unlink(name) < 0){
    136f:	89 3c 24             	mov    %edi,(%esp)
    1372:	e8 09 27 00 00       	call   3a80 <unlink>
    1377:	85 c0                	test   %eax,%eax
    1379:	79 c4                	jns    133f <createdelete+0x147>
            printf(1, "unlink failed\n");
    137b:	c7 44 24 04 ad 3e 00 	movl   $0x3ead,0x4(%esp)
    1382:	00 
    1383:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    138a:	e8 d1 27 00 00       	call   3b60 <printf>
            exit();
    138f:	e8 9c 26 00 00       	call   3a30 <exit>
      fd = open(name, 0);
      if((i == 0 || i >= N/2) && fd < 0){
        printf(1, "oops createdelete %s didn't exist\n", name);
        exit();
      } else if((i >= 1 && i < N/2) && fd >= 0){
        printf(1, "oops createdelete %s did exist\n", name);
    1394:	89 7c 24 08          	mov    %edi,0x8(%esp)
    1398:	c7 44 24 04 90 4f 00 	movl   $0x4f90,0x4(%esp)
    139f:	00 
    13a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    13a7:	e8 b4 27 00 00       	call   3b60 <printf>
        exit();
    13ac:	e8 7f 26 00 00       	call   3a30 <exit>
  printf(1, "createdelete test\n");

  for(pi = 0; pi < 4; pi++){
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
    13b1:	c7 44 24 04 35 4d 00 	movl   $0x4d35,0x4(%esp)
    13b8:	00 
    13b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    13c0:	e8 9b 27 00 00       	call   3b60 <printf>
      exit();
    13c5:	e8 66 26 00 00       	call   3a30 <exit>
      name[2] = '\0';
      for(i = 0; i < N; i++){
        name[1] = '0' + i;
        fd = open(name, O_CREATE | O_RDWR);
        if(fd < 0){
          printf(1, "create failed\n");
    13ca:	c7 44 24 04 fb 44 00 	movl   $0x44fb,0x4(%esp)
    13d1:	00 
    13d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    13d9:	e8 82 27 00 00       	call   3b60 <printf>
          exit();
    13de:	e8 4d 26 00 00       	call   3a30 <exit>
    13e3:	90                   	nop

000013e4 <unlinkread>:
}

// can I unlink a file and still read it?
void
unlinkread(void)
{
    13e4:	55                   	push   %ebp
    13e5:	89 e5                	mov    %esp,%ebp
    13e7:	56                   	push   %esi
    13e8:	53                   	push   %ebx
    13e9:	83 ec 10             	sub    $0x10,%esp
  int fd, fd1;

  printf(1, "unlinkread test\n");
    13ec:	c7 44 24 04 d0 42 00 	movl   $0x42d0,0x4(%esp)
    13f3:	00 
    13f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    13fb:	e8 60 27 00 00       	call   3b60 <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    1400:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1407:	00 
    1408:	c7 04 24 e1 42 00 00 	movl   $0x42e1,(%esp)
    140f:	e8 5c 26 00 00       	call   3a70 <open>
    1414:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1416:	85 c0                	test   %eax,%eax
    1418:	0f 88 fe 00 00 00    	js     151c <unlinkread+0x138>
    printf(1, "create unlinkread failed\n");
    exit();
  }
  write(fd, "hello", 5);
    141e:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    1425:	00 
    1426:	c7 44 24 04 06 43 00 	movl   $0x4306,0x4(%esp)
    142d:	00 
    142e:	89 04 24             	mov    %eax,(%esp)
    1431:	e8 1a 26 00 00       	call   3a50 <write>
  close(fd);
    1436:	89 1c 24             	mov    %ebx,(%esp)
    1439:	e8 1a 26 00 00       	call   3a58 <close>

  fd = open("unlinkread", O_RDWR);
    143e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    1445:	00 
    1446:	c7 04 24 e1 42 00 00 	movl   $0x42e1,(%esp)
    144d:	e8 1e 26 00 00       	call   3a70 <open>
    1452:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1454:	85 c0                	test   %eax,%eax
    1456:	0f 88 3d 01 00 00    	js     1599 <unlinkread+0x1b5>
    printf(1, "open unlinkread failed\n");
    exit();
  }
  if(unlink("unlinkread") != 0){
    145c:	c7 04 24 e1 42 00 00 	movl   $0x42e1,(%esp)
    1463:	e8 18 26 00 00       	call   3a80 <unlink>
    1468:	85 c0                	test   %eax,%eax
    146a:	0f 85 10 01 00 00    	jne    1580 <unlinkread+0x19c>
    printf(1, "unlink unlinkread failed\n");
    exit();
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    1470:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1477:	00 
    1478:	c7 04 24 e1 42 00 00 	movl   $0x42e1,(%esp)
    147f:	e8 ec 25 00 00       	call   3a70 <open>
    1484:	89 c6                	mov    %eax,%esi
  write(fd1, "yyy", 3);
    1486:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
    148d:	00 
    148e:	c7 44 24 04 3e 43 00 	movl   $0x433e,0x4(%esp)
    1495:	00 
    1496:	89 04 24             	mov    %eax,(%esp)
    1499:	e8 b2 25 00 00       	call   3a50 <write>
  close(fd1);
    149e:	89 34 24             	mov    %esi,(%esp)
    14a1:	e8 b2 25 00 00       	call   3a58 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    14a6:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    14ad:	00 
    14ae:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
    14b5:	00 
    14b6:	89 1c 24             	mov    %ebx,(%esp)
    14b9:	e8 8a 25 00 00       	call   3a48 <read>
    14be:	83 f8 05             	cmp    $0x5,%eax
    14c1:	0f 85 a0 00 00 00    	jne    1567 <unlinkread+0x183>
    printf(1, "unlinkread read failed");
    exit();
  }
  if(buf[0] != 'h'){
    14c7:	80 3d 80 86 00 00 68 	cmpb   $0x68,0x8680
    14ce:	75 7e                	jne    154e <unlinkread+0x16a>
    printf(1, "unlinkread wrong data\n");
    exit();
  }
  if(write(fd, buf, 10) != 10){
    14d0:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    14d7:	00 
    14d8:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
    14df:	00 
    14e0:	89 1c 24             	mov    %ebx,(%esp)
    14e3:	e8 68 25 00 00       	call   3a50 <write>
    14e8:	83 f8 0a             	cmp    $0xa,%eax
    14eb:	75 48                	jne    1535 <unlinkread+0x151>
    printf(1, "unlinkread write failed\n");
    exit();
  }
  close(fd);
    14ed:	89 1c 24             	mov    %ebx,(%esp)
    14f0:	e8 63 25 00 00       	call   3a58 <close>
  unlink("unlinkread");
    14f5:	c7 04 24 e1 42 00 00 	movl   $0x42e1,(%esp)
    14fc:	e8 7f 25 00 00       	call   3a80 <unlink>
  printf(1, "unlinkread ok\n");
    1501:	c7 44 24 04 89 43 00 	movl   $0x4389,0x4(%esp)
    1508:	00 
    1509:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1510:	e8 4b 26 00 00       	call   3b60 <printf>
}
    1515:	83 c4 10             	add    $0x10,%esp
    1518:	5b                   	pop    %ebx
    1519:	5e                   	pop    %esi
    151a:	5d                   	pop    %ebp
    151b:	c3                   	ret    
  int fd, fd1;

  printf(1, "unlinkread test\n");
  fd = open("unlinkread", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "create unlinkread failed\n");
    151c:	c7 44 24 04 ec 42 00 	movl   $0x42ec,0x4(%esp)
    1523:	00 
    1524:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    152b:	e8 30 26 00 00       	call   3b60 <printf>
    exit();
    1530:	e8 fb 24 00 00       	call   3a30 <exit>
  if(buf[0] != 'h'){
    printf(1, "unlinkread wrong data\n");
    exit();
  }
  if(write(fd, buf, 10) != 10){
    printf(1, "unlinkread write failed\n");
    1535:	c7 44 24 04 70 43 00 	movl   $0x4370,0x4(%esp)
    153c:	00 
    153d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1544:	e8 17 26 00 00       	call   3b60 <printf>
    exit();
    1549:	e8 e2 24 00 00       	call   3a30 <exit>
  if(read(fd, buf, sizeof(buf)) != 5){
    printf(1, "unlinkread read failed");
    exit();
  }
  if(buf[0] != 'h'){
    printf(1, "unlinkread wrong data\n");
    154e:	c7 44 24 04 59 43 00 	movl   $0x4359,0x4(%esp)
    1555:	00 
    1556:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    155d:	e8 fe 25 00 00       	call   3b60 <printf>
    exit();
    1562:	e8 c9 24 00 00       	call   3a30 <exit>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
  write(fd1, "yyy", 3);
  close(fd1);

  if(read(fd, buf, sizeof(buf)) != 5){
    printf(1, "unlinkread read failed");
    1567:	c7 44 24 04 42 43 00 	movl   $0x4342,0x4(%esp)
    156e:	00 
    156f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1576:	e8 e5 25 00 00       	call   3b60 <printf>
    exit();
    157b:	e8 b0 24 00 00       	call   3a30 <exit>
  if(fd < 0){
    printf(1, "open unlinkread failed\n");
    exit();
  }
  if(unlink("unlinkread") != 0){
    printf(1, "unlink unlinkread failed\n");
    1580:	c7 44 24 04 24 43 00 	movl   $0x4324,0x4(%esp)
    1587:	00 
    1588:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    158f:	e8 cc 25 00 00       	call   3b60 <printf>
    exit();
    1594:	e8 97 24 00 00       	call   3a30 <exit>
  write(fd, "hello", 5);
  close(fd);

  fd = open("unlinkread", O_RDWR);
  if(fd < 0){
    printf(1, "open unlinkread failed\n");
    1599:	c7 44 24 04 0c 43 00 	movl   $0x430c,0x4(%esp)
    15a0:	00 
    15a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15a8:	e8 b3 25 00 00       	call   3b60 <printf>
    exit();
    15ad:	e8 7e 24 00 00       	call   3a30 <exit>
    15b2:	66 90                	xchg   %ax,%ax

000015b4 <linktest>:
  printf(1, "unlinkread ok\n");
}

void
linktest(void)
{
    15b4:	55                   	push   %ebp
    15b5:	89 e5                	mov    %esp,%ebp
    15b7:	53                   	push   %ebx
    15b8:	83 ec 14             	sub    $0x14,%esp
  int fd;

  printf(1, "linktest\n");
    15bb:	c7 44 24 04 98 43 00 	movl   $0x4398,0x4(%esp)
    15c2:	00 
    15c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15ca:	e8 91 25 00 00       	call   3b60 <printf>

  unlink("lf1");
    15cf:	c7 04 24 a2 43 00 00 	movl   $0x43a2,(%esp)
    15d6:	e8 a5 24 00 00       	call   3a80 <unlink>
  unlink("lf2");
    15db:	c7 04 24 a6 43 00 00 	movl   $0x43a6,(%esp)
    15e2:	e8 99 24 00 00       	call   3a80 <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    15e7:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    15ee:	00 
    15ef:	c7 04 24 a2 43 00 00 	movl   $0x43a2,(%esp)
    15f6:	e8 75 24 00 00       	call   3a70 <open>
    15fb:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    15fd:	85 c0                	test   %eax,%eax
    15ff:	0f 88 26 01 00 00    	js     172b <linktest+0x177>
    printf(1, "create lf1 failed\n");
    exit();
  }
  if(write(fd, "hello", 5) != 5){
    1605:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    160c:	00 
    160d:	c7 44 24 04 06 43 00 	movl   $0x4306,0x4(%esp)
    1614:	00 
    1615:	89 04 24             	mov    %eax,(%esp)
    1618:	e8 33 24 00 00       	call   3a50 <write>
    161d:	83 f8 05             	cmp    $0x5,%eax
    1620:	0f 85 cd 01 00 00    	jne    17f3 <linktest+0x23f>
    printf(1, "write lf1 failed\n");
    exit();
  }
  close(fd);
    1626:	89 1c 24             	mov    %ebx,(%esp)
    1629:	e8 2a 24 00 00       	call   3a58 <close>

  if(link("lf1", "lf2") < 0){
    162e:	c7 44 24 04 a6 43 00 	movl   $0x43a6,0x4(%esp)
    1635:	00 
    1636:	c7 04 24 a2 43 00 00 	movl   $0x43a2,(%esp)
    163d:	e8 4e 24 00 00       	call   3a90 <link>
    1642:	85 c0                	test   %eax,%eax
    1644:	0f 88 90 01 00 00    	js     17da <linktest+0x226>
    printf(1, "link lf1 lf2 failed\n");
    exit();
  }
  unlink("lf1");
    164a:	c7 04 24 a2 43 00 00 	movl   $0x43a2,(%esp)
    1651:	e8 2a 24 00 00       	call   3a80 <unlink>

  if(open("lf1", 0) >= 0){
    1656:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    165d:	00 
    165e:	c7 04 24 a2 43 00 00 	movl   $0x43a2,(%esp)
    1665:	e8 06 24 00 00       	call   3a70 <open>
    166a:	85 c0                	test   %eax,%eax
    166c:	0f 89 4f 01 00 00    	jns    17c1 <linktest+0x20d>
    printf(1, "unlinked lf1 but it is still there!\n");
    exit();
  }

  fd = open("lf2", 0);
    1672:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1679:	00 
    167a:	c7 04 24 a6 43 00 00 	movl   $0x43a6,(%esp)
    1681:	e8 ea 23 00 00       	call   3a70 <open>
    1686:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1688:	85 c0                	test   %eax,%eax
    168a:	0f 88 18 01 00 00    	js     17a8 <linktest+0x1f4>
    printf(1, "open lf2 failed\n");
    exit();
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    1690:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1697:	00 
    1698:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
    169f:	00 
    16a0:	89 04 24             	mov    %eax,(%esp)
    16a3:	e8 a0 23 00 00       	call   3a48 <read>
    16a8:	83 f8 05             	cmp    $0x5,%eax
    16ab:	0f 85 de 00 00 00    	jne    178f <linktest+0x1db>
    printf(1, "read lf2 failed\n");
    exit();
  }
  close(fd);
    16b1:	89 1c 24             	mov    %ebx,(%esp)
    16b4:	e8 9f 23 00 00       	call   3a58 <close>

  if(link("lf2", "lf2") >= 0){
    16b9:	c7 44 24 04 a6 43 00 	movl   $0x43a6,0x4(%esp)
    16c0:	00 
    16c1:	c7 04 24 a6 43 00 00 	movl   $0x43a6,(%esp)
    16c8:	e8 c3 23 00 00       	call   3a90 <link>
    16cd:	85 c0                	test   %eax,%eax
    16cf:	0f 89 a1 00 00 00    	jns    1776 <linktest+0x1c2>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    exit();
  }

  unlink("lf2");
    16d5:	c7 04 24 a6 43 00 00 	movl   $0x43a6,(%esp)
    16dc:	e8 9f 23 00 00       	call   3a80 <unlink>
  if(link("lf2", "lf1") >= 0){
    16e1:	c7 44 24 04 a2 43 00 	movl   $0x43a2,0x4(%esp)
    16e8:	00 
    16e9:	c7 04 24 a6 43 00 00 	movl   $0x43a6,(%esp)
    16f0:	e8 9b 23 00 00       	call   3a90 <link>
    16f5:	85 c0                	test   %eax,%eax
    16f7:	79 64                	jns    175d <linktest+0x1a9>
    printf(1, "link non-existant succeeded! oops\n");
    exit();
  }

  if(link(".", "lf1") >= 0){
    16f9:	c7 44 24 04 a2 43 00 	movl   $0x43a2,0x4(%esp)
    1700:	00 
    1701:	c7 04 24 6a 46 00 00 	movl   $0x466a,(%esp)
    1708:	e8 83 23 00 00       	call   3a90 <link>
    170d:	85 c0                	test   %eax,%eax
    170f:	79 33                	jns    1744 <linktest+0x190>
    printf(1, "link . lf1 succeeded! oops\n");
    exit();
  }

  printf(1, "linktest ok\n");
    1711:	c7 44 24 04 40 44 00 	movl   $0x4440,0x4(%esp)
    1718:	00 
    1719:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1720:	e8 3b 24 00 00       	call   3b60 <printf>
}
    1725:	83 c4 14             	add    $0x14,%esp
    1728:	5b                   	pop    %ebx
    1729:	5d                   	pop    %ebp
    172a:	c3                   	ret    
  unlink("lf1");
  unlink("lf2");

  fd = open("lf1", O_CREATE|O_RDWR);
  if(fd < 0){
    printf(1, "create lf1 failed\n");
    172b:	c7 44 24 04 aa 43 00 	movl   $0x43aa,0x4(%esp)
    1732:	00 
    1733:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    173a:	e8 21 24 00 00       	call   3b60 <printf>
    exit();
    173f:	e8 ec 22 00 00       	call   3a30 <exit>
    printf(1, "link non-existant succeeded! oops\n");
    exit();
  }

  if(link(".", "lf1") >= 0){
    printf(1, "link . lf1 succeeded! oops\n");
    1744:	c7 44 24 04 24 44 00 	movl   $0x4424,0x4(%esp)
    174b:	00 
    174c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1753:	e8 08 24 00 00       	call   3b60 <printf>
    exit();
    1758:	e8 d3 22 00 00       	call   3a30 <exit>
    exit();
  }

  unlink("lf2");
  if(link("lf2", "lf1") >= 0){
    printf(1, "link non-existant succeeded! oops\n");
    175d:	c7 44 24 04 d8 4f 00 	movl   $0x4fd8,0x4(%esp)
    1764:	00 
    1765:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    176c:	e8 ef 23 00 00       	call   3b60 <printf>
    exit();
    1771:	e8 ba 22 00 00       	call   3a30 <exit>
    exit();
  }
  close(fd);

  if(link("lf2", "lf2") >= 0){
    printf(1, "link lf2 lf2 succeeded! oops\n");
    1776:	c7 44 24 04 06 44 00 	movl   $0x4406,0x4(%esp)
    177d:	00 
    177e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1785:	e8 d6 23 00 00       	call   3b60 <printf>
    exit();
    178a:	e8 a1 22 00 00       	call   3a30 <exit>
  if(fd < 0){
    printf(1, "open lf2 failed\n");
    exit();
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    printf(1, "read lf2 failed\n");
    178f:	c7 44 24 04 f5 43 00 	movl   $0x43f5,0x4(%esp)
    1796:	00 
    1797:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    179e:	e8 bd 23 00 00       	call   3b60 <printf>
    exit();
    17a3:	e8 88 22 00 00       	call   3a30 <exit>
    exit();
  }

  fd = open("lf2", 0);
  if(fd < 0){
    printf(1, "open lf2 failed\n");
    17a8:	c7 44 24 04 e4 43 00 	movl   $0x43e4,0x4(%esp)
    17af:	00 
    17b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17b7:	e8 a4 23 00 00       	call   3b60 <printf>
    exit();
    17bc:	e8 6f 22 00 00       	call   3a30 <exit>
    exit();
  }
  unlink("lf1");

  if(open("lf1", 0) >= 0){
    printf(1, "unlinked lf1 but it is still there!\n");
    17c1:	c7 44 24 04 b0 4f 00 	movl   $0x4fb0,0x4(%esp)
    17c8:	00 
    17c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17d0:	e8 8b 23 00 00       	call   3b60 <printf>
    exit();
    17d5:	e8 56 22 00 00       	call   3a30 <exit>
    exit();
  }
  close(fd);

  if(link("lf1", "lf2") < 0){
    printf(1, "link lf1 lf2 failed\n");
    17da:	c7 44 24 04 cf 43 00 	movl   $0x43cf,0x4(%esp)
    17e1:	00 
    17e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17e9:	e8 72 23 00 00       	call   3b60 <printf>
    exit();
    17ee:	e8 3d 22 00 00       	call   3a30 <exit>
  if(fd < 0){
    printf(1, "create lf1 failed\n");
    exit();
  }
  if(write(fd, "hello", 5) != 5){
    printf(1, "write lf1 failed\n");
    17f3:	c7 44 24 04 bd 43 00 	movl   $0x43bd,0x4(%esp)
    17fa:	00 
    17fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1802:	e8 59 23 00 00       	call   3b60 <printf>
    exit();
    1807:	e8 24 22 00 00       	call   3a30 <exit>

0000180c <concreate>:
}

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    180c:	55                   	push   %ebp
    180d:	89 e5                	mov    %esp,%ebp
    180f:	57                   	push   %edi
    1810:	56                   	push   %esi
    1811:	53                   	push   %ebx
    1812:	83 ec 6c             	sub    $0x6c,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    1815:	c7 44 24 04 4d 44 00 	movl   $0x444d,0x4(%esp)
    181c:	00 
    181d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1824:	e8 37 23 00 00       	call   3b60 <printf>
  file[0] = 'C';
    1829:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    182d:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  for(i = 0; i < 40; i++){
    1831:	31 f6                	xor    %esi,%esi
    1833:	8d 5d e5             	lea    -0x1b(%ebp),%ebx
    1836:	eb 3a                	jmp    1872 <concreate+0x66>
    file[1] = '0' + i;
    unlink(file);
    pid = fork();
    if(pid && (i % 3) == 1){
    1838:	b9 03 00 00 00       	mov    $0x3,%ecx
    183d:	99                   	cltd   
    183e:	f7 f9                	idiv   %ecx
    1840:	4a                   	dec    %edx
    1841:	74 6d                	je     18b0 <concreate+0xa4>
      link("C0", file);
    } else if(pid == 0 && (i % 5) == 1){
      link("C0", file);
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    1843:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    184a:	00 
    184b:	89 1c 24             	mov    %ebx,(%esp)
    184e:	e8 1d 22 00 00       	call   3a70 <open>
      if(fd < 0){
    1853:	85 c0                	test   %eax,%eax
    1855:	0f 88 16 02 00 00    	js     1a71 <concreate+0x265>
        printf(1, "concreate create %s failed\n", file);
        exit();
      }
      close(fd);
    185b:	89 04 24             	mov    %eax,(%esp)
    185e:	e8 f5 21 00 00       	call   3a58 <close>
    }
    if(pid == 0)
    1863:	85 ff                	test   %edi,%edi
    1865:	74 41                	je     18a8 <concreate+0x9c>
      exit();
    else
      wait();
    1867:	e8 cc 21 00 00       	call   3a38 <wait>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    186c:	46                   	inc    %esi
    186d:	83 fe 28             	cmp    $0x28,%esi
    1870:	74 5a                	je     18cc <concreate+0xc0>
  printf(1, "linktest ok\n");
}

// test concurrent create/link/unlink of the same file
void
concreate(void)
    1872:	8d 46 30             	lea    0x30(%esi),%eax
    1875:	88 45 e6             	mov    %al,-0x1a(%ebp)
  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    file[1] = '0' + i;
    unlink(file);
    1878:	89 1c 24             	mov    %ebx,(%esp)
    187b:	e8 00 22 00 00       	call   3a80 <unlink>
    pid = fork();
    1880:	e8 a3 21 00 00       	call   3a28 <fork>
    1885:	89 c7                	mov    %eax,%edi
    if(pid && (i % 3) == 1){
    1887:	89 f0                	mov    %esi,%eax
    1889:	85 ff                	test   %edi,%edi
    188b:	75 ab                	jne    1838 <concreate+0x2c>
      link("C0", file);
    } else if(pid == 0 && (i % 5) == 1){
    188d:	b9 05 00 00 00       	mov    $0x5,%ecx
    1892:	99                   	cltd   
    1893:	f7 f9                	idiv   %ecx
    1895:	4a                   	dec    %edx
    1896:	75 ab                	jne    1843 <concreate+0x37>
      link("C0", file);
    1898:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    189c:	c7 04 24 5d 44 00 00 	movl   $0x445d,(%esp)
    18a3:	e8 e8 21 00 00       	call   3a90 <link>
      continue;
    if(de.name[0] == 'C' && de.name[2] == '\0'){
      i = de.name[1] - '0';
      if(i < 0 || i >= sizeof(fa)){
        printf(1, "concreate weird file %s\n", de.name);
        exit();
    18a8:	e8 83 21 00 00       	call   3a30 <exit>
    18ad:	8d 76 00             	lea    0x0(%esi),%esi
  for(i = 0; i < 40; i++){
    file[1] = '0' + i;
    unlink(file);
    pid = fork();
    if(pid && (i % 3) == 1){
      link("C0", file);
    18b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    18b4:	c7 04 24 5d 44 00 00 	movl   $0x445d,(%esp)
    18bb:	e8 d0 21 00 00       	call   3a90 <link>
      close(fd);
    }
    if(pid == 0)
      exit();
    else
      wait();
    18c0:	e8 73 21 00 00       	call   3a38 <wait>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    18c5:	46                   	inc    %esi
    18c6:	83 fe 28             	cmp    $0x28,%esi
    18c9:	75 a7                	jne    1872 <concreate+0x66>
    18cb:	90                   	nop
      exit();
    else
      wait();
  }

  memset(fa, 0, sizeof(fa));
    18cc:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
    18d3:	00 
    18d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    18db:	00 
    18dc:	8d 45 ac             	lea    -0x54(%ebp),%eax
    18df:	89 04 24             	mov    %eax,(%esp)
    18e2:	e8 09 20 00 00       	call   38f0 <memset>
  fd = open(".", 0);
    18e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    18ee:	00 
    18ef:	c7 04 24 6a 46 00 00 	movl   $0x466a,(%esp)
    18f6:	e8 75 21 00 00       	call   3a70 <open>
    18fb:	89 c6                	mov    %eax,%esi
  n = 0;
    18fd:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
    1904:	8d 7d d4             	lea    -0x2c(%ebp),%edi
    1907:	90                   	nop
  while(read(fd, &de, sizeof(de)) > 0){
    1908:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    190f:	00 
    1910:	89 7c 24 04          	mov    %edi,0x4(%esp)
    1914:	89 34 24             	mov    %esi,(%esp)
    1917:	e8 2c 21 00 00       	call   3a48 <read>
    191c:	85 c0                	test   %eax,%eax
    191e:	7e 38                	jle    1958 <concreate+0x14c>
    if(de.inum == 0)
    1920:	66 83 7d d4 00       	cmpw   $0x0,-0x2c(%ebp)
    1925:	74 e1                	je     1908 <concreate+0xfc>
      continue;
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    1927:	80 7d d6 43          	cmpb   $0x43,-0x2a(%ebp)
    192b:	75 db                	jne    1908 <concreate+0xfc>
    192d:	80 7d d8 00          	cmpb   $0x0,-0x28(%ebp)
    1931:	75 d5                	jne    1908 <concreate+0xfc>
      i = de.name[1] - '0';
    1933:	0f be 45 d7          	movsbl -0x29(%ebp),%eax
    1937:	83 e8 30             	sub    $0x30,%eax
      if(i < 0 || i >= sizeof(fa)){
    193a:	83 f8 27             	cmp    $0x27,%eax
    193d:	0f 87 4b 01 00 00    	ja     1a8e <concreate+0x282>
        printf(1, "concreate weird file %s\n", de.name);
        exit();
      }
      if(fa[i]){
    1943:	80 7c 05 ac 00       	cmpb   $0x0,-0x54(%ebp,%eax,1)
    1948:	0f 85 79 01 00 00    	jne    1ac7 <concreate+0x2bb>
        printf(1, "concreate duplicate file %s\n", de.name);
        exit();
      }
      fa[i] = 1;
    194e:	c6 44 05 ac 01       	movb   $0x1,-0x54(%ebp,%eax,1)
      n++;
    1953:	ff 45 a4             	incl   -0x5c(%ebp)
    1956:	eb b0                	jmp    1908 <concreate+0xfc>
    }
  }
  close(fd);
    1958:	89 34 24             	mov    %esi,(%esp)
    195b:	e8 f8 20 00 00       	call   3a58 <close>

  if(n != 40){
    1960:	83 7d a4 28          	cmpl   $0x28,-0x5c(%ebp)
    1964:	0f 85 44 01 00 00    	jne    1aae <concreate+0x2a2>
    196a:	31 ff                	xor    %edi,%edi
    196c:	eb 7d                	jmp    19eb <concreate+0x1df>
    196e:	66 90                	xchg   %ax,%ax
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
      exit();
    }
    if(((i % 3) == 0 && pid == 0) ||
    1970:	85 f6                	test   %esi,%esi
    1972:	0f 85 a1 00 00 00    	jne    1a19 <concreate+0x20d>
       ((i % 3) == 1 && pid != 0)){
      close(open(file, 0));
    1978:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    197f:	00 
    1980:	89 1c 24             	mov    %ebx,(%esp)
    1983:	e8 e8 20 00 00       	call   3a70 <open>
    1988:	89 04 24             	mov    %eax,(%esp)
    198b:	e8 c8 20 00 00       	call   3a58 <close>
      close(open(file, 0));
    1990:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1997:	00 
    1998:	89 1c 24             	mov    %ebx,(%esp)
    199b:	e8 d0 20 00 00       	call   3a70 <open>
    19a0:	89 04 24             	mov    %eax,(%esp)
    19a3:	e8 b0 20 00 00       	call   3a58 <close>
      close(open(file, 0));
    19a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    19af:	00 
    19b0:	89 1c 24             	mov    %ebx,(%esp)
    19b3:	e8 b8 20 00 00       	call   3a70 <open>
    19b8:	89 04 24             	mov    %eax,(%esp)
    19bb:	e8 98 20 00 00       	call   3a58 <close>
      close(open(file, 0));
    19c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    19c7:	00 
    19c8:	89 1c 24             	mov    %ebx,(%esp)
    19cb:	e8 a0 20 00 00       	call   3a70 <open>
    19d0:	89 04 24             	mov    %eax,(%esp)
    19d3:	e8 80 20 00 00       	call   3a58 <close>
      unlink(file);
      unlink(file);
      unlink(file);
      unlink(file);
    }
    if(pid == 0)
    19d8:	85 f6                	test   %esi,%esi
    19da:	0f 84 c8 fe ff ff    	je     18a8 <concreate+0x9c>
      exit();
    else
      wait();
    19e0:	e8 53 20 00 00       	call   3a38 <wait>
  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    exit();
  }

  for(i = 0; i < 40; i++){
    19e5:	47                   	inc    %edi
    19e6:	83 ff 28             	cmp    $0x28,%edi
    19e9:	74 51                	je     1a3c <concreate+0x230>
  printf(1, "linktest ok\n");
}

// test concurrent create/link/unlink of the same file
void
concreate(void)
    19eb:	8d 47 30             	lea    0x30(%edi),%eax
    19ee:	88 45 e6             	mov    %al,-0x1a(%ebp)
    exit();
  }

  for(i = 0; i < 40; i++){
    file[1] = '0' + i;
    pid = fork();
    19f1:	e8 32 20 00 00       	call   3a28 <fork>
    19f6:	89 c6                	mov    %eax,%esi
    if(pid < 0){
    19f8:	85 c0                	test   %eax,%eax
    19fa:	78 5c                	js     1a58 <concreate+0x24c>
      printf(1, "fork failed\n");
      exit();
    }
    if(((i % 3) == 0 && pid == 0) ||
    19fc:	89 f8                	mov    %edi,%eax
    19fe:	b9 03 00 00 00       	mov    $0x3,%ecx
    1a03:	99                   	cltd   
    1a04:	f7 f9                	idiv   %ecx
    1a06:	85 d2                	test   %edx,%edx
    1a08:	0f 84 62 ff ff ff    	je     1970 <concreate+0x164>
    1a0e:	4a                   	dec    %edx
    1a0f:	75 08                	jne    1a19 <concreate+0x20d>
       ((i % 3) == 1 && pid != 0)){
    1a11:	85 f6                	test   %esi,%esi
    1a13:	0f 85 5f ff ff ff    	jne    1978 <concreate+0x16c>
      close(open(file, 0));
      close(open(file, 0));
      close(open(file, 0));
      close(open(file, 0));
    } else {
      unlink(file);
    1a19:	89 1c 24             	mov    %ebx,(%esp)
    1a1c:	e8 5f 20 00 00       	call   3a80 <unlink>
      unlink(file);
    1a21:	89 1c 24             	mov    %ebx,(%esp)
    1a24:	e8 57 20 00 00       	call   3a80 <unlink>
      unlink(file);
    1a29:	89 1c 24             	mov    %ebx,(%esp)
    1a2c:	e8 4f 20 00 00       	call   3a80 <unlink>
      unlink(file);
    1a31:	89 1c 24             	mov    %ebx,(%esp)
    1a34:	e8 47 20 00 00       	call   3a80 <unlink>
    1a39:	eb 9d                	jmp    19d8 <concreate+0x1cc>
    1a3b:	90                   	nop
      exit();
    else
      wait();
  }

  printf(1, "concreate ok\n");
    1a3c:	c7 44 24 04 b2 44 00 	movl   $0x44b2,0x4(%esp)
    1a43:	00 
    1a44:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a4b:	e8 10 21 00 00       	call   3b60 <printf>
}
    1a50:	83 c4 6c             	add    $0x6c,%esp
    1a53:	5b                   	pop    %ebx
    1a54:	5e                   	pop    %esi
    1a55:	5f                   	pop    %edi
    1a56:	5d                   	pop    %ebp
    1a57:	c3                   	ret    

  for(i = 0; i < 40; i++){
    file[1] = '0' + i;
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
    1a58:	c7 44 24 04 35 4d 00 	movl   $0x4d35,0x4(%esp)
    1a5f:	00 
    1a60:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a67:	e8 f4 20 00 00       	call   3b60 <printf>
      exit();
    1a6c:	e8 bf 1f 00 00       	call   3a30 <exit>
    } else if(pid == 0 && (i % 5) == 1){
      link("C0", file);
    } else {
      fd = open(file, O_CREATE | O_RDWR);
      if(fd < 0){
        printf(1, "concreate create %s failed\n", file);
    1a71:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    1a75:	c7 44 24 04 60 44 00 	movl   $0x4460,0x4(%esp)
    1a7c:	00 
    1a7d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a84:	e8 d7 20 00 00       	call   3b60 <printf>
        exit();
    1a89:	e8 a2 1f 00 00       	call   3a30 <exit>
    if(de.inum == 0)
      continue;
    if(de.name[0] == 'C' && de.name[2] == '\0'){
      i = de.name[1] - '0';
      if(i < 0 || i >= sizeof(fa)){
        printf(1, "concreate weird file %s\n", de.name);
    1a8e:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    1a91:	89 44 24 08          	mov    %eax,0x8(%esp)
    1a95:	c7 44 24 04 7c 44 00 	movl   $0x447c,0x4(%esp)
    1a9c:	00 
    1a9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1aa4:	e8 b7 20 00 00       	call   3b60 <printf>
    1aa9:	e9 fa fd ff ff       	jmp    18a8 <concreate+0x9c>
    }
  }
  close(fd);

  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    1aae:	c7 44 24 04 fc 4f 00 	movl   $0x4ffc,0x4(%esp)
    1ab5:	00 
    1ab6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1abd:	e8 9e 20 00 00       	call   3b60 <printf>
    exit();
    1ac2:	e8 69 1f 00 00       	call   3a30 <exit>
      if(i < 0 || i >= sizeof(fa)){
        printf(1, "concreate weird file %s\n", de.name);
        exit();
      }
      if(fa[i]){
        printf(1, "concreate duplicate file %s\n", de.name);
    1ac7:	8d 45 d6             	lea    -0x2a(%ebp),%eax
    1aca:	89 44 24 08          	mov    %eax,0x8(%esp)
    1ace:	c7 44 24 04 95 44 00 	movl   $0x4495,0x4(%esp)
    1ad5:	00 
    1ad6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1add:	e8 7e 20 00 00       	call   3b60 <printf>
        exit();
    1ae2:	e8 49 1f 00 00       	call   3a30 <exit>
    1ae7:	90                   	nop

00001ae8 <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    1ae8:	55                   	push   %ebp
    1ae9:	89 e5                	mov    %esp,%ebp
    1aeb:	57                   	push   %edi
    1aec:	56                   	push   %esi
    1aed:	53                   	push   %ebx
    1aee:	83 ec 2c             	sub    $0x2c,%esp
  int pid, i;

  printf(1, "linkunlink test\n");
    1af1:	c7 44 24 04 c0 44 00 	movl   $0x44c0,0x4(%esp)
    1af8:	00 
    1af9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b00:	e8 5b 20 00 00       	call   3b60 <printf>

  unlink("x");
    1b05:	c7 04 24 4d 47 00 00 	movl   $0x474d,(%esp)
    1b0c:	e8 6f 1f 00 00       	call   3a80 <unlink>
  pid = fork();
    1b11:	e8 12 1f 00 00       	call   3a28 <fork>
    1b16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(pid < 0){
    1b19:	85 c0                	test   %eax,%eax
    1b1b:	0f 88 c0 00 00 00    	js     1be1 <linkunlink+0xf9>
    printf(1, "fork failed\n");
    exit();
  }

  unsigned int x = (pid ? 1 : 97);
    1b21:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
    1b25:	19 db                	sbb    %ebx,%ebx
    1b27:	83 e3 60             	and    $0x60,%ebx
    1b2a:	43                   	inc    %ebx
    1b2b:	be 64 00 00 00       	mov    $0x64,%esi
  for(i = 0; i < 100; i++){
    x = x * 1103515245 + 12345;
    if((x % 3) == 0){
    1b30:	bf 03 00 00 00       	mov    $0x3,%edi
    1b35:	eb 17                	jmp    1b4e <linkunlink+0x66>
    1b37:	90                   	nop
      close(open("x", O_RDWR | O_CREATE));
    } else if((x % 3) == 1){
    1b38:	4a                   	dec    %edx
    1b39:	0f 84 89 00 00 00    	je     1bc8 <linkunlink+0xe0>
      link("cat", "x");
    } else {
      unlink("x");
    1b3f:	c7 04 24 4d 47 00 00 	movl   $0x474d,(%esp)
    1b46:	e8 35 1f 00 00       	call   3a80 <unlink>
    printf(1, "fork failed\n");
    exit();
  }

  unsigned int x = (pid ? 1 : 97);
  for(i = 0; i < 100; i++){
    1b4b:	4e                   	dec    %esi
    1b4c:	74 50                	je     1b9e <linkunlink+0xb6>
    x = x * 1103515245 + 12345;
    1b4e:	89 d8                	mov    %ebx,%eax
    1b50:	c1 e0 09             	shl    $0x9,%eax
    1b53:	29 d8                	sub    %ebx,%eax
    1b55:	8d 14 83             	lea    (%ebx,%eax,4),%edx
    1b58:	89 d0                	mov    %edx,%eax
    1b5a:	c1 e0 09             	shl    $0x9,%eax
    1b5d:	29 d0                	sub    %edx,%eax
    1b5f:	8d 04 43             	lea    (%ebx,%eax,2),%eax
    1b62:	89 c2                	mov    %eax,%edx
    1b64:	c1 e2 05             	shl    $0x5,%edx
    1b67:	01 d0                	add    %edx,%eax
    1b69:	c1 e0 02             	shl    $0x2,%eax
    1b6c:	29 d8                	sub    %ebx,%eax
    1b6e:	8d 9c 83 39 30 00 00 	lea    0x3039(%ebx,%eax,4),%ebx
    if((x % 3) == 0){
    1b75:	89 d8                	mov    %ebx,%eax
    1b77:	31 d2                	xor    %edx,%edx
    1b79:	f7 f7                	div    %edi
    1b7b:	85 d2                	test   %edx,%edx
    1b7d:	75 b9                	jne    1b38 <linkunlink+0x50>
      close(open("x", O_RDWR | O_CREATE));
    1b7f:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1b86:	00 
    1b87:	c7 04 24 4d 47 00 00 	movl   $0x474d,(%esp)
    1b8e:	e8 dd 1e 00 00       	call   3a70 <open>
    1b93:	89 04 24             	mov    %eax,(%esp)
    1b96:	e8 bd 1e 00 00       	call   3a58 <close>
    printf(1, "fork failed\n");
    exit();
  }

  unsigned int x = (pid ? 1 : 97);
  for(i = 0; i < 100; i++){
    1b9b:	4e                   	dec    %esi
    1b9c:	75 b0                	jne    1b4e <linkunlink+0x66>
    } else {
      unlink("x");
    }
  }

  if(pid)
    1b9e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
    1ba1:	85 d2                	test   %edx,%edx
    1ba3:	74 55                	je     1bfa <linkunlink+0x112>
    wait();
    1ba5:	e8 8e 1e 00 00       	call   3a38 <wait>
  else
    exit();

  printf(1, "linkunlink ok\n");
    1baa:	c7 44 24 04 d5 44 00 	movl   $0x44d5,0x4(%esp)
    1bb1:	00 
    1bb2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1bb9:	e8 a2 1f 00 00       	call   3b60 <printf>
}
    1bbe:	83 c4 2c             	add    $0x2c,%esp
    1bc1:	5b                   	pop    %ebx
    1bc2:	5e                   	pop    %esi
    1bc3:	5f                   	pop    %edi
    1bc4:	5d                   	pop    %ebp
    1bc5:	c3                   	ret    
    1bc6:	66 90                	xchg   %ax,%ax
  for(i = 0; i < 100; i++){
    x = x * 1103515245 + 12345;
    if((x % 3) == 0){
      close(open("x", O_RDWR | O_CREATE));
    } else if((x % 3) == 1){
      link("cat", "x");
    1bc8:	c7 44 24 04 4d 47 00 	movl   $0x474d,0x4(%esp)
    1bcf:	00 
    1bd0:	c7 04 24 d1 44 00 00 	movl   $0x44d1,(%esp)
    1bd7:	e8 b4 1e 00 00       	call   3a90 <link>
    1bdc:	e9 6a ff ff ff       	jmp    1b4b <linkunlink+0x63>
  printf(1, "linkunlink test\n");

  unlink("x");
  pid = fork();
  if(pid < 0){
    printf(1, "fork failed\n");
    1be1:	c7 44 24 04 35 4d 00 	movl   $0x4d35,0x4(%esp)
    1be8:	00 
    1be9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1bf0:	e8 6b 1f 00 00       	call   3b60 <printf>
    exit();
    1bf5:	e8 36 1e 00 00       	call   3a30 <exit>
  }

  if(pid)
    wait();
  else
    exit();
    1bfa:	e8 31 1e 00 00       	call   3a30 <exit>
    1bff:	90                   	nop

00001c00 <bigdir>:
}

// directory that uses indirect blocks
void
bigdir(void)
{
    1c00:	55                   	push   %ebp
    1c01:	89 e5                	mov    %esp,%ebp
    1c03:	56                   	push   %esi
    1c04:	53                   	push   %ebx
    1c05:	83 ec 20             	sub    $0x20,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    1c08:	c7 44 24 04 e4 44 00 	movl   $0x44e4,0x4(%esp)
    1c0f:	00 
    1c10:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1c17:	e8 44 1f 00 00       	call   3b60 <printf>
  unlink("bd");
    1c1c:	c7 04 24 f1 44 00 00 	movl   $0x44f1,(%esp)
    1c23:	e8 58 1e 00 00       	call   3a80 <unlink>

  fd = open("bd", O_CREATE);
    1c28:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    1c2f:	00 
    1c30:	c7 04 24 f1 44 00 00 	movl   $0x44f1,(%esp)
    1c37:	e8 34 1e 00 00       	call   3a70 <open>
  if(fd < 0){
    1c3c:	85 c0                	test   %eax,%eax
    1c3e:	0f 88 dc 00 00 00    	js     1d20 <bigdir+0x120>
    printf(1, "bigdir create failed\n");
    exit();
  }
  close(fd);
    1c44:	89 04 24             	mov    %eax,(%esp)
    1c47:	e8 0c 1e 00 00       	call   3a58 <close>

  for(i = 0; i < 500; i++){
    1c4c:	31 db                	xor    %ebx,%ebx
    1c4e:	8d 75 ee             	lea    -0x12(%ebp),%esi
    1c51:	8d 76 00             	lea    0x0(%esi),%esi
    name[0] = 'x';
    1c54:	c6 45 ee 78          	movb   $0x78,-0x12(%ebp)
    name[1] = '0' + (i / 64);
    1c58:	89 d8                	mov    %ebx,%eax
    1c5a:	c1 f8 06             	sar    $0x6,%eax
    1c5d:	83 c0 30             	add    $0x30,%eax
    1c60:	88 45 ef             	mov    %al,-0x11(%ebp)
    name[2] = '0' + (i % 64);
    1c63:	89 d8                	mov    %ebx,%eax
    1c65:	83 e0 3f             	and    $0x3f,%eax
    1c68:	83 c0 30             	add    $0x30,%eax
    1c6b:	88 45 f0             	mov    %al,-0x10(%ebp)
    name[3] = '\0';
    1c6e:	c6 45 f1 00          	movb   $0x0,-0xf(%ebp)
    if(link("bd", name) != 0){
    1c72:	89 74 24 04          	mov    %esi,0x4(%esp)
    1c76:	c7 04 24 f1 44 00 00 	movl   $0x44f1,(%esp)
    1c7d:	e8 0e 1e 00 00       	call   3a90 <link>
    1c82:	85 c0                	test   %eax,%eax
    1c84:	75 68                	jne    1cee <bigdir+0xee>
    printf(1, "bigdir create failed\n");
    exit();
  }
  close(fd);

  for(i = 0; i < 500; i++){
    1c86:	43                   	inc    %ebx
    1c87:	81 fb f4 01 00 00    	cmp    $0x1f4,%ebx
    1c8d:	75 c5                	jne    1c54 <bigdir+0x54>
      printf(1, "bigdir link failed\n");
      exit();
    }
  }

  unlink("bd");
    1c8f:	c7 04 24 f1 44 00 00 	movl   $0x44f1,(%esp)
    1c96:	e8 e5 1d 00 00       	call   3a80 <unlink>
  for(i = 0; i < 500; i++){
    1c9b:	66 31 db             	xor    %bx,%bx
    1c9e:	66 90                	xchg   %ax,%ax
    name[0] = 'x';
    1ca0:	c6 45 ee 78          	movb   $0x78,-0x12(%ebp)
    name[1] = '0' + (i / 64);
    1ca4:	89 d8                	mov    %ebx,%eax
    1ca6:	c1 f8 06             	sar    $0x6,%eax
    1ca9:	83 c0 30             	add    $0x30,%eax
    1cac:	88 45 ef             	mov    %al,-0x11(%ebp)
    name[2] = '0' + (i % 64);
    1caf:	89 d8                	mov    %ebx,%eax
    1cb1:	83 e0 3f             	and    $0x3f,%eax
    1cb4:	83 c0 30             	add    $0x30,%eax
    1cb7:	88 45 f0             	mov    %al,-0x10(%ebp)
    name[3] = '\0';
    1cba:	c6 45 f1 00          	movb   $0x0,-0xf(%ebp)
    if(unlink(name) != 0){
    1cbe:	89 34 24             	mov    %esi,(%esp)
    1cc1:	e8 ba 1d 00 00       	call   3a80 <unlink>
    1cc6:	85 c0                	test   %eax,%eax
    1cc8:	75 3d                	jne    1d07 <bigdir+0x107>
      exit();
    }
  }

  unlink("bd");
  for(i = 0; i < 500; i++){
    1cca:	43                   	inc    %ebx
    1ccb:	81 fb f4 01 00 00    	cmp    $0x1f4,%ebx
    1cd1:	75 cd                	jne    1ca0 <bigdir+0xa0>
      printf(1, "bigdir unlink failed");
      exit();
    }
  }

  printf(1, "bigdir ok\n");
    1cd3:	c7 44 24 04 33 45 00 	movl   $0x4533,0x4(%esp)
    1cda:	00 
    1cdb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ce2:	e8 79 1e 00 00       	call   3b60 <printf>
}
    1ce7:	83 c4 20             	add    $0x20,%esp
    1cea:	5b                   	pop    %ebx
    1ceb:	5e                   	pop    %esi
    1cec:	5d                   	pop    %ebp
    1ced:	c3                   	ret    
    name[0] = 'x';
    name[1] = '0' + (i / 64);
    name[2] = '0' + (i % 64);
    name[3] = '\0';
    if(link("bd", name) != 0){
      printf(1, "bigdir link failed\n");
    1cee:	c7 44 24 04 0a 45 00 	movl   $0x450a,0x4(%esp)
    1cf5:	00 
    1cf6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1cfd:	e8 5e 1e 00 00       	call   3b60 <printf>
      exit();
    1d02:	e8 29 1d 00 00       	call   3a30 <exit>
    name[0] = 'x';
    name[1] = '0' + (i / 64);
    name[2] = '0' + (i % 64);
    name[3] = '\0';
    if(unlink(name) != 0){
      printf(1, "bigdir unlink failed");
    1d07:	c7 44 24 04 1e 45 00 	movl   $0x451e,0x4(%esp)
    1d0e:	00 
    1d0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d16:	e8 45 1e 00 00       	call   3b60 <printf>
      exit();
    1d1b:	e8 10 1d 00 00       	call   3a30 <exit>
  printf(1, "bigdir test\n");
  unlink("bd");

  fd = open("bd", O_CREATE);
  if(fd < 0){
    printf(1, "bigdir create failed\n");
    1d20:	c7 44 24 04 f4 44 00 	movl   $0x44f4,0x4(%esp)
    1d27:	00 
    1d28:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d2f:	e8 2c 1e 00 00       	call   3b60 <printf>
    exit();
    1d34:	e8 f7 1c 00 00       	call   3a30 <exit>
    1d39:	8d 76 00             	lea    0x0(%esi),%esi

00001d3c <subdir>:
  printf(1, "bigdir ok\n");
}

void
subdir(void)
{
    1d3c:	55                   	push   %ebp
    1d3d:	89 e5                	mov    %esp,%ebp
    1d3f:	53                   	push   %ebx
    1d40:	83 ec 14             	sub    $0x14,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    1d43:	c7 44 24 04 3e 45 00 	movl   $0x453e,0x4(%esp)
    1d4a:	00 
    1d4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d52:	e8 09 1e 00 00       	call   3b60 <printf>

  unlink("ff");
    1d57:	c7 04 24 c7 45 00 00 	movl   $0x45c7,(%esp)
    1d5e:	e8 1d 1d 00 00       	call   3a80 <unlink>
  if(mkdir("dd") != 0){
    1d63:	c7 04 24 64 46 00 00 	movl   $0x4664,(%esp)
    1d6a:	e8 29 1d 00 00       	call   3a98 <mkdir>
    1d6f:	85 c0                	test   %eax,%eax
    1d71:	0f 85 07 06 00 00    	jne    237e <subdir+0x642>
    printf(1, "subdir mkdir dd failed\n");
    exit();
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    1d77:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1d7e:	00 
    1d7f:	c7 04 24 9d 45 00 00 	movl   $0x459d,(%esp)
    1d86:	e8 e5 1c 00 00       	call   3a70 <open>
    1d8b:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1d8d:	85 c0                	test   %eax,%eax
    1d8f:	0f 88 d0 05 00 00    	js     2365 <subdir+0x629>
    printf(1, "create dd/ff failed\n");
    exit();
  }
  write(fd, "ff", 2);
    1d95:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    1d9c:	00 
    1d9d:	c7 44 24 04 c7 45 00 	movl   $0x45c7,0x4(%esp)
    1da4:	00 
    1da5:	89 04 24             	mov    %eax,(%esp)
    1da8:	e8 a3 1c 00 00       	call   3a50 <write>
  close(fd);
    1dad:	89 1c 24             	mov    %ebx,(%esp)
    1db0:	e8 a3 1c 00 00       	call   3a58 <close>

  if(unlink("dd") >= 0){
    1db5:	c7 04 24 64 46 00 00 	movl   $0x4664,(%esp)
    1dbc:	e8 bf 1c 00 00       	call   3a80 <unlink>
    1dc1:	85 c0                	test   %eax,%eax
    1dc3:	0f 89 83 05 00 00    	jns    234c <subdir+0x610>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    exit();
  }

  if(mkdir("/dd/dd") != 0){
    1dc9:	c7 04 24 78 45 00 00 	movl   $0x4578,(%esp)
    1dd0:	e8 c3 1c 00 00       	call   3a98 <mkdir>
    1dd5:	85 c0                	test   %eax,%eax
    1dd7:	0f 85 56 05 00 00    	jne    2333 <subdir+0x5f7>
    printf(1, "subdir mkdir dd/dd failed\n");
    exit();
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    1ddd:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1de4:	00 
    1de5:	c7 04 24 9a 45 00 00 	movl   $0x459a,(%esp)
    1dec:	e8 7f 1c 00 00       	call   3a70 <open>
    1df1:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1df3:	85 c0                	test   %eax,%eax
    1df5:	0f 88 25 04 00 00    	js     2220 <subdir+0x4e4>
    printf(1, "create dd/dd/ff failed\n");
    exit();
  }
  write(fd, "FF", 2);
    1dfb:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    1e02:	00 
    1e03:	c7 44 24 04 bb 45 00 	movl   $0x45bb,0x4(%esp)
    1e0a:	00 
    1e0b:	89 04 24             	mov    %eax,(%esp)
    1e0e:	e8 3d 1c 00 00       	call   3a50 <write>
  close(fd);
    1e13:	89 1c 24             	mov    %ebx,(%esp)
    1e16:	e8 3d 1c 00 00       	call   3a58 <close>

  fd = open("dd/dd/../ff", 0);
    1e1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1e22:	00 
    1e23:	c7 04 24 be 45 00 00 	movl   $0x45be,(%esp)
    1e2a:	e8 41 1c 00 00       	call   3a70 <open>
    1e2f:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1e31:	85 c0                	test   %eax,%eax
    1e33:	0f 88 ce 03 00 00    	js     2207 <subdir+0x4cb>
    printf(1, "open dd/dd/../ff failed\n");
    exit();
  }
  cc = read(fd, buf, sizeof(buf));
    1e39:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1e40:	00 
    1e41:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
    1e48:	00 
    1e49:	89 04 24             	mov    %eax,(%esp)
    1e4c:	e8 f7 1b 00 00       	call   3a48 <read>
  if(cc != 2 || buf[0] != 'f'){
    1e51:	83 f8 02             	cmp    $0x2,%eax
    1e54:	0f 85 fe 02 00 00    	jne    2158 <subdir+0x41c>
    1e5a:	80 3d 80 86 00 00 66 	cmpb   $0x66,0x8680
    1e61:	0f 85 f1 02 00 00    	jne    2158 <subdir+0x41c>
    printf(1, "dd/dd/../ff wrong content\n");
    exit();
  }
  close(fd);
    1e67:	89 1c 24             	mov    %ebx,(%esp)
    1e6a:	e8 e9 1b 00 00       	call   3a58 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    1e6f:	c7 44 24 04 fe 45 00 	movl   $0x45fe,0x4(%esp)
    1e76:	00 
    1e77:	c7 04 24 9a 45 00 00 	movl   $0x459a,(%esp)
    1e7e:	e8 0d 1c 00 00       	call   3a90 <link>
    1e83:	85 c0                	test   %eax,%eax
    1e85:	0f 85 c7 03 00 00    	jne    2252 <subdir+0x516>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    exit();
  }

  if(unlink("dd/dd/ff") != 0){
    1e8b:	c7 04 24 9a 45 00 00 	movl   $0x459a,(%esp)
    1e92:	e8 e9 1b 00 00       	call   3a80 <unlink>
    1e97:	85 c0                	test   %eax,%eax
    1e99:	0f 85 eb 02 00 00    	jne    218a <subdir+0x44e>
    printf(1, "unlink dd/dd/ff failed\n");
    exit();
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    1e9f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1ea6:	00 
    1ea7:	c7 04 24 9a 45 00 00 	movl   $0x459a,(%esp)
    1eae:	e8 bd 1b 00 00       	call   3a70 <open>
    1eb3:	85 c0                	test   %eax,%eax
    1eb5:	0f 89 5f 04 00 00    	jns    231a <subdir+0x5de>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    exit();
  }

  if(chdir("dd") != 0){
    1ebb:	c7 04 24 64 46 00 00 	movl   $0x4664,(%esp)
    1ec2:	e8 d9 1b 00 00       	call   3aa0 <chdir>
    1ec7:	85 c0                	test   %eax,%eax
    1ec9:	0f 85 32 04 00 00    	jne    2301 <subdir+0x5c5>
    printf(1, "chdir dd failed\n");
    exit();
  }
  if(chdir("dd/../../dd") != 0){
    1ecf:	c7 04 24 32 46 00 00 	movl   $0x4632,(%esp)
    1ed6:	e8 c5 1b 00 00       	call   3aa0 <chdir>
    1edb:	85 c0                	test   %eax,%eax
    1edd:	0f 85 8e 02 00 00    	jne    2171 <subdir+0x435>
    printf(1, "chdir dd/../../dd failed\n");
    exit();
  }
  if(chdir("dd/../../../dd") != 0){
    1ee3:	c7 04 24 58 46 00 00 	movl   $0x4658,(%esp)
    1eea:	e8 b1 1b 00 00       	call   3aa0 <chdir>
    1eef:	85 c0                	test   %eax,%eax
    1ef1:	0f 85 7a 02 00 00    	jne    2171 <subdir+0x435>
    printf(1, "chdir dd/../../dd failed\n");
    exit();
  }
  if(chdir("./..") != 0){
    1ef7:	c7 04 24 67 46 00 00 	movl   $0x4667,(%esp)
    1efe:	e8 9d 1b 00 00       	call   3aa0 <chdir>
    1f03:	85 c0                	test   %eax,%eax
    1f05:	0f 85 2e 03 00 00    	jne    2239 <subdir+0x4fd>
    printf(1, "chdir ./.. failed\n");
    exit();
  }

  fd = open("dd/dd/ffff", 0);
    1f0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1f12:	00 
    1f13:	c7 04 24 fe 45 00 00 	movl   $0x45fe,(%esp)
    1f1a:	e8 51 1b 00 00       	call   3a70 <open>
    1f1f:	89 c3                	mov    %eax,%ebx
  if(fd < 0){
    1f21:	85 c0                	test   %eax,%eax
    1f23:	0f 88 81 05 00 00    	js     24aa <subdir+0x76e>
    printf(1, "open dd/dd/ffff failed\n");
    exit();
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    1f29:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1f30:	00 
    1f31:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
    1f38:	00 
    1f39:	89 04 24             	mov    %eax,(%esp)
    1f3c:	e8 07 1b 00 00       	call   3a48 <read>
    1f41:	83 f8 02             	cmp    $0x2,%eax
    1f44:	0f 85 47 05 00 00    	jne    2491 <subdir+0x755>
    printf(1, "read dd/dd/ffff wrong len\n");
    exit();
  }
  close(fd);
    1f4a:	89 1c 24             	mov    %ebx,(%esp)
    1f4d:	e8 06 1b 00 00       	call   3a58 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    1f52:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1f59:	00 
    1f5a:	c7 04 24 9a 45 00 00 	movl   $0x459a,(%esp)
    1f61:	e8 0a 1b 00 00       	call   3a70 <open>
    1f66:	85 c0                	test   %eax,%eax
    1f68:	0f 89 4e 02 00 00    	jns    21bc <subdir+0x480>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    exit();
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    1f6e:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1f75:	00 
    1f76:	c7 04 24 b2 46 00 00 	movl   $0x46b2,(%esp)
    1f7d:	e8 ee 1a 00 00       	call   3a70 <open>
    1f82:	85 c0                	test   %eax,%eax
    1f84:	0f 89 19 02 00 00    	jns    21a3 <subdir+0x467>
    printf(1, "create dd/ff/ff succeeded!\n");
    exit();
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    1f8a:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1f91:	00 
    1f92:	c7 04 24 d7 46 00 00 	movl   $0x46d7,(%esp)
    1f99:	e8 d2 1a 00 00       	call   3a70 <open>
    1f9e:	85 c0                	test   %eax,%eax
    1fa0:	0f 89 42 03 00 00    	jns    22e8 <subdir+0x5ac>
    printf(1, "create dd/xx/ff succeeded!\n");
    exit();
  }
  if(open("dd", O_CREATE) >= 0){
    1fa6:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    1fad:	00 
    1fae:	c7 04 24 64 46 00 00 	movl   $0x4664,(%esp)
    1fb5:	e8 b6 1a 00 00       	call   3a70 <open>
    1fba:	85 c0                	test   %eax,%eax
    1fbc:	0f 89 0d 03 00 00    	jns    22cf <subdir+0x593>
    printf(1, "create dd succeeded!\n");
    exit();
  }
  if(open("dd", O_RDWR) >= 0){
    1fc2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    1fc9:	00 
    1fca:	c7 04 24 64 46 00 00 	movl   $0x4664,(%esp)
    1fd1:	e8 9a 1a 00 00       	call   3a70 <open>
    1fd6:	85 c0                	test   %eax,%eax
    1fd8:	0f 89 d8 02 00 00    	jns    22b6 <subdir+0x57a>
    printf(1, "open dd rdwr succeeded!\n");
    exit();
  }
  if(open("dd", O_WRONLY) >= 0){
    1fde:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
    1fe5:	00 
    1fe6:	c7 04 24 64 46 00 00 	movl   $0x4664,(%esp)
    1fed:	e8 7e 1a 00 00       	call   3a70 <open>
    1ff2:	85 c0                	test   %eax,%eax
    1ff4:	0f 89 a3 02 00 00    	jns    229d <subdir+0x561>
    printf(1, "open dd wronly succeeded!\n");
    exit();
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    1ffa:	c7 44 24 04 46 47 00 	movl   $0x4746,0x4(%esp)
    2001:	00 
    2002:	c7 04 24 b2 46 00 00 	movl   $0x46b2,(%esp)
    2009:	e8 82 1a 00 00       	call   3a90 <link>
    200e:	85 c0                	test   %eax,%eax
    2010:	0f 84 6e 02 00 00    	je     2284 <subdir+0x548>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    exit();
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2016:	c7 44 24 04 46 47 00 	movl   $0x4746,0x4(%esp)
    201d:	00 
    201e:	c7 04 24 d7 46 00 00 	movl   $0x46d7,(%esp)
    2025:	e8 66 1a 00 00       	call   3a90 <link>
    202a:	85 c0                	test   %eax,%eax
    202c:	0f 84 39 02 00 00    	je     226b <subdir+0x52f>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    exit();
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2032:	c7 44 24 04 fe 45 00 	movl   $0x45fe,0x4(%esp)
    2039:	00 
    203a:	c7 04 24 9d 45 00 00 	movl   $0x459d,(%esp)
    2041:	e8 4a 1a 00 00       	call   3a90 <link>
    2046:	85 c0                	test   %eax,%eax
    2048:	0f 84 a0 01 00 00    	je     21ee <subdir+0x4b2>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    exit();
  }
  if(mkdir("dd/ff/ff") == 0){
    204e:	c7 04 24 b2 46 00 00 	movl   $0x46b2,(%esp)
    2055:	e8 3e 1a 00 00       	call   3a98 <mkdir>
    205a:	85 c0                	test   %eax,%eax
    205c:	0f 84 73 01 00 00    	je     21d5 <subdir+0x499>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    exit();
  }
  if(mkdir("dd/xx/ff") == 0){
    2062:	c7 04 24 d7 46 00 00 	movl   $0x46d7,(%esp)
    2069:	e8 2a 1a 00 00       	call   3a98 <mkdir>
    206e:	85 c0                	test   %eax,%eax
    2070:	0f 84 02 04 00 00    	je     2478 <subdir+0x73c>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    exit();
  }
  if(mkdir("dd/dd/ffff") == 0){
    2076:	c7 04 24 fe 45 00 00 	movl   $0x45fe,(%esp)
    207d:	e8 16 1a 00 00       	call   3a98 <mkdir>
    2082:	85 c0                	test   %eax,%eax
    2084:	0f 84 d5 03 00 00    	je     245f <subdir+0x723>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    exit();
  }
  if(unlink("dd/xx/ff") == 0){
    208a:	c7 04 24 d7 46 00 00 	movl   $0x46d7,(%esp)
    2091:	e8 ea 19 00 00       	call   3a80 <unlink>
    2096:	85 c0                	test   %eax,%eax
    2098:	0f 84 a8 03 00 00    	je     2446 <subdir+0x70a>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    exit();
  }
  if(unlink("dd/ff/ff") == 0){
    209e:	c7 04 24 b2 46 00 00 	movl   $0x46b2,(%esp)
    20a5:	e8 d6 19 00 00       	call   3a80 <unlink>
    20aa:	85 c0                	test   %eax,%eax
    20ac:	0f 84 7b 03 00 00    	je     242d <subdir+0x6f1>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    exit();
  }
  if(chdir("dd/ff") == 0){
    20b2:	c7 04 24 9d 45 00 00 	movl   $0x459d,(%esp)
    20b9:	e8 e2 19 00 00       	call   3aa0 <chdir>
    20be:	85 c0                	test   %eax,%eax
    20c0:	0f 84 4e 03 00 00    	je     2414 <subdir+0x6d8>
    printf(1, "chdir dd/ff succeeded!\n");
    exit();
  }
  if(chdir("dd/xx") == 0){
    20c6:	c7 04 24 49 47 00 00 	movl   $0x4749,(%esp)
    20cd:	e8 ce 19 00 00       	call   3aa0 <chdir>
    20d2:	85 c0                	test   %eax,%eax
    20d4:	0f 84 21 03 00 00    	je     23fb <subdir+0x6bf>
    printf(1, "chdir dd/xx succeeded!\n");
    exit();
  }

  if(unlink("dd/dd/ffff") != 0){
    20da:	c7 04 24 fe 45 00 00 	movl   $0x45fe,(%esp)
    20e1:	e8 9a 19 00 00       	call   3a80 <unlink>
    20e6:	85 c0                	test   %eax,%eax
    20e8:	0f 85 9c 00 00 00    	jne    218a <subdir+0x44e>
    printf(1, "unlink dd/dd/ff failed\n");
    exit();
  }
  if(unlink("dd/ff") != 0){
    20ee:	c7 04 24 9d 45 00 00 	movl   $0x459d,(%esp)
    20f5:	e8 86 19 00 00       	call   3a80 <unlink>
    20fa:	85 c0                	test   %eax,%eax
    20fc:	0f 85 e0 02 00 00    	jne    23e2 <subdir+0x6a6>
    printf(1, "unlink dd/ff failed\n");
    exit();
  }
  if(unlink("dd") == 0){
    2102:	c7 04 24 64 46 00 00 	movl   $0x4664,(%esp)
    2109:	e8 72 19 00 00       	call   3a80 <unlink>
    210e:	85 c0                	test   %eax,%eax
    2110:	0f 84 b3 02 00 00    	je     23c9 <subdir+0x68d>
    printf(1, "unlink non-empty dd succeeded!\n");
    exit();
  }
  if(unlink("dd/dd") < 0){
    2116:	c7 04 24 79 45 00 00 	movl   $0x4579,(%esp)
    211d:	e8 5e 19 00 00       	call   3a80 <unlink>
    2122:	85 c0                	test   %eax,%eax
    2124:	0f 88 86 02 00 00    	js     23b0 <subdir+0x674>
    printf(1, "unlink dd/dd failed\n");
    exit();
  }
  if(unlink("dd") < 0){
    212a:	c7 04 24 64 46 00 00 	movl   $0x4664,(%esp)
    2131:	e8 4a 19 00 00       	call   3a80 <unlink>
    2136:	85 c0                	test   %eax,%eax
    2138:	0f 88 59 02 00 00    	js     2397 <subdir+0x65b>
    printf(1, "unlink dd failed\n");
    exit();
  }

  printf(1, "subdir ok\n");
    213e:	c7 44 24 04 46 48 00 	movl   $0x4846,0x4(%esp)
    2145:	00 
    2146:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    214d:	e8 0e 1a 00 00       	call   3b60 <printf>
}
    2152:	83 c4 14             	add    $0x14,%esp
    2155:	5b                   	pop    %ebx
    2156:	5d                   	pop    %ebp
    2157:	c3                   	ret    
    printf(1, "open dd/dd/../ff failed\n");
    exit();
  }
  cc = read(fd, buf, sizeof(buf));
  if(cc != 2 || buf[0] != 'f'){
    printf(1, "dd/dd/../ff wrong content\n");
    2158:	c7 44 24 04 e3 45 00 	movl   $0x45e3,0x4(%esp)
    215f:	00 
    2160:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2167:	e8 f4 19 00 00       	call   3b60 <printf>
    exit();
    216c:	e8 bf 18 00 00       	call   3a30 <exit>
  if(chdir("dd/../../dd") != 0){
    printf(1, "chdir dd/../../dd failed\n");
    exit();
  }
  if(chdir("dd/../../../dd") != 0){
    printf(1, "chdir dd/../../dd failed\n");
    2171:	c7 44 24 04 3e 46 00 	movl   $0x463e,0x4(%esp)
    2178:	00 
    2179:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2180:	e8 db 19 00 00       	call   3b60 <printf>
    exit();
    2185:	e8 a6 18 00 00       	call   3a30 <exit>
    printf(1, "chdir dd/xx succeeded!\n");
    exit();
  }

  if(unlink("dd/dd/ffff") != 0){
    printf(1, "unlink dd/dd/ff failed\n");
    218a:	c7 44 24 04 09 46 00 	movl   $0x4609,0x4(%esp)
    2191:	00 
    2192:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2199:	e8 c2 19 00 00       	call   3b60 <printf>
    exit();
    219e:	e8 8d 18 00 00       	call   3a30 <exit>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    exit();
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    printf(1, "create dd/ff/ff succeeded!\n");
    21a3:	c7 44 24 04 bb 46 00 	movl   $0x46bb,0x4(%esp)
    21aa:	00 
    21ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21b2:	e8 a9 19 00 00       	call   3b60 <printf>
    exit();
    21b7:	e8 74 18 00 00       	call   3a30 <exit>
    exit();
  }
  close(fd);

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    21bc:	c7 44 24 04 a0 50 00 	movl   $0x50a0,0x4(%esp)
    21c3:	00 
    21c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21cb:	e8 90 19 00 00       	call   3b60 <printf>
    exit();
    21d0:	e8 5b 18 00 00       	call   3a30 <exit>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    exit();
  }
  if(mkdir("dd/ff/ff") == 0){
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    21d5:	c7 44 24 04 4f 47 00 	movl   $0x474f,0x4(%esp)
    21dc:	00 
    21dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21e4:	e8 77 19 00 00       	call   3b60 <printf>
    exit();
    21e9:	e8 42 18 00 00       	call   3a30 <exit>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    exit();
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    21ee:	c7 44 24 04 10 51 00 	movl   $0x5110,0x4(%esp)
    21f5:	00 
    21f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21fd:	e8 5e 19 00 00       	call   3b60 <printf>
    exit();
    2202:	e8 29 18 00 00       	call   3a30 <exit>
  write(fd, "FF", 2);
  close(fd);

  fd = open("dd/dd/../ff", 0);
  if(fd < 0){
    printf(1, "open dd/dd/../ff failed\n");
    2207:	c7 44 24 04 ca 45 00 	movl   $0x45ca,0x4(%esp)
    220e:	00 
    220f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2216:	e8 45 19 00 00       	call   3b60 <printf>
    exit();
    221b:	e8 10 18 00 00       	call   3a30 <exit>
    exit();
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "create dd/dd/ff failed\n");
    2220:	c7 44 24 04 a3 45 00 	movl   $0x45a3,0x4(%esp)
    2227:	00 
    2228:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    222f:	e8 2c 19 00 00       	call   3b60 <printf>
    exit();
    2234:	e8 f7 17 00 00       	call   3a30 <exit>
  if(chdir("dd/../../../dd") != 0){
    printf(1, "chdir dd/../../dd failed\n");
    exit();
  }
  if(chdir("./..") != 0){
    printf(1, "chdir ./.. failed\n");
    2239:	c7 44 24 04 6c 46 00 	movl   $0x466c,0x4(%esp)
    2240:	00 
    2241:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2248:	e8 13 19 00 00       	call   3b60 <printf>
    exit();
    224d:	e8 de 17 00 00       	call   3a30 <exit>
    exit();
  }
  close(fd);

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    2252:	c7 44 24 04 58 50 00 	movl   $0x5058,0x4(%esp)
    2259:	00 
    225a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2261:	e8 fa 18 00 00       	call   3b60 <printf>
    exit();
    2266:	e8 c5 17 00 00       	call   3a30 <exit>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    exit();
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    226b:	c7 44 24 04 ec 50 00 	movl   $0x50ec,0x4(%esp)
    2272:	00 
    2273:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    227a:	e8 e1 18 00 00       	call   3b60 <printf>
    exit();
    227f:	e8 ac 17 00 00       	call   3a30 <exit>
  if(open("dd", O_WRONLY) >= 0){
    printf(1, "open dd wronly succeeded!\n");
    exit();
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    2284:	c7 44 24 04 c8 50 00 	movl   $0x50c8,0x4(%esp)
    228b:	00 
    228c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2293:	e8 c8 18 00 00       	call   3b60 <printf>
    exit();
    2298:	e8 93 17 00 00       	call   3a30 <exit>
  if(open("dd", O_RDWR) >= 0){
    printf(1, "open dd rdwr succeeded!\n");
    exit();
  }
  if(open("dd", O_WRONLY) >= 0){
    printf(1, "open dd wronly succeeded!\n");
    229d:	c7 44 24 04 2b 47 00 	movl   $0x472b,0x4(%esp)
    22a4:	00 
    22a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22ac:	e8 af 18 00 00       	call   3b60 <printf>
    exit();
    22b1:	e8 7a 17 00 00       	call   3a30 <exit>
  if(open("dd", O_CREATE) >= 0){
    printf(1, "create dd succeeded!\n");
    exit();
  }
  if(open("dd", O_RDWR) >= 0){
    printf(1, "open dd rdwr succeeded!\n");
    22b6:	c7 44 24 04 12 47 00 	movl   $0x4712,0x4(%esp)
    22bd:	00 
    22be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22c5:	e8 96 18 00 00       	call   3b60 <printf>
    exit();
    22ca:	e8 61 17 00 00       	call   3a30 <exit>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    printf(1, "create dd/xx/ff succeeded!\n");
    exit();
  }
  if(open("dd", O_CREATE) >= 0){
    printf(1, "create dd succeeded!\n");
    22cf:	c7 44 24 04 fc 46 00 	movl   $0x46fc,0x4(%esp)
    22d6:	00 
    22d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22de:	e8 7d 18 00 00       	call   3b60 <printf>
    exit();
    22e3:	e8 48 17 00 00       	call   3a30 <exit>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    printf(1, "create dd/ff/ff succeeded!\n");
    exit();
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    printf(1, "create dd/xx/ff succeeded!\n");
    22e8:	c7 44 24 04 e0 46 00 	movl   $0x46e0,0x4(%esp)
    22ef:	00 
    22f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22f7:	e8 64 18 00 00       	call   3b60 <printf>
    exit();
    22fc:	e8 2f 17 00 00       	call   3a30 <exit>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    exit();
  }

  if(chdir("dd") != 0){
    printf(1, "chdir dd failed\n");
    2301:	c7 44 24 04 21 46 00 	movl   $0x4621,0x4(%esp)
    2308:	00 
    2309:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2310:	e8 4b 18 00 00       	call   3b60 <printf>
    exit();
    2315:	e8 16 17 00 00       	call   3a30 <exit>
  if(unlink("dd/dd/ff") != 0){
    printf(1, "unlink dd/dd/ff failed\n");
    exit();
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    231a:	c7 44 24 04 7c 50 00 	movl   $0x507c,0x4(%esp)
    2321:	00 
    2322:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2329:	e8 32 18 00 00       	call   3b60 <printf>
    exit();
    232e:	e8 fd 16 00 00       	call   3a30 <exit>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    exit();
  }

  if(mkdir("/dd/dd") != 0){
    printf(1, "subdir mkdir dd/dd failed\n");
    2333:	c7 44 24 04 7f 45 00 	movl   $0x457f,0x4(%esp)
    233a:	00 
    233b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2342:	e8 19 18 00 00       	call   3b60 <printf>
    exit();
    2347:	e8 e4 16 00 00       	call   3a30 <exit>
  }
  write(fd, "ff", 2);
  close(fd);

  if(unlink("dd") >= 0){
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    234c:	c7 44 24 04 30 50 00 	movl   $0x5030,0x4(%esp)
    2353:	00 
    2354:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    235b:	e8 00 18 00 00       	call   3b60 <printf>
    exit();
    2360:	e8 cb 16 00 00       	call   3a30 <exit>
    exit();
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "create dd/ff failed\n");
    2365:	c7 44 24 04 63 45 00 	movl   $0x4563,0x4(%esp)
    236c:	00 
    236d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2374:	e8 e7 17 00 00       	call   3b60 <printf>
    exit();
    2379:	e8 b2 16 00 00       	call   3a30 <exit>

  printf(1, "subdir test\n");

  unlink("ff");
  if(mkdir("dd") != 0){
    printf(1, "subdir mkdir dd failed\n");
    237e:	c7 44 24 04 4b 45 00 	movl   $0x454b,0x4(%esp)
    2385:	00 
    2386:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    238d:	e8 ce 17 00 00       	call   3b60 <printf>
    exit();
    2392:	e8 99 16 00 00       	call   3a30 <exit>
  if(unlink("dd/dd") < 0){
    printf(1, "unlink dd/dd failed\n");
    exit();
  }
  if(unlink("dd") < 0){
    printf(1, "unlink dd failed\n");
    2397:	c7 44 24 04 34 48 00 	movl   $0x4834,0x4(%esp)
    239e:	00 
    239f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23a6:	e8 b5 17 00 00       	call   3b60 <printf>
    exit();
    23ab:	e8 80 16 00 00       	call   3a30 <exit>
  if(unlink("dd") == 0){
    printf(1, "unlink non-empty dd succeeded!\n");
    exit();
  }
  if(unlink("dd/dd") < 0){
    printf(1, "unlink dd/dd failed\n");
    23b0:	c7 44 24 04 1f 48 00 	movl   $0x481f,0x4(%esp)
    23b7:	00 
    23b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23bf:	e8 9c 17 00 00       	call   3b60 <printf>
    exit();
    23c4:	e8 67 16 00 00       	call   3a30 <exit>
  if(unlink("dd/ff") != 0){
    printf(1, "unlink dd/ff failed\n");
    exit();
  }
  if(unlink("dd") == 0){
    printf(1, "unlink non-empty dd succeeded!\n");
    23c9:	c7 44 24 04 34 51 00 	movl   $0x5134,0x4(%esp)
    23d0:	00 
    23d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23d8:	e8 83 17 00 00       	call   3b60 <printf>
    exit();
    23dd:	e8 4e 16 00 00       	call   3a30 <exit>
  if(unlink("dd/dd/ffff") != 0){
    printf(1, "unlink dd/dd/ff failed\n");
    exit();
  }
  if(unlink("dd/ff") != 0){
    printf(1, "unlink dd/ff failed\n");
    23e2:	c7 44 24 04 0a 48 00 	movl   $0x480a,0x4(%esp)
    23e9:	00 
    23ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23f1:	e8 6a 17 00 00       	call   3b60 <printf>
    exit();
    23f6:	e8 35 16 00 00       	call   3a30 <exit>
  if(chdir("dd/ff") == 0){
    printf(1, "chdir dd/ff succeeded!\n");
    exit();
  }
  if(chdir("dd/xx") == 0){
    printf(1, "chdir dd/xx succeeded!\n");
    23fb:	c7 44 24 04 f2 47 00 	movl   $0x47f2,0x4(%esp)
    2402:	00 
    2403:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    240a:	e8 51 17 00 00       	call   3b60 <printf>
    exit();
    240f:	e8 1c 16 00 00       	call   3a30 <exit>
  if(unlink("dd/ff/ff") == 0){
    printf(1, "unlink dd/ff/ff succeeded!\n");
    exit();
  }
  if(chdir("dd/ff") == 0){
    printf(1, "chdir dd/ff succeeded!\n");
    2414:	c7 44 24 04 da 47 00 	movl   $0x47da,0x4(%esp)
    241b:	00 
    241c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2423:	e8 38 17 00 00       	call   3b60 <printf>
    exit();
    2428:	e8 03 16 00 00       	call   3a30 <exit>
  if(unlink("dd/xx/ff") == 0){
    printf(1, "unlink dd/xx/ff succeeded!\n");
    exit();
  }
  if(unlink("dd/ff/ff") == 0){
    printf(1, "unlink dd/ff/ff succeeded!\n");
    242d:	c7 44 24 04 be 47 00 	movl   $0x47be,0x4(%esp)
    2434:	00 
    2435:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    243c:	e8 1f 17 00 00       	call   3b60 <printf>
    exit();
    2441:	e8 ea 15 00 00       	call   3a30 <exit>
  if(mkdir("dd/dd/ffff") == 0){
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    exit();
  }
  if(unlink("dd/xx/ff") == 0){
    printf(1, "unlink dd/xx/ff succeeded!\n");
    2446:	c7 44 24 04 a2 47 00 	movl   $0x47a2,0x4(%esp)
    244d:	00 
    244e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2455:	e8 06 17 00 00       	call   3b60 <printf>
    exit();
    245a:	e8 d1 15 00 00       	call   3a30 <exit>
  if(mkdir("dd/xx/ff") == 0){
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    exit();
  }
  if(mkdir("dd/dd/ffff") == 0){
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    245f:	c7 44 24 04 85 47 00 	movl   $0x4785,0x4(%esp)
    2466:	00 
    2467:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    246e:	e8 ed 16 00 00       	call   3b60 <printf>
    exit();
    2473:	e8 b8 15 00 00       	call   3a30 <exit>
  if(mkdir("dd/ff/ff") == 0){
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    exit();
  }
  if(mkdir("dd/xx/ff") == 0){
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    2478:	c7 44 24 04 6a 47 00 	movl   $0x476a,0x4(%esp)
    247f:	00 
    2480:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2487:	e8 d4 16 00 00       	call   3b60 <printf>
    exit();
    248c:	e8 9f 15 00 00       	call   3a30 <exit>
  if(fd < 0){
    printf(1, "open dd/dd/ffff failed\n");
    exit();
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    printf(1, "read dd/dd/ffff wrong len\n");
    2491:	c7 44 24 04 97 46 00 	movl   $0x4697,0x4(%esp)
    2498:	00 
    2499:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24a0:	e8 bb 16 00 00       	call   3b60 <printf>
    exit();
    24a5:	e8 86 15 00 00       	call   3a30 <exit>
    exit();
  }

  fd = open("dd/dd/ffff", 0);
  if(fd < 0){
    printf(1, "open dd/dd/ffff failed\n");
    24aa:	c7 44 24 04 7f 46 00 	movl   $0x467f,0x4(%esp)
    24b1:	00 
    24b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24b9:	e8 a2 16 00 00       	call   3b60 <printf>
    exit();
    24be:	e8 6d 15 00 00       	call   3a30 <exit>
    24c3:	90                   	nop

000024c4 <bigwrite>:
}

// test writes that are larger than the log.
void
bigwrite(void)
{
    24c4:	55                   	push   %ebp
    24c5:	89 e5                	mov    %esp,%ebp
    24c7:	56                   	push   %esi
    24c8:	53                   	push   %ebx
    24c9:	83 ec 10             	sub    $0x10,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");
    24cc:	c7 44 24 04 51 48 00 	movl   $0x4851,0x4(%esp)
    24d3:	00 
    24d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24db:	e8 80 16 00 00       	call   3b60 <printf>

  unlink("bigwrite");
    24e0:	c7 04 24 60 48 00 00 	movl   $0x4860,(%esp)
    24e7:	e8 94 15 00 00       	call   3a80 <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    24ec:	bb f3 01 00 00       	mov    $0x1f3,%ebx
    24f1:	8d 76 00             	lea    0x0(%esi),%esi
    fd = open("bigwrite", O_CREATE | O_RDWR);
    24f4:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    24fb:	00 
    24fc:	c7 04 24 60 48 00 00 	movl   $0x4860,(%esp)
    2503:	e8 68 15 00 00       	call   3a70 <open>
    2508:	89 c6                	mov    %eax,%esi
    if(fd < 0){
    250a:	85 c0                	test   %eax,%eax
    250c:	0f 88 8e 00 00 00    	js     25a0 <bigwrite+0xdc>
      printf(1, "cannot create bigwrite\n");
      exit();
    }
    int i;
    for(i = 0; i < 2; i++){
      int cc = write(fd, buf, sz);
    2512:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    2516:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
    251d:	00 
    251e:	89 04 24             	mov    %eax,(%esp)
    2521:	e8 2a 15 00 00       	call   3a50 <write>
      if(cc != sz){
    2526:	39 d8                	cmp    %ebx,%eax
    2528:	75 55                	jne    257f <bigwrite+0xbb>
      printf(1, "cannot create bigwrite\n");
      exit();
    }
    int i;
    for(i = 0; i < 2; i++){
      int cc = write(fd, buf, sz);
    252a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    252e:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
    2535:	00 
    2536:	89 34 24             	mov    %esi,(%esp)
    2539:	e8 12 15 00 00       	call   3a50 <write>
      if(cc != sz){
    253e:	39 c3                	cmp    %eax,%ebx
    2540:	75 3d                	jne    257f <bigwrite+0xbb>
        printf(1, "write(%d) ret %d\n", sz, cc);
        exit();
      }
    }
    close(fd);
    2542:	89 34 24             	mov    %esi,(%esp)
    2545:	e8 0e 15 00 00       	call   3a58 <close>
    unlink("bigwrite");
    254a:	c7 04 24 60 48 00 00 	movl   $0x4860,(%esp)
    2551:	e8 2a 15 00 00       	call   3a80 <unlink>
  int fd, sz;

  printf(1, "bigwrite test\n");

  unlink("bigwrite");
  for(sz = 499; sz < 12*512; sz += 471){
    2556:	81 c3 d7 01 00 00    	add    $0x1d7,%ebx
    255c:	81 fb 07 18 00 00    	cmp    $0x1807,%ebx
    2562:	75 90                	jne    24f4 <bigwrite+0x30>
    }
    close(fd);
    unlink("bigwrite");
  }

  printf(1, "bigwrite ok\n");
    2564:	c7 44 24 04 93 48 00 	movl   $0x4893,0x4(%esp)
    256b:	00 
    256c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2573:	e8 e8 15 00 00       	call   3b60 <printf>
}
    2578:	83 c4 10             	add    $0x10,%esp
    257b:	5b                   	pop    %ebx
    257c:	5e                   	pop    %esi
    257d:	5d                   	pop    %ebp
    257e:	c3                   	ret    
    }
    int i;
    for(i = 0; i < 2; i++){
      int cc = write(fd, buf, sz);
      if(cc != sz){
        printf(1, "write(%d) ret %d\n", sz, cc);
    257f:	89 44 24 0c          	mov    %eax,0xc(%esp)
    2583:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    2587:	c7 44 24 04 81 48 00 	movl   $0x4881,0x4(%esp)
    258e:	00 
    258f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2596:	e8 c5 15 00 00       	call   3b60 <printf>
        exit();
    259b:	e8 90 14 00 00       	call   3a30 <exit>

  unlink("bigwrite");
  for(sz = 499; sz < 12*512; sz += 471){
    fd = open("bigwrite", O_CREATE | O_RDWR);
    if(fd < 0){
      printf(1, "cannot create bigwrite\n");
    25a0:	c7 44 24 04 69 48 00 	movl   $0x4869,0x4(%esp)
    25a7:	00 
    25a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25af:	e8 ac 15 00 00       	call   3b60 <printf>
      exit();
    25b4:	e8 77 14 00 00       	call   3a30 <exit>
    25b9:	8d 76 00             	lea    0x0(%esi),%esi

000025bc <bigfile>:
  printf(1, "bigwrite ok\n");
}

void
bigfile(void)
{
    25bc:	55                   	push   %ebp
    25bd:	89 e5                	mov    %esp,%ebp
    25bf:	57                   	push   %edi
    25c0:	56                   	push   %esi
    25c1:	53                   	push   %ebx
    25c2:	83 ec 1c             	sub    $0x1c,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    25c5:	c7 44 24 04 a0 48 00 	movl   $0x48a0,0x4(%esp)
    25cc:	00 
    25cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25d4:	e8 87 15 00 00       	call   3b60 <printf>

  unlink("bigfile");
    25d9:	c7 04 24 bc 48 00 00 	movl   $0x48bc,(%esp)
    25e0:	e8 9b 14 00 00       	call   3a80 <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    25e5:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    25ec:	00 
    25ed:	c7 04 24 bc 48 00 00 	movl   $0x48bc,(%esp)
    25f4:	e8 77 14 00 00       	call   3a70 <open>
    25f9:	89 c6                	mov    %eax,%esi
  if(fd < 0){
    25fb:	85 c0                	test   %eax,%eax
    25fd:	0f 88 79 01 00 00    	js     277c <bigfile+0x1c0>
    2603:	31 db                	xor    %ebx,%ebx
    2605:	8d 76 00             	lea    0x0(%esi),%esi
    printf(1, "cannot create bigfile");
    exit();
  }
  for(i = 0; i < 20; i++){
    memset(buf, i, 600);
    2608:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    260f:	00 
    2610:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    2614:	c7 04 24 80 86 00 00 	movl   $0x8680,(%esp)
    261b:	e8 d0 12 00 00       	call   38f0 <memset>
    if(write(fd, buf, 600) != 600){
    2620:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    2627:	00 
    2628:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
    262f:	00 
    2630:	89 34 24             	mov    %esi,(%esp)
    2633:	e8 18 14 00 00       	call   3a50 <write>
    2638:	3d 58 02 00 00       	cmp    $0x258,%eax
    263d:	0f 85 07 01 00 00    	jne    274a <bigfile+0x18e>
  fd = open("bigfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "cannot create bigfile");
    exit();
  }
  for(i = 0; i < 20; i++){
    2643:	43                   	inc    %ebx
    2644:	83 fb 14             	cmp    $0x14,%ebx
    2647:	75 bf                	jne    2608 <bigfile+0x4c>
    if(write(fd, buf, 600) != 600){
      printf(1, "write bigfile failed\n");
      exit();
    }
  }
  close(fd);
    2649:	89 34 24             	mov    %esi,(%esp)
    264c:	e8 07 14 00 00       	call   3a58 <close>

  fd = open("bigfile", 0);
    2651:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2658:	00 
    2659:	c7 04 24 bc 48 00 00 	movl   $0x48bc,(%esp)
    2660:	e8 0b 14 00 00       	call   3a70 <open>
    2665:	89 c7                	mov    %eax,%edi
  if(fd < 0){
    2667:	85 c0                	test   %eax,%eax
    2669:	0f 88 f4 00 00 00    	js     2763 <bigfile+0x1a7>
    266f:	31 f6                	xor    %esi,%esi
    2671:	31 db                	xor    %ebx,%ebx
    2673:	eb 2f                	jmp    26a4 <bigfile+0xe8>
    2675:	8d 76 00             	lea    0x0(%esi),%esi
      printf(1, "read bigfile failed\n");
      exit();
    }
    if(cc == 0)
      break;
    if(cc != 300){
    2678:	3d 2c 01 00 00       	cmp    $0x12c,%eax
    267d:	0f 85 95 00 00 00    	jne    2718 <bigfile+0x15c>
      printf(1, "short read bigfile\n");
      exit();
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    2683:	0f be 05 80 86 00 00 	movsbl 0x8680,%eax
    268a:	89 da                	mov    %ebx,%edx
    268c:	d1 fa                	sar    %edx
    268e:	39 d0                	cmp    %edx,%eax
    2690:	75 6d                	jne    26ff <bigfile+0x143>
    2692:	0f be 15 ab 87 00 00 	movsbl 0x87ab,%edx
    2699:	39 d0                	cmp    %edx,%eax
    269b:	75 62                	jne    26ff <bigfile+0x143>
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
    269d:	81 c6 2c 01 00 00    	add    $0x12c,%esi
  if(fd < 0){
    printf(1, "cannot open bigfile\n");
    exit();
  }
  total = 0;
  for(i = 0; ; i++){
    26a3:	43                   	inc    %ebx
    cc = read(fd, buf, 300);
    26a4:	c7 44 24 08 2c 01 00 	movl   $0x12c,0x8(%esp)
    26ab:	00 
    26ac:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
    26b3:	00 
    26b4:	89 3c 24             	mov    %edi,(%esp)
    26b7:	e8 8c 13 00 00       	call   3a48 <read>
    if(cc < 0){
    26bc:	83 f8 00             	cmp    $0x0,%eax
    26bf:	7c 70                	jl     2731 <bigfile+0x175>
      printf(1, "read bigfile failed\n");
      exit();
    }
    if(cc == 0)
    26c1:	75 b5                	jne    2678 <bigfile+0xbc>
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
  close(fd);
    26c3:	89 3c 24             	mov    %edi,(%esp)
    26c6:	e8 8d 13 00 00       	call   3a58 <close>
  if(total != 20*600){
    26cb:	81 fe e0 2e 00 00    	cmp    $0x2ee0,%esi
    26d1:	0f 85 be 00 00 00    	jne    2795 <bigfile+0x1d9>
    printf(1, "read bigfile wrong total\n");
    exit();
  }
  unlink("bigfile");
    26d7:	c7 04 24 bc 48 00 00 	movl   $0x48bc,(%esp)
    26de:	e8 9d 13 00 00       	call   3a80 <unlink>

  printf(1, "bigfile test ok\n");
    26e3:	c7 44 24 04 4b 49 00 	movl   $0x494b,0x4(%esp)
    26ea:	00 
    26eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26f2:	e8 69 14 00 00       	call   3b60 <printf>
}
    26f7:	83 c4 1c             	add    $0x1c,%esp
    26fa:	5b                   	pop    %ebx
    26fb:	5e                   	pop    %esi
    26fc:	5f                   	pop    %edi
    26fd:	5d                   	pop    %ebp
    26fe:	c3                   	ret    
    if(cc != 300){
      printf(1, "short read bigfile\n");
      exit();
    }
    if(buf[0] != i/2 || buf[299] != i/2){
      printf(1, "read bigfile wrong data\n");
    26ff:	c7 44 24 04 18 49 00 	movl   $0x4918,0x4(%esp)
    2706:	00 
    2707:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    270e:	e8 4d 14 00 00       	call   3b60 <printf>
      exit();
    2713:	e8 18 13 00 00       	call   3a30 <exit>
      exit();
    }
    if(cc == 0)
      break;
    if(cc != 300){
      printf(1, "short read bigfile\n");
    2718:	c7 44 24 04 04 49 00 	movl   $0x4904,0x4(%esp)
    271f:	00 
    2720:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2727:	e8 34 14 00 00       	call   3b60 <printf>
      exit();
    272c:	e8 ff 12 00 00       	call   3a30 <exit>
  }
  total = 0;
  for(i = 0; ; i++){
    cc = read(fd, buf, 300);
    if(cc < 0){
      printf(1, "read bigfile failed\n");
    2731:	c7 44 24 04 ef 48 00 	movl   $0x48ef,0x4(%esp)
    2738:	00 
    2739:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2740:	e8 1b 14 00 00       	call   3b60 <printf>
      exit();
    2745:	e8 e6 12 00 00       	call   3a30 <exit>
    exit();
  }
  for(i = 0; i < 20; i++){
    memset(buf, i, 600);
    if(write(fd, buf, 600) != 600){
      printf(1, "write bigfile failed\n");
    274a:	c7 44 24 04 c4 48 00 	movl   $0x48c4,0x4(%esp)
    2751:	00 
    2752:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2759:	e8 02 14 00 00       	call   3b60 <printf>
      exit();
    275e:	e8 cd 12 00 00       	call   3a30 <exit>
  }
  close(fd);

  fd = open("bigfile", 0);
  if(fd < 0){
    printf(1, "cannot open bigfile\n");
    2763:	c7 44 24 04 da 48 00 	movl   $0x48da,0x4(%esp)
    276a:	00 
    276b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2772:	e8 e9 13 00 00       	call   3b60 <printf>
    exit();
    2777:	e8 b4 12 00 00       	call   3a30 <exit>
  printf(1, "bigfile test\n");

  unlink("bigfile");
  fd = open("bigfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "cannot create bigfile");
    277c:	c7 44 24 04 ae 48 00 	movl   $0x48ae,0x4(%esp)
    2783:	00 
    2784:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    278b:	e8 d0 13 00 00       	call   3b60 <printf>
    exit();
    2790:	e8 9b 12 00 00       	call   3a30 <exit>
    }
    total += cc;
  }
  close(fd);
  if(total != 20*600){
    printf(1, "read bigfile wrong total\n");
    2795:	c7 44 24 04 31 49 00 	movl   $0x4931,0x4(%esp)
    279c:	00 
    279d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27a4:	e8 b7 13 00 00       	call   3b60 <printf>
    exit();
    27a9:	e8 82 12 00 00       	call   3a30 <exit>
    27ae:	66 90                	xchg   %ax,%ax

000027b0 <fourteen>:
  printf(1, "bigfile test ok\n");
}

void
fourteen(void)
{
    27b0:	55                   	push   %ebp
    27b1:	89 e5                	mov    %esp,%ebp
    27b3:	83 ec 18             	sub    $0x18,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    27b6:	c7 44 24 04 5c 49 00 	movl   $0x495c,0x4(%esp)
    27bd:	00 
    27be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27c5:	e8 96 13 00 00       	call   3b60 <printf>

  if(mkdir("12345678901234") != 0){
    27ca:	c7 04 24 97 49 00 00 	movl   $0x4997,(%esp)
    27d1:	e8 c2 12 00 00       	call   3a98 <mkdir>
    27d6:	85 c0                	test   %eax,%eax
    27d8:	0f 85 92 00 00 00    	jne    2870 <fourteen+0xc0>
    printf(1, "mkdir 12345678901234 failed\n");
    exit();
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    27de:	c7 04 24 54 51 00 00 	movl   $0x5154,(%esp)
    27e5:	e8 ae 12 00 00       	call   3a98 <mkdir>
    27ea:	85 c0                	test   %eax,%eax
    27ec:	0f 85 fb 00 00 00    	jne    28ed <fourteen+0x13d>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    exit();
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    27f2:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    27f9:	00 
    27fa:	c7 04 24 a4 51 00 00 	movl   $0x51a4,(%esp)
    2801:	e8 6a 12 00 00       	call   3a70 <open>
  if(fd < 0){
    2806:	85 c0                	test   %eax,%eax
    2808:	0f 88 c6 00 00 00    	js     28d4 <fourteen+0x124>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    exit();
  }
  close(fd);
    280e:	89 04 24             	mov    %eax,(%esp)
    2811:	e8 42 12 00 00       	call   3a58 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2816:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    281d:	00 
    281e:	c7 04 24 14 52 00 00 	movl   $0x5214,(%esp)
    2825:	e8 46 12 00 00       	call   3a70 <open>
  if(fd < 0){
    282a:	85 c0                	test   %eax,%eax
    282c:	0f 88 89 00 00 00    	js     28bb <fourteen+0x10b>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    exit();
  }
  close(fd);
    2832:	89 04 24             	mov    %eax,(%esp)
    2835:	e8 1e 12 00 00       	call   3a58 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    283a:	c7 04 24 88 49 00 00 	movl   $0x4988,(%esp)
    2841:	e8 52 12 00 00       	call   3a98 <mkdir>
    2846:	85 c0                	test   %eax,%eax
    2848:	74 58                	je     28a2 <fourteen+0xf2>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    exit();
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    284a:	c7 04 24 b0 52 00 00 	movl   $0x52b0,(%esp)
    2851:	e8 42 12 00 00       	call   3a98 <mkdir>
    2856:	85 c0                	test   %eax,%eax
    2858:	74 2f                	je     2889 <fourteen+0xd9>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    exit();
  }

  printf(1, "fourteen ok\n");
    285a:	c7 44 24 04 a6 49 00 	movl   $0x49a6,0x4(%esp)
    2861:	00 
    2862:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2869:	e8 f2 12 00 00       	call   3b60 <printf>
}
    286e:	c9                   	leave  
    286f:	c3                   	ret    

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");

  if(mkdir("12345678901234") != 0){
    printf(1, "mkdir 12345678901234 failed\n");
    2870:	c7 44 24 04 6b 49 00 	movl   $0x496b,0x4(%esp)
    2877:	00 
    2878:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    287f:	e8 dc 12 00 00       	call   3b60 <printf>
    exit();
    2884:	e8 a7 11 00 00       	call   3a30 <exit>
  if(mkdir("12345678901234/12345678901234") == 0){
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    exit();
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    2889:	c7 44 24 04 d0 52 00 	movl   $0x52d0,0x4(%esp)
    2890:	00 
    2891:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2898:	e8 c3 12 00 00       	call   3b60 <printf>
    exit();
    289d:	e8 8e 11 00 00       	call   3a30 <exit>
    exit();
  }
  close(fd);

  if(mkdir("12345678901234/12345678901234") == 0){
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    28a2:	c7 44 24 04 80 52 00 	movl   $0x5280,0x4(%esp)
    28a9:	00 
    28aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28b1:	e8 aa 12 00 00       	call   3b60 <printf>
    exit();
    28b6:	e8 75 11 00 00       	call   3a30 <exit>
    exit();
  }
  close(fd);
  fd = open("12345678901234/12345678901234/12345678901234", 0);
  if(fd < 0){
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    28bb:	c7 44 24 04 44 52 00 	movl   $0x5244,0x4(%esp)
    28c2:	00 
    28c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28ca:	e8 91 12 00 00       	call   3b60 <printf>
    exit();
    28cf:	e8 5c 11 00 00       	call   3a30 <exit>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    exit();
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
  if(fd < 0){
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    28d4:	c7 44 24 04 d4 51 00 	movl   $0x51d4,0x4(%esp)
    28db:	00 
    28dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28e3:	e8 78 12 00 00       	call   3b60 <printf>
    exit();
    28e8:	e8 43 11 00 00       	call   3a30 <exit>
  if(mkdir("12345678901234") != 0){
    printf(1, "mkdir 12345678901234 failed\n");
    exit();
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    28ed:	c7 44 24 04 74 51 00 	movl   $0x5174,0x4(%esp)
    28f4:	00 
    28f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28fc:	e8 5f 12 00 00       	call   3b60 <printf>
    exit();
    2901:	e8 2a 11 00 00       	call   3a30 <exit>
    2906:	66 90                	xchg   %ax,%ax

00002908 <rmdot>:
  printf(1, "fourteen ok\n");
}

void
rmdot(void)
{
    2908:	55                   	push   %ebp
    2909:	89 e5                	mov    %esp,%ebp
    290b:	83 ec 18             	sub    $0x18,%esp
  printf(1, "rmdot test\n");
    290e:	c7 44 24 04 b3 49 00 	movl   $0x49b3,0x4(%esp)
    2915:	00 
    2916:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    291d:	e8 3e 12 00 00       	call   3b60 <printf>
  if(mkdir("dots") != 0){
    2922:	c7 04 24 bf 49 00 00 	movl   $0x49bf,(%esp)
    2929:	e8 6a 11 00 00       	call   3a98 <mkdir>
    292e:	85 c0                	test   %eax,%eax
    2930:	0f 85 9a 00 00 00    	jne    29d0 <rmdot+0xc8>
    printf(1, "mkdir dots failed\n");
    exit();
  }
  if(chdir("dots") != 0){
    2936:	c7 04 24 bf 49 00 00 	movl   $0x49bf,(%esp)
    293d:	e8 5e 11 00 00       	call   3aa0 <chdir>
    2942:	85 c0                	test   %eax,%eax
    2944:	0f 85 35 01 00 00    	jne    2a7f <rmdot+0x177>
    printf(1, "chdir dots failed\n");
    exit();
  }
  if(unlink(".") == 0){
    294a:	c7 04 24 6a 46 00 00 	movl   $0x466a,(%esp)
    2951:	e8 2a 11 00 00       	call   3a80 <unlink>
    2956:	85 c0                	test   %eax,%eax
    2958:	0f 84 08 01 00 00    	je     2a66 <rmdot+0x15e>
    printf(1, "rm . worked!\n");
    exit();
  }
  if(unlink("..") == 0){
    295e:	c7 04 24 69 46 00 00 	movl   $0x4669,(%esp)
    2965:	e8 16 11 00 00       	call   3a80 <unlink>
    296a:	85 c0                	test   %eax,%eax
    296c:	0f 84 db 00 00 00    	je     2a4d <rmdot+0x145>
    printf(1, "rm .. worked!\n");
    exit();
  }
  if(chdir("/") != 0){
    2972:	c7 04 24 3d 3e 00 00 	movl   $0x3e3d,(%esp)
    2979:	e8 22 11 00 00       	call   3aa0 <chdir>
    297e:	85 c0                	test   %eax,%eax
    2980:	0f 85 ae 00 00 00    	jne    2a34 <rmdot+0x12c>
    printf(1, "chdir / failed\n");
    exit();
  }
  if(unlink("dots/.") == 0){
    2986:	c7 04 24 07 4a 00 00 	movl   $0x4a07,(%esp)
    298d:	e8 ee 10 00 00       	call   3a80 <unlink>
    2992:	85 c0                	test   %eax,%eax
    2994:	0f 84 81 00 00 00    	je     2a1b <rmdot+0x113>
    printf(1, "unlink dots/. worked!\n");
    exit();
  }
  if(unlink("dots/..") == 0){
    299a:	c7 04 24 25 4a 00 00 	movl   $0x4a25,(%esp)
    29a1:	e8 da 10 00 00       	call   3a80 <unlink>
    29a6:	85 c0                	test   %eax,%eax
    29a8:	74 58                	je     2a02 <rmdot+0xfa>
    printf(1, "unlink dots/.. worked!\n");
    exit();
  }
  if(unlink("dots") != 0){
    29aa:	c7 04 24 bf 49 00 00 	movl   $0x49bf,(%esp)
    29b1:	e8 ca 10 00 00       	call   3a80 <unlink>
    29b6:	85 c0                	test   %eax,%eax
    29b8:	75 2f                	jne    29e9 <rmdot+0xe1>
    printf(1, "unlink dots failed!\n");
    exit();
  }
  printf(1, "rmdot ok\n");
    29ba:	c7 44 24 04 5a 4a 00 	movl   $0x4a5a,0x4(%esp)
    29c1:	00 
    29c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29c9:	e8 92 11 00 00       	call   3b60 <printf>
}
    29ce:	c9                   	leave  
    29cf:	c3                   	ret    
void
rmdot(void)
{
  printf(1, "rmdot test\n");
  if(mkdir("dots") != 0){
    printf(1, "mkdir dots failed\n");
    29d0:	c7 44 24 04 c4 49 00 	movl   $0x49c4,0x4(%esp)
    29d7:	00 
    29d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29df:	e8 7c 11 00 00       	call   3b60 <printf>
    exit();
    29e4:	e8 47 10 00 00       	call   3a30 <exit>
  if(unlink("dots/..") == 0){
    printf(1, "unlink dots/.. worked!\n");
    exit();
  }
  if(unlink("dots") != 0){
    printf(1, "unlink dots failed!\n");
    29e9:	c7 44 24 04 45 4a 00 	movl   $0x4a45,0x4(%esp)
    29f0:	00 
    29f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29f8:	e8 63 11 00 00       	call   3b60 <printf>
    exit();
    29fd:	e8 2e 10 00 00       	call   3a30 <exit>
  if(unlink("dots/.") == 0){
    printf(1, "unlink dots/. worked!\n");
    exit();
  }
  if(unlink("dots/..") == 0){
    printf(1, "unlink dots/.. worked!\n");
    2a02:	c7 44 24 04 2d 4a 00 	movl   $0x4a2d,0x4(%esp)
    2a09:	00 
    2a0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a11:	e8 4a 11 00 00       	call   3b60 <printf>
    exit();
    2a16:	e8 15 10 00 00       	call   3a30 <exit>
  if(chdir("/") != 0){
    printf(1, "chdir / failed\n");
    exit();
  }
  if(unlink("dots/.") == 0){
    printf(1, "unlink dots/. worked!\n");
    2a1b:	c7 44 24 04 0e 4a 00 	movl   $0x4a0e,0x4(%esp)
    2a22:	00 
    2a23:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a2a:	e8 31 11 00 00       	call   3b60 <printf>
    exit();
    2a2f:	e8 fc 0f 00 00       	call   3a30 <exit>
  if(unlink("..") == 0){
    printf(1, "rm .. worked!\n");
    exit();
  }
  if(chdir("/") != 0){
    printf(1, "chdir / failed\n");
    2a34:	c7 44 24 04 3f 3e 00 	movl   $0x3e3f,0x4(%esp)
    2a3b:	00 
    2a3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a43:	e8 18 11 00 00       	call   3b60 <printf>
    exit();
    2a48:	e8 e3 0f 00 00       	call   3a30 <exit>
  if(unlink(".") == 0){
    printf(1, "rm . worked!\n");
    exit();
  }
  if(unlink("..") == 0){
    printf(1, "rm .. worked!\n");
    2a4d:	c7 44 24 04 f8 49 00 	movl   $0x49f8,0x4(%esp)
    2a54:	00 
    2a55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a5c:	e8 ff 10 00 00       	call   3b60 <printf>
    exit();
    2a61:	e8 ca 0f 00 00       	call   3a30 <exit>
  if(chdir("dots") != 0){
    printf(1, "chdir dots failed\n");
    exit();
  }
  if(unlink(".") == 0){
    printf(1, "rm . worked!\n");
    2a66:	c7 44 24 04 ea 49 00 	movl   $0x49ea,0x4(%esp)
    2a6d:	00 
    2a6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a75:	e8 e6 10 00 00       	call   3b60 <printf>
    exit();
    2a7a:	e8 b1 0f 00 00       	call   3a30 <exit>
  if(mkdir("dots") != 0){
    printf(1, "mkdir dots failed\n");
    exit();
  }
  if(chdir("dots") != 0){
    printf(1, "chdir dots failed\n");
    2a7f:	c7 44 24 04 d7 49 00 	movl   $0x49d7,0x4(%esp)
    2a86:	00 
    2a87:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a8e:	e8 cd 10 00 00       	call   3b60 <printf>
    exit();
    2a93:	e8 98 0f 00 00       	call   3a30 <exit>

00002a98 <dirfile>:
  printf(1, "rmdot ok\n");
}

void
dirfile(void)
{
    2a98:	55                   	push   %ebp
    2a99:	89 e5                	mov    %esp,%ebp
    2a9b:	53                   	push   %ebx
    2a9c:	83 ec 14             	sub    $0x14,%esp
  int fd;

  printf(1, "dir vs file\n");
    2a9f:	c7 44 24 04 64 4a 00 	movl   $0x4a64,0x4(%esp)
    2aa6:	00 
    2aa7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2aae:	e8 ad 10 00 00       	call   3b60 <printf>

  fd = open("dirfile", O_CREATE);
    2ab3:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2aba:	00 
    2abb:	c7 04 24 71 4a 00 00 	movl   $0x4a71,(%esp)
    2ac2:	e8 a9 0f 00 00       	call   3a70 <open>
  if(fd < 0){
    2ac7:	85 c0                	test   %eax,%eax
    2ac9:	0f 88 4e 01 00 00    	js     2c1d <dirfile+0x185>
    printf(1, "create dirfile failed\n");
    exit();
  }
  close(fd);
    2acf:	89 04 24             	mov    %eax,(%esp)
    2ad2:	e8 81 0f 00 00       	call   3a58 <close>
  if(chdir("dirfile") == 0){
    2ad7:	c7 04 24 71 4a 00 00 	movl   $0x4a71,(%esp)
    2ade:	e8 bd 0f 00 00       	call   3aa0 <chdir>
    2ae3:	85 c0                	test   %eax,%eax
    2ae5:	0f 84 19 01 00 00    	je     2c04 <dirfile+0x16c>
    printf(1, "chdir dirfile succeeded!\n");
    exit();
  }
  fd = open("dirfile/xx", 0);
    2aeb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2af2:	00 
    2af3:	c7 04 24 aa 4a 00 00 	movl   $0x4aaa,(%esp)
    2afa:	e8 71 0f 00 00       	call   3a70 <open>
  if(fd >= 0){
    2aff:	85 c0                	test   %eax,%eax
    2b01:	0f 89 e4 00 00 00    	jns    2beb <dirfile+0x153>
    printf(1, "create dirfile/xx succeeded!\n");
    exit();
  }
  fd = open("dirfile/xx", O_CREATE);
    2b07:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2b0e:	00 
    2b0f:	c7 04 24 aa 4a 00 00 	movl   $0x4aaa,(%esp)
    2b16:	e8 55 0f 00 00       	call   3a70 <open>
  if(fd >= 0){
    2b1b:	85 c0                	test   %eax,%eax
    2b1d:	0f 89 c8 00 00 00    	jns    2beb <dirfile+0x153>
    printf(1, "create dirfile/xx succeeded!\n");
    exit();
  }
  if(mkdir("dirfile/xx") == 0){
    2b23:	c7 04 24 aa 4a 00 00 	movl   $0x4aaa,(%esp)
    2b2a:	e8 69 0f 00 00       	call   3a98 <mkdir>
    2b2f:	85 c0                	test   %eax,%eax
    2b31:	0f 84 7c 01 00 00    	je     2cb3 <dirfile+0x21b>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    exit();
  }
  if(unlink("dirfile/xx") == 0){
    2b37:	c7 04 24 aa 4a 00 00 	movl   $0x4aaa,(%esp)
    2b3e:	e8 3d 0f 00 00       	call   3a80 <unlink>
    2b43:	85 c0                	test   %eax,%eax
    2b45:	0f 84 4f 01 00 00    	je     2c9a <dirfile+0x202>
    printf(1, "unlink dirfile/xx succeeded!\n");
    exit();
  }
  if(link("README", "dirfile/xx") == 0){
    2b4b:	c7 44 24 04 aa 4a 00 	movl   $0x4aaa,0x4(%esp)
    2b52:	00 
    2b53:	c7 04 24 0e 4b 00 00 	movl   $0x4b0e,(%esp)
    2b5a:	e8 31 0f 00 00       	call   3a90 <link>
    2b5f:	85 c0                	test   %eax,%eax
    2b61:	0f 84 1a 01 00 00    	je     2c81 <dirfile+0x1e9>
    printf(1, "link to dirfile/xx succeeded!\n");
    exit();
  }
  if(unlink("dirfile") != 0){
    2b67:	c7 04 24 71 4a 00 00 	movl   $0x4a71,(%esp)
    2b6e:	e8 0d 0f 00 00       	call   3a80 <unlink>
    2b73:	85 c0                	test   %eax,%eax
    2b75:	0f 85 ed 00 00 00    	jne    2c68 <dirfile+0x1d0>
    printf(1, "unlink dirfile failed!\n");
    exit();
  }

  fd = open(".", O_RDWR);
    2b7b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    2b82:	00 
    2b83:	c7 04 24 6a 46 00 00 	movl   $0x466a,(%esp)
    2b8a:	e8 e1 0e 00 00       	call   3a70 <open>
  if(fd >= 0){
    2b8f:	85 c0                	test   %eax,%eax
    2b91:	0f 89 b8 00 00 00    	jns    2c4f <dirfile+0x1b7>
    printf(1, "open . for writing succeeded!\n");
    exit();
  }
  fd = open(".", 0);
    2b97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2b9e:	00 
    2b9f:	c7 04 24 6a 46 00 00 	movl   $0x466a,(%esp)
    2ba6:	e8 c5 0e 00 00       	call   3a70 <open>
    2bab:	89 c3                	mov    %eax,%ebx
  if(write(fd, "x", 1) > 0){
    2bad:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    2bb4:	00 
    2bb5:	c7 44 24 04 4d 47 00 	movl   $0x474d,0x4(%esp)
    2bbc:	00 
    2bbd:	89 04 24             	mov    %eax,(%esp)
    2bc0:	e8 8b 0e 00 00       	call   3a50 <write>
    2bc5:	85 c0                	test   %eax,%eax
    2bc7:	7f 6d                	jg     2c36 <dirfile+0x19e>
    printf(1, "write . succeeded!\n");
    exit();
  }
  close(fd);
    2bc9:	89 1c 24             	mov    %ebx,(%esp)
    2bcc:	e8 87 0e 00 00       	call   3a58 <close>

  printf(1, "dir vs file OK\n");
    2bd1:	c7 44 24 04 41 4b 00 	movl   $0x4b41,0x4(%esp)
    2bd8:	00 
    2bd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2be0:	e8 7b 0f 00 00       	call   3b60 <printf>
}
    2be5:	83 c4 14             	add    $0x14,%esp
    2be8:	5b                   	pop    %ebx
    2be9:	5d                   	pop    %ebp
    2bea:	c3                   	ret    
    printf(1, "create dirfile/xx succeeded!\n");
    exit();
  }
  fd = open("dirfile/xx", O_CREATE);
  if(fd >= 0){
    printf(1, "create dirfile/xx succeeded!\n");
    2beb:	c7 44 24 04 b5 4a 00 	movl   $0x4ab5,0x4(%esp)
    2bf2:	00 
    2bf3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bfa:	e8 61 0f 00 00       	call   3b60 <printf>
    exit();
    2bff:	e8 2c 0e 00 00       	call   3a30 <exit>
    printf(1, "create dirfile failed\n");
    exit();
  }
  close(fd);
  if(chdir("dirfile") == 0){
    printf(1, "chdir dirfile succeeded!\n");
    2c04:	c7 44 24 04 90 4a 00 	movl   $0x4a90,0x4(%esp)
    2c0b:	00 
    2c0c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c13:	e8 48 0f 00 00       	call   3b60 <printf>
    exit();
    2c18:	e8 13 0e 00 00       	call   3a30 <exit>

  printf(1, "dir vs file\n");

  fd = open("dirfile", O_CREATE);
  if(fd < 0){
    printf(1, "create dirfile failed\n");
    2c1d:	c7 44 24 04 79 4a 00 	movl   $0x4a79,0x4(%esp)
    2c24:	00 
    2c25:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c2c:	e8 2f 0f 00 00       	call   3b60 <printf>
    exit();
    2c31:	e8 fa 0d 00 00       	call   3a30 <exit>
    printf(1, "open . for writing succeeded!\n");
    exit();
  }
  fd = open(".", 0);
  if(write(fd, "x", 1) > 0){
    printf(1, "write . succeeded!\n");
    2c36:	c7 44 24 04 2d 4b 00 	movl   $0x4b2d,0x4(%esp)
    2c3d:	00 
    2c3e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c45:	e8 16 0f 00 00       	call   3b60 <printf>
    exit();
    2c4a:	e8 e1 0d 00 00       	call   3a30 <exit>
    exit();
  }

  fd = open(".", O_RDWR);
  if(fd >= 0){
    printf(1, "open . for writing succeeded!\n");
    2c4f:	c7 44 24 04 24 53 00 	movl   $0x5324,0x4(%esp)
    2c56:	00 
    2c57:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c5e:	e8 fd 0e 00 00       	call   3b60 <printf>
    exit();
    2c63:	e8 c8 0d 00 00       	call   3a30 <exit>
  if(link("README", "dirfile/xx") == 0){
    printf(1, "link to dirfile/xx succeeded!\n");
    exit();
  }
  if(unlink("dirfile") != 0){
    printf(1, "unlink dirfile failed!\n");
    2c68:	c7 44 24 04 15 4b 00 	movl   $0x4b15,0x4(%esp)
    2c6f:	00 
    2c70:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c77:	e8 e4 0e 00 00       	call   3b60 <printf>
    exit();
    2c7c:	e8 af 0d 00 00       	call   3a30 <exit>
  if(unlink("dirfile/xx") == 0){
    printf(1, "unlink dirfile/xx succeeded!\n");
    exit();
  }
  if(link("README", "dirfile/xx") == 0){
    printf(1, "link to dirfile/xx succeeded!\n");
    2c81:	c7 44 24 04 04 53 00 	movl   $0x5304,0x4(%esp)
    2c88:	00 
    2c89:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c90:	e8 cb 0e 00 00       	call   3b60 <printf>
    exit();
    2c95:	e8 96 0d 00 00       	call   3a30 <exit>
  if(mkdir("dirfile/xx") == 0){
    printf(1, "mkdir dirfile/xx succeeded!\n");
    exit();
  }
  if(unlink("dirfile/xx") == 0){
    printf(1, "unlink dirfile/xx succeeded!\n");
    2c9a:	c7 44 24 04 f0 4a 00 	movl   $0x4af0,0x4(%esp)
    2ca1:	00 
    2ca2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ca9:	e8 b2 0e 00 00       	call   3b60 <printf>
    exit();
    2cae:	e8 7d 0d 00 00       	call   3a30 <exit>
  if(fd >= 0){
    printf(1, "create dirfile/xx succeeded!\n");
    exit();
  }
  if(mkdir("dirfile/xx") == 0){
    printf(1, "mkdir dirfile/xx succeeded!\n");
    2cb3:	c7 44 24 04 d3 4a 00 	movl   $0x4ad3,0x4(%esp)
    2cba:	00 
    2cbb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2cc2:	e8 99 0e 00 00       	call   3b60 <printf>
    exit();
    2cc7:	e8 64 0d 00 00       	call   3a30 <exit>

00002ccc <iref>:
}

// test that iput() is called at the end of _namei()
void
iref(void)
{
    2ccc:	55                   	push   %ebp
    2ccd:	89 e5                	mov    %esp,%ebp
    2ccf:	53                   	push   %ebx
    2cd0:	83 ec 14             	sub    $0x14,%esp
  int i, fd;

  printf(1, "empty file name\n");
    2cd3:	c7 44 24 04 51 4b 00 	movl   $0x4b51,0x4(%esp)
    2cda:	00 
    2cdb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ce2:	e8 79 0e 00 00       	call   3b60 <printf>
    2ce7:	bb 33 00 00 00       	mov    $0x33,%ebx

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    if(mkdir("irefd") != 0){
    2cec:	c7 04 24 62 4b 00 00 	movl   $0x4b62,(%esp)
    2cf3:	e8 a0 0d 00 00       	call   3a98 <mkdir>
    2cf8:	85 c0                	test   %eax,%eax
    2cfa:	0f 85 ad 00 00 00    	jne    2dad <iref+0xe1>
      printf(1, "mkdir irefd failed\n");
      exit();
    }
    if(chdir("irefd") != 0){
    2d00:	c7 04 24 62 4b 00 00 	movl   $0x4b62,(%esp)
    2d07:	e8 94 0d 00 00       	call   3aa0 <chdir>
    2d0c:	85 c0                	test   %eax,%eax
    2d0e:	0f 85 b2 00 00 00    	jne    2dc6 <iref+0xfa>
      printf(1, "chdir irefd failed\n");
      exit();
    }

    mkdir("");
    2d14:	c7 04 24 17 42 00 00 	movl   $0x4217,(%esp)
    2d1b:	e8 78 0d 00 00       	call   3a98 <mkdir>
    link("README", "");
    2d20:	c7 44 24 04 17 42 00 	movl   $0x4217,0x4(%esp)
    2d27:	00 
    2d28:	c7 04 24 0e 4b 00 00 	movl   $0x4b0e,(%esp)
    2d2f:	e8 5c 0d 00 00       	call   3a90 <link>
    fd = open("", O_CREATE);
    2d34:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2d3b:	00 
    2d3c:	c7 04 24 17 42 00 00 	movl   $0x4217,(%esp)
    2d43:	e8 28 0d 00 00       	call   3a70 <open>
    if(fd >= 0)
    2d48:	85 c0                	test   %eax,%eax
    2d4a:	78 08                	js     2d54 <iref+0x88>
      close(fd);
    2d4c:	89 04 24             	mov    %eax,(%esp)
    2d4f:	e8 04 0d 00 00       	call   3a58 <close>
    fd = open("xx", O_CREATE);
    2d54:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2d5b:	00 
    2d5c:	c7 04 24 4c 47 00 00 	movl   $0x474c,(%esp)
    2d63:	e8 08 0d 00 00       	call   3a70 <open>
    if(fd >= 0)
    2d68:	85 c0                	test   %eax,%eax
    2d6a:	78 08                	js     2d74 <iref+0xa8>
      close(fd);
    2d6c:	89 04 24             	mov    %eax,(%esp)
    2d6f:	e8 e4 0c 00 00       	call   3a58 <close>
    unlink("xx");
    2d74:	c7 04 24 4c 47 00 00 	movl   $0x474c,(%esp)
    2d7b:	e8 00 0d 00 00       	call   3a80 <unlink>
  int i, fd;

  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    2d80:	4b                   	dec    %ebx
    2d81:	0f 85 65 ff ff ff    	jne    2cec <iref+0x20>
    if(fd >= 0)
      close(fd);
    unlink("xx");
  }

  chdir("/");
    2d87:	c7 04 24 3d 3e 00 00 	movl   $0x3e3d,(%esp)
    2d8e:	e8 0d 0d 00 00       	call   3aa0 <chdir>
  printf(1, "empty file name OK\n");
    2d93:	c7 44 24 04 90 4b 00 	movl   $0x4b90,0x4(%esp)
    2d9a:	00 
    2d9b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2da2:	e8 b9 0d 00 00       	call   3b60 <printf>
}
    2da7:	83 c4 14             	add    $0x14,%esp
    2daa:	5b                   	pop    %ebx
    2dab:	5d                   	pop    %ebp
    2dac:	c3                   	ret    
  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    if(mkdir("irefd") != 0){
      printf(1, "mkdir irefd failed\n");
    2dad:	c7 44 24 04 68 4b 00 	movl   $0x4b68,0x4(%esp)
    2db4:	00 
    2db5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2dbc:	e8 9f 0d 00 00       	call   3b60 <printf>
      exit();
    2dc1:	e8 6a 0c 00 00       	call   3a30 <exit>
    }
    if(chdir("irefd") != 0){
      printf(1, "chdir irefd failed\n");
    2dc6:	c7 44 24 04 7c 4b 00 	movl   $0x4b7c,0x4(%esp)
    2dcd:	00 
    2dce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2dd5:	e8 86 0d 00 00       	call   3b60 <printf>
      exit();
    2dda:	e8 51 0c 00 00       	call   3a30 <exit>
    2ddf:	90                   	nop

00002de0 <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    2de0:	55                   	push   %ebp
    2de1:	89 e5                	mov    %esp,%ebp
    2de3:	53                   	push   %ebx
    2de4:	83 ec 14             	sub    $0x14,%esp
  int n, pid;

  printf(1, "fork test\n");
    2de7:	c7 44 24 04 a4 4b 00 	movl   $0x4ba4,0x4(%esp)
    2dee:	00 
    2def:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2df6:	e8 65 0d 00 00       	call   3b60 <printf>

  for(n=0; n<1000; n++){
    2dfb:	31 db                	xor    %ebx,%ebx
    2dfd:	eb 0c                	jmp    2e0b <forktest+0x2b>
    2dff:	90                   	nop
    pid = fork();
    if(pid < 0)
      break;
    if(pid == 0)
    2e00:	74 77                	je     2e79 <forktest+0x99>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<1000; n++){
    2e02:	43                   	inc    %ebx
    2e03:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
    2e09:	74 41                	je     2e4c <forktest+0x6c>
    pid = fork();
    2e0b:	e8 18 0c 00 00       	call   3a28 <fork>
    if(pid < 0)
    2e10:	83 f8 00             	cmp    $0x0,%eax
    2e13:	7d eb                	jge    2e00 <forktest+0x20>
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    exit();
  }

  for(; n > 0; n--){
    2e15:	85 db                	test   %ebx,%ebx
    2e17:	74 0f                	je     2e28 <forktest+0x48>
    2e19:	8d 76 00             	lea    0x0(%esi),%esi
    if(wait() < 0){
    2e1c:	e8 17 0c 00 00       	call   3a38 <wait>
    2e21:	85 c0                	test   %eax,%eax
    2e23:	78 40                	js     2e65 <forktest+0x85>
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    exit();
  }

  for(; n > 0; n--){
    2e25:	4b                   	dec    %ebx
    2e26:	75 f4                	jne    2e1c <forktest+0x3c>
      printf(1, "wait stopped early\n");
      exit();
    }
  }

  if(wait() != -1){
    2e28:	e8 0b 0c 00 00       	call   3a38 <wait>
    2e2d:	40                   	inc    %eax
    2e2e:	75 4e                	jne    2e7e <forktest+0x9e>
    printf(1, "wait got too many\n");
    exit();
  }

  printf(1, "fork test OK\n");
    2e30:	c7 44 24 04 d6 4b 00 	movl   $0x4bd6,0x4(%esp)
    2e37:	00 
    2e38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e3f:	e8 1c 0d 00 00       	call   3b60 <printf>
}
    2e44:	83 c4 14             	add    $0x14,%esp
    2e47:	5b                   	pop    %ebx
    2e48:	5d                   	pop    %ebp
    2e49:	c3                   	ret    
    2e4a:	66 90                	xchg   %ax,%ax
    if(pid == 0)
      exit();
  }

  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    2e4c:	c7 44 24 04 44 53 00 	movl   $0x5344,0x4(%esp)
    2e53:	00 
    2e54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e5b:	e8 00 0d 00 00       	call   3b60 <printf>
    exit();
    2e60:	e8 cb 0b 00 00       	call   3a30 <exit>
  }

  for(; n > 0; n--){
    if(wait() < 0){
      printf(1, "wait stopped early\n");
    2e65:	c7 44 24 04 af 4b 00 	movl   $0x4baf,0x4(%esp)
    2e6c:	00 
    2e6d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e74:	e8 e7 0c 00 00       	call   3b60 <printf>
      exit();
    2e79:	e8 b2 0b 00 00       	call   3a30 <exit>
    }
  }

  if(wait() != -1){
    printf(1, "wait got too many\n");
    2e7e:	c7 44 24 04 c3 4b 00 	movl   $0x4bc3,0x4(%esp)
    2e85:	00 
    2e86:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e8d:	e8 ce 0c 00 00       	call   3b60 <printf>
    exit();
    2e92:	e8 99 0b 00 00       	call   3a30 <exit>
    2e97:	90                   	nop

00002e98 <sbrktest>:
  printf(1, "fork test OK\n");
}

void
sbrktest(void)
{
    2e98:	55                   	push   %ebp
    2e99:	89 e5                	mov    %esp,%ebp
    2e9b:	57                   	push   %edi
    2e9c:	56                   	push   %esi
    2e9d:	53                   	push   %ebx
    2e9e:	83 ec 7c             	sub    $0x7c,%esp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    2ea1:	c7 44 24 04 e4 4b 00 	movl   $0x4be4,0x4(%esp)
    2ea8:	00 
    2ea9:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    2eae:	89 04 24             	mov    %eax,(%esp)
    2eb1:	e8 aa 0c 00 00       	call   3b60 <printf>
  oldbrk = sbrk(0);
    2eb6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2ebd:	e8 f6 0b 00 00       	call   3ab8 <sbrk>
    2ec2:	89 45 a4             	mov    %eax,-0x5c(%ebp)

  // can one sbrk() less than a page?
  a = sbrk(0);
    2ec5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2ecc:	e8 e7 0b 00 00       	call   3ab8 <sbrk>
    2ed1:	89 c3                	mov    %eax,%ebx
  int i;
  for(i = 0; i < 5000; i++){
    2ed3:	31 f6                	xor    %esi,%esi
    2ed5:	8d 76 00             	lea    0x0(%esi),%esi
    b = sbrk(1);
    2ed8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2edf:	e8 d4 0b 00 00       	call   3ab8 <sbrk>
    if(b != a){
    2ee4:	39 d8                	cmp    %ebx,%eax
    2ee6:	0f 85 66 02 00 00    	jne    3152 <sbrktest+0x2ba>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
      exit();
    }
    *b = 1;
    2eec:	c6 03 01             	movb   $0x1,(%ebx)
    a = b + 1;
    2eef:	43                   	inc    %ebx
  oldbrk = sbrk(0);

  // can one sbrk() less than a page?
  a = sbrk(0);
  int i;
  for(i = 0; i < 5000; i++){
    2ef0:	46                   	inc    %esi
    2ef1:	81 fe 88 13 00 00    	cmp    $0x1388,%esi
    2ef7:	75 df                	jne    2ed8 <sbrktest+0x40>
      exit();
    }
    *b = 1;
    a = b + 1;
  }
  pid = fork();
    2ef9:	e8 2a 0b 00 00       	call   3a28 <fork>
    2efe:	89 c6                	mov    %eax,%esi
  if(pid < 0){
    2f00:	85 c0                	test   %eax,%eax
    2f02:	0f 88 b8 03 00 00    	js     32c0 <sbrktest+0x428>
    printf(stdout, "sbrk test fork failed\n");
    exit();
  }
  c = sbrk(1);
    2f08:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f0f:	e8 a4 0b 00 00       	call   3ab8 <sbrk>
  c = sbrk(1);
    2f14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f1b:	e8 98 0b 00 00       	call   3ab8 <sbrk>
  if(c != a + 1){
    2f20:	43                   	inc    %ebx
    2f21:	39 d8                	cmp    %ebx,%eax
    2f23:	0f 85 7d 03 00 00    	jne    32a6 <sbrktest+0x40e>
    printf(stdout, "sbrk test failed post-fork\n");
    exit();
  }
  if(pid == 0)
    2f29:	85 f6                	test   %esi,%esi
    2f2b:	0f 84 70 03 00 00    	je     32a1 <sbrktest+0x409>
    exit();
  wait();
    2f31:	e8 02 0b 00 00       	call   3a38 <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    2f36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2f3d:	e8 76 0b 00 00       	call   3ab8 <sbrk>
    2f42:	89 c3                	mov    %eax,%ebx
  amt = (BIG) - (uint)a;
    2f44:	b8 00 00 40 06       	mov    $0x6400000,%eax
    2f49:	29 d8                	sub    %ebx,%eax
  p = sbrk(amt);
    2f4b:	89 04 24             	mov    %eax,(%esp)
    2f4e:	e8 65 0b 00 00       	call   3ab8 <sbrk>
  if (p != a) {
    2f53:	39 d8                	cmp    %ebx,%eax
    2f55:	0f 85 31 03 00 00    	jne    328c <sbrktest+0x3f4>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    exit();
  }
  lastaddr = (char*) (BIG-1);
  *lastaddr = 99;
    2f5b:	c6 05 ff ff 3f 06 63 	movb   $0x63,0x63fffff

  // can one de-allocate?
  a = sbrk(0);
    2f62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2f69:	e8 4a 0b 00 00       	call   3ab8 <sbrk>
    2f6e:	89 c3                	mov    %eax,%ebx
  c = sbrk(-4096);
    2f70:	c7 04 24 00 f0 ff ff 	movl   $0xfffff000,(%esp)
    2f77:	e8 3c 0b 00 00       	call   3ab8 <sbrk>
  if(c == (char*)0xffffffff){
    2f7c:	40                   	inc    %eax
    2f7d:	0f 84 ef 02 00 00    	je     3272 <sbrktest+0x3da>
    printf(stdout, "sbrk could not deallocate\n");
    exit();
  }
  c = sbrk(0);
    2f83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2f8a:	e8 29 0b 00 00       	call   3ab8 <sbrk>
  if(c != a - 4096){
    2f8f:	8d 93 00 f0 ff ff    	lea    -0x1000(%ebx),%edx
    2f95:	39 d0                	cmp    %edx,%eax
    2f97:	0f 85 b3 02 00 00    	jne    3250 <sbrktest+0x3b8>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    exit();
  }

  // can one re-allocate that page?
  a = sbrk(0);
    2f9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2fa4:	e8 0f 0b 00 00       	call   3ab8 <sbrk>
    2fa9:	89 c6                	mov    %eax,%esi
  c = sbrk(4096);
    2fab:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    2fb2:	e8 01 0b 00 00       	call   3ab8 <sbrk>
    2fb7:	89 c3                	mov    %eax,%ebx
  if(c != a || sbrk(0) != a + 4096){
    2fb9:	39 f0                	cmp    %esi,%eax
    2fbb:	0f 85 6d 02 00 00    	jne    322e <sbrktest+0x396>
    2fc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2fc8:	e8 eb 0a 00 00       	call   3ab8 <sbrk>
    2fcd:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
    2fd3:	39 d0                	cmp    %edx,%eax
    2fd5:	0f 85 53 02 00 00    	jne    322e <sbrktest+0x396>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    exit();
  }
  if(*lastaddr == 99){
    2fdb:	80 3d ff ff 3f 06 63 	cmpb   $0x63,0x63fffff
    2fe2:	0f 84 2c 02 00 00    	je     3214 <sbrktest+0x37c>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    exit();
  }

  a = sbrk(0);
    2fe8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2fef:	e8 c4 0a 00 00       	call   3ab8 <sbrk>
    2ff4:	89 c3                	mov    %eax,%ebx
  c = sbrk(-(sbrk(0) - oldbrk));
    2ff6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2ffd:	e8 b6 0a 00 00       	call   3ab8 <sbrk>
    3002:	8b 55 a4             	mov    -0x5c(%ebp),%edx
    3005:	29 c2                	sub    %eax,%edx
    3007:	89 14 24             	mov    %edx,(%esp)
    300a:	e8 a9 0a 00 00       	call   3ab8 <sbrk>
  if(c != a){
    300f:	39 d8                	cmp    %ebx,%eax
    3011:	0f 85 db 01 00 00    	jne    31f2 <sbrktest+0x35a>
    3017:	bb 00 00 00 80       	mov    $0x80000000,%ebx
    exit();
  }

  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    ppid = getpid();
    301c:	e8 8f 0a 00 00       	call   3ab0 <getpid>
    3021:	89 c6                	mov    %eax,%esi
    pid = fork();
    3023:	e8 00 0a 00 00       	call   3a28 <fork>
    if(pid < 0){
    3028:	83 f8 00             	cmp    $0x0,%eax
    302b:	0f 8c a7 01 00 00    	jl     31d8 <sbrktest+0x340>
      printf(stdout, "fork failed\n");
      exit();
    }
    if(pid == 0){
    3031:	0f 84 74 01 00 00    	je     31ab <sbrktest+0x313>
      printf(stdout, "oops could read %x = %x\n", a, *a);
      kill(ppid);
      exit();
    }
    wait();
    3037:	e8 fc 09 00 00       	call   3a38 <wait>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    exit();
  }

  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    303c:	81 c3 50 c3 00 00    	add    $0xc350,%ebx
    3042:	81 fb 80 84 1e 80    	cmp    $0x801e8480,%ebx
    3048:	75 d2                	jne    301c <sbrktest+0x184>
    wait();
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    304a:	8d 7d dc             	lea    -0x24(%ebp),%edi
    304d:	89 3c 24             	mov    %edi,(%esp)
    3050:	e8 eb 09 00 00       	call   3a40 <pipe>
    3055:	85 c0                	test   %eax,%eax
    3057:	0f 85 35 01 00 00    	jne    3192 <sbrktest+0x2fa>
    printf(1, "pipe() failed\n");
    exit();
    305d:	8d 5d b4             	lea    -0x4c(%ebp),%ebx

  printf(1, "fork test OK\n");
}

void
sbrktest(void)
    3060:	89 de                	mov    %ebx,%esi
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    if((pids[i] = fork()) == 0){
    3062:	e8 c1 09 00 00       	call   3a28 <fork>
    3067:	89 06                	mov    %eax,(%esi)
    3069:	85 c0                	test   %eax,%eax
    306b:	0f 84 9b 00 00 00    	je     310c <sbrktest+0x274>
      sbrk(BIG - (uint)sbrk(0));
      write(fds[1], "x", 1);
      // sit around until killed
      for(;;) sleep(1000);
    }
    if(pids[i] != -1)
    3071:	40                   	inc    %eax
    3072:	74 1a                	je     308e <sbrktest+0x1f6>
      read(fds[0], &scratch, 1);
    3074:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    307b:	00 
    307c:	8d 45 e7             	lea    -0x19(%ebp),%eax
    307f:	89 44 24 04          	mov    %eax,0x4(%esp)
    3083:	8b 45 dc             	mov    -0x24(%ebp),%eax
    3086:	89 04 24             	mov    %eax,(%esp)
    3089:	e8 ba 09 00 00       	call   3a48 <read>
    308e:	83 c6 04             	add    $0x4,%esi
  // failed allocation?
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3091:	39 fe                	cmp    %edi,%esi
    3093:	75 cd                	jne    3062 <sbrktest+0x1ca>
    if(pids[i] != -1)
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    3095:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    309c:	e8 17 0a 00 00       	call   3ab8 <sbrk>
    30a1:	89 c6                	mov    %eax,%esi
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    if(pids[i] == -1)
    30a3:	8b 03                	mov    (%ebx),%eax
    30a5:	83 f8 ff             	cmp    $0xffffffff,%eax
    30a8:	74 0d                	je     30b7 <sbrktest+0x21f>
      continue;
    kill(pids[i]);
    30aa:	89 04 24             	mov    %eax,(%esp)
    30ad:	e8 ae 09 00 00       	call   3a60 <kill>
    wait();
    30b2:	e8 81 09 00 00       	call   3a38 <wait>
    30b7:	83 c3 04             	add    $0x4,%ebx
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    30ba:	39 df                	cmp    %ebx,%edi
    30bc:	75 e5                	jne    30a3 <sbrktest+0x20b>
    if(pids[i] == -1)
      continue;
    kill(pids[i]);
    wait();
  }
  if(c == (char*)0xffffffff){
    30be:	46                   	inc    %esi
    30bf:	0f 84 b3 00 00 00    	je     3178 <sbrktest+0x2e0>
    printf(stdout, "failed sbrk leaked memory\n");
    exit();
  }

  if(sbrk(0) > oldbrk)
    30c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    30cc:	e8 e7 09 00 00       	call   3ab8 <sbrk>
    30d1:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
    30d4:	73 19                	jae    30ef <sbrktest+0x257>
    sbrk(-(sbrk(0) - oldbrk));
    30d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    30dd:	e8 d6 09 00 00       	call   3ab8 <sbrk>
    30e2:	8b 55 a4             	mov    -0x5c(%ebp),%edx
    30e5:	29 c2                	sub    %eax,%edx
    30e7:	89 14 24             	mov    %edx,(%esp)
    30ea:	e8 c9 09 00 00       	call   3ab8 <sbrk>

  printf(stdout, "sbrk test OK\n");
    30ef:	c7 44 24 04 8c 4c 00 	movl   $0x4c8c,0x4(%esp)
    30f6:	00 
    30f7:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    30fc:	89 04 24             	mov    %eax,(%esp)
    30ff:	e8 5c 0a 00 00       	call   3b60 <printf>
}
    3104:	83 c4 7c             	add    $0x7c,%esp
    3107:	5b                   	pop    %ebx
    3108:	5e                   	pop    %esi
    3109:	5f                   	pop    %edi
    310a:	5d                   	pop    %ebp
    310b:	c3                   	ret    
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    if((pids[i] = fork()) == 0){
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    310c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3113:	e8 a0 09 00 00       	call   3ab8 <sbrk>
    3118:	ba 00 00 40 06       	mov    $0x6400000,%edx
    311d:	29 c2                	sub    %eax,%edx
    311f:	89 14 24             	mov    %edx,(%esp)
    3122:	e8 91 09 00 00       	call   3ab8 <sbrk>
      write(fds[1], "x", 1);
    3127:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    312e:	00 
    312f:	c7 44 24 04 4d 47 00 	movl   $0x474d,0x4(%esp)
    3136:	00 
    3137:	8b 45 e0             	mov    -0x20(%ebp),%eax
    313a:	89 04 24             	mov    %eax,(%esp)
    313d:	e8 0e 09 00 00       	call   3a50 <write>
    3142:	66 90                	xchg   %ax,%ax
      // sit around until killed
      for(;;) sleep(1000);
    3144:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
    314b:	e8 70 09 00 00       	call   3ac0 <sleep>
    3150:	eb f2                	jmp    3144 <sbrktest+0x2ac>
  a = sbrk(0);
  int i;
  for(i = 0; i < 5000; i++){
    b = sbrk(1);
    if(b != a){
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    3152:	89 44 24 10          	mov    %eax,0x10(%esp)
    3156:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
    315a:	89 74 24 08          	mov    %esi,0x8(%esp)
    315e:	c7 44 24 04 ef 4b 00 	movl   $0x4bef,0x4(%esp)
    3165:	00 
    3166:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    316b:	89 04 24             	mov    %eax,(%esp)
    316e:	e8 ed 09 00 00       	call   3b60 <printf>
      exit();
    3173:	e8 b8 08 00 00       	call   3a30 <exit>
      continue;
    kill(pids[i]);
    wait();
  }
  if(c == (char*)0xffffffff){
    printf(stdout, "failed sbrk leaked memory\n");
    3178:	c7 44 24 04 71 4c 00 	movl   $0x4c71,0x4(%esp)
    317f:	00 
    3180:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    3185:	89 04 24             	mov    %eax,(%esp)
    3188:	e8 d3 09 00 00       	call   3b60 <printf>
    exit();
    318d:	e8 9e 08 00 00       	call   3a30 <exit>
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    3192:	c7 44 24 04 2d 41 00 	movl   $0x412d,0x4(%esp)
    3199:	00 
    319a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    31a1:	e8 ba 09 00 00       	call   3b60 <printf>
    exit();
    31a6:	e8 85 08 00 00       	call   3a30 <exit>
    if(pid < 0){
      printf(stdout, "fork failed\n");
      exit();
    }
    if(pid == 0){
      printf(stdout, "oops could read %x = %x\n", a, *a);
    31ab:	0f be 03             	movsbl (%ebx),%eax
    31ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
    31b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    31b6:	c7 44 24 04 58 4c 00 	movl   $0x4c58,0x4(%esp)
    31bd:	00 
    31be:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    31c3:	89 04 24             	mov    %eax,(%esp)
    31c6:	e8 95 09 00 00       	call   3b60 <printf>
      kill(ppid);
    31cb:	89 34 24             	mov    %esi,(%esp)
    31ce:	e8 8d 08 00 00       	call   3a60 <kill>
      exit();
    31d3:	e8 58 08 00 00       	call   3a30 <exit>
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    ppid = getpid();
    pid = fork();
    if(pid < 0){
      printf(stdout, "fork failed\n");
    31d8:	c7 44 24 04 35 4d 00 	movl   $0x4d35,0x4(%esp)
    31df:	00 
    31e0:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    31e5:	89 04 24             	mov    %eax,(%esp)
    31e8:	e8 73 09 00 00       	call   3b60 <printf>
      exit();
    31ed:	e8 3e 08 00 00       	call   3a30 <exit>
  }

  a = sbrk(0);
  c = sbrk(-(sbrk(0) - oldbrk));
  if(c != a){
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    31f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
    31f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    31fa:	c7 44 24 04 38 54 00 	movl   $0x5438,0x4(%esp)
    3201:	00 
    3202:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    3207:	89 04 24             	mov    %eax,(%esp)
    320a:	e8 51 09 00 00       	call   3b60 <printf>
    exit();
    320f:	e8 1c 08 00 00       	call   3a30 <exit>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    exit();
  }
  if(*lastaddr == 99){
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    3214:	c7 44 24 04 08 54 00 	movl   $0x5408,0x4(%esp)
    321b:	00 
    321c:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    3221:	89 04 24             	mov    %eax,(%esp)
    3224:	e8 37 09 00 00       	call   3b60 <printf>
    exit();
    3229:	e8 02 08 00 00       	call   3a30 <exit>

  // can one re-allocate that page?
  a = sbrk(0);
  c = sbrk(4096);
  if(c != a || sbrk(0) != a + 4096){
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    322e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
    3232:	89 74 24 08          	mov    %esi,0x8(%esp)
    3236:	c7 44 24 04 e0 53 00 	movl   $0x53e0,0x4(%esp)
    323d:	00 
    323e:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    3243:	89 04 24             	mov    %eax,(%esp)
    3246:	e8 15 09 00 00       	call   3b60 <printf>
    exit();
    324b:	e8 e0 07 00 00       	call   3a30 <exit>
    printf(stdout, "sbrk could not deallocate\n");
    exit();
  }
  c = sbrk(0);
  if(c != a - 4096){
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    3250:	89 44 24 0c          	mov    %eax,0xc(%esp)
    3254:	89 5c 24 08          	mov    %ebx,0x8(%esp)
    3258:	c7 44 24 04 a8 53 00 	movl   $0x53a8,0x4(%esp)
    325f:	00 
    3260:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    3265:	89 04 24             	mov    %eax,(%esp)
    3268:	e8 f3 08 00 00       	call   3b60 <printf>
    exit();
    326d:	e8 be 07 00 00       	call   3a30 <exit>

  // can one de-allocate?
  a = sbrk(0);
  c = sbrk(-4096);
  if(c == (char*)0xffffffff){
    printf(stdout, "sbrk could not deallocate\n");
    3272:	c7 44 24 04 3d 4c 00 	movl   $0x4c3d,0x4(%esp)
    3279:	00 
    327a:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    327f:	89 04 24             	mov    %eax,(%esp)
    3282:	e8 d9 08 00 00       	call   3b60 <printf>
    exit();
    3287:	e8 a4 07 00 00       	call   3a30 <exit>
#define BIG (100*1024*1024)
  a = sbrk(0);
  amt = (BIG) - (uint)a;
  p = sbrk(amt);
  if (p != a) {
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    328c:	c7 44 24 04 68 53 00 	movl   $0x5368,0x4(%esp)
    3293:	00 
    3294:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    3299:	89 04 24             	mov    %eax,(%esp)
    329c:	e8 bf 08 00 00       	call   3b60 <printf>
    exit();
    32a1:	e8 8a 07 00 00       	call   3a30 <exit>
    exit();
  }
  c = sbrk(1);
  c = sbrk(1);
  if(c != a + 1){
    printf(stdout, "sbrk test failed post-fork\n");
    32a6:	c7 44 24 04 21 4c 00 	movl   $0x4c21,0x4(%esp)
    32ad:	00 
    32ae:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    32b3:	89 04 24             	mov    %eax,(%esp)
    32b6:	e8 a5 08 00 00       	call   3b60 <printf>
    exit();
    32bb:	e8 70 07 00 00       	call   3a30 <exit>
    *b = 1;
    a = b + 1;
  }
  pid = fork();
  if(pid < 0){
    printf(stdout, "sbrk test fork failed\n");
    32c0:	c7 44 24 04 0a 4c 00 	movl   $0x4c0a,0x4(%esp)
    32c7:	00 
    32c8:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    32cd:	89 04 24             	mov    %eax,(%esp)
    32d0:	e8 8b 08 00 00       	call   3b60 <printf>
    exit();
    32d5:	e8 56 07 00 00       	call   3a30 <exit>
    32da:	66 90                	xchg   %ax,%ax

000032dc <validateint>:
  printf(stdout, "sbrk test OK\n");
}

void
validateint(int *p)
{
    32dc:	55                   	push   %ebp
    32dd:	89 e5                	mov    %esp,%ebp
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
    32df:	5d                   	pop    %ebp
    32e0:	c3                   	ret    
    32e1:	8d 76 00             	lea    0x0(%esi),%esi

000032e4 <validatetest>:

void
validatetest(void)
{
    32e4:	55                   	push   %ebp
    32e5:	89 e5                	mov    %esp,%ebp
    32e7:	56                   	push   %esi
    32e8:	53                   	push   %ebx
    32e9:	83 ec 10             	sub    $0x10,%esp
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    32ec:	c7 44 24 04 9a 4c 00 	movl   $0x4c9a,0x4(%esp)
    32f3:	00 
    32f4:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    32f9:	89 04 24             	mov    %eax,(%esp)
    32fc:	e8 5f 08 00 00       	call   3b60 <printf>
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    3301:	31 db                	xor    %ebx,%ebx
    3303:	90                   	nop
    if((pid = fork()) == 0){
    3304:	e8 1f 07 00 00       	call   3a28 <fork>
    3309:	89 c6                	mov    %eax,%esi
    330b:	85 c0                	test   %eax,%eax
    330d:	74 77                	je     3386 <validatetest+0xa2>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
      exit();
    }
    sleep(0);
    330f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3316:	e8 a5 07 00 00       	call   3ac0 <sleep>
    sleep(0);
    331b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3322:	e8 99 07 00 00       	call   3ac0 <sleep>
    kill(pid);
    3327:	89 34 24             	mov    %esi,(%esp)
    332a:	e8 31 07 00 00       	call   3a60 <kill>
    wait();
    332f:	e8 04 07 00 00       	call   3a38 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    3334:	89 5c 24 04          	mov    %ebx,0x4(%esp)
    3338:	c7 04 24 a9 4c 00 00 	movl   $0x4ca9,(%esp)
    333f:	e8 4c 07 00 00       	call   3a90 <link>
    3344:	40                   	inc    %eax
    3345:	75 2a                	jne    3371 <validatetest+0x8d>
  uint p;

  printf(stdout, "validate test\n");
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    3347:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    334d:	81 fb 00 40 11 00    	cmp    $0x114000,%ebx
    3353:	75 af                	jne    3304 <validatetest+0x20>
      printf(stdout, "link should not succeed\n");
      exit();
    }
  }

  printf(stdout, "validate ok\n");
    3355:	c7 44 24 04 cd 4c 00 	movl   $0x4ccd,0x4(%esp)
    335c:	00 
    335d:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    3362:	89 04 24             	mov    %eax,(%esp)
    3365:	e8 f6 07 00 00       	call   3b60 <printf>
}
    336a:	83 c4 10             	add    $0x10,%esp
    336d:	5b                   	pop    %ebx
    336e:	5e                   	pop    %esi
    336f:	5d                   	pop    %ebp
    3370:	c3                   	ret    
    kill(pid);
    wait();

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
      printf(stdout, "link should not succeed\n");
    3371:	c7 44 24 04 b4 4c 00 	movl   $0x4cb4,0x4(%esp)
    3378:	00 
    3379:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    337e:	89 04 24             	mov    %eax,(%esp)
    3381:	e8 da 07 00 00       	call   3b60 <printf>
      exit();
    3386:	e8 a5 06 00 00       	call   3a30 <exit>
    338b:	90                   	nop

0000338c <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    338c:	55                   	push   %ebp
    338d:	89 e5                	mov    %esp,%ebp
    338f:	83 ec 18             	sub    $0x18,%esp
  int i;

  printf(stdout, "bss test\n");
    3392:	c7 44 24 04 da 4c 00 	movl   $0x4cda,0x4(%esp)
    3399:	00 
    339a:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    339f:	89 04 24             	mov    %eax,(%esp)
    33a2:	e8 b9 07 00 00       	call   3b60 <printf>
  for(i = 0; i < sizeof(uninit); i++){
    if(uninit[i] != '\0'){
    33a7:	80 3d 60 5f 00 00 00 	cmpb   $0x0,0x5f60
    33ae:	75 30                	jne    33e0 <bsstest+0x54>
    33b0:	b8 01 00 00 00       	mov    $0x1,%eax
    33b5:	8d 76 00             	lea    0x0(%esi),%esi
    33b8:	80 b8 60 5f 00 00 00 	cmpb   $0x0,0x5f60(%eax)
    33bf:	75 1f                	jne    33e0 <bsstest+0x54>
bsstest(void)
{
  int i;

  printf(stdout, "bss test\n");
  for(i = 0; i < sizeof(uninit); i++){
    33c1:	40                   	inc    %eax
    33c2:	3d 10 27 00 00       	cmp    $0x2710,%eax
    33c7:	75 ef                	jne    33b8 <bsstest+0x2c>
    if(uninit[i] != '\0'){
      printf(stdout, "bss test failed\n");
      exit();
    }
  }
  printf(stdout, "bss test ok\n");
    33c9:	c7 44 24 04 f5 4c 00 	movl   $0x4cf5,0x4(%esp)
    33d0:	00 
    33d1:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    33d6:	89 04 24             	mov    %eax,(%esp)
    33d9:	e8 82 07 00 00       	call   3b60 <printf>
}
    33de:	c9                   	leave  
    33df:	c3                   	ret    
  int i;

  printf(stdout, "bss test\n");
  for(i = 0; i < sizeof(uninit); i++){
    if(uninit[i] != '\0'){
      printf(stdout, "bss test failed\n");
    33e0:	c7 44 24 04 e4 4c 00 	movl   $0x4ce4,0x4(%esp)
    33e7:	00 
    33e8:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    33ed:	89 04 24             	mov    %eax,(%esp)
    33f0:	e8 6b 07 00 00       	call   3b60 <printf>
      exit();
    33f5:	e8 36 06 00 00       	call   3a30 <exit>
    33fa:	66 90                	xchg   %ax,%ax

000033fc <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    33fc:	55                   	push   %ebp
    33fd:	89 e5                	mov    %esp,%ebp
    33ff:	83 ec 18             	sub    $0x18,%esp
  int pid, fd;

  unlink("bigarg-ok");
    3402:	c7 04 24 02 4d 00 00 	movl   $0x4d02,(%esp)
    3409:	e8 72 06 00 00       	call   3a80 <unlink>
  pid = fork();
    340e:	e8 15 06 00 00       	call   3a28 <fork>
  if(pid == 0){
    3413:	83 f8 00             	cmp    $0x0,%eax
    3416:	74 40                	je     3458 <bigargtest+0x5c>
    exec("echo", args);
    printf(stdout, "bigarg test ok\n");
    fd = open("bigarg-ok", O_CREATE);
    close(fd);
    exit();
  } else if(pid < 0){
    3418:	0f 8c ce 00 00 00    	jl     34ec <bigargtest+0xf0>
    printf(stdout, "bigargtest: fork failed\n");
    exit();
  }
  wait();
    341e:	e8 15 06 00 00       	call   3a38 <wait>
  fd = open("bigarg-ok", 0);
    3423:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    342a:	00 
    342b:	c7 04 24 02 4d 00 00 	movl   $0x4d02,(%esp)
    3432:	e8 39 06 00 00       	call   3a70 <open>
  if(fd < 0){
    3437:	85 c0                	test   %eax,%eax
    3439:	0f 88 93 00 00 00    	js     34d2 <bigargtest+0xd6>
    printf(stdout, "bigarg test failed!\n");
    exit();
  }
  close(fd);
    343f:	89 04 24             	mov    %eax,(%esp)
    3442:	e8 11 06 00 00       	call   3a58 <close>
  unlink("bigarg-ok");
    3447:	c7 04 24 02 4d 00 00 	movl   $0x4d02,(%esp)
    344e:	e8 2d 06 00 00       	call   3a80 <unlink>
}
    3453:	c9                   	leave  
    3454:	c3                   	ret    
    3455:	8d 76 00             	lea    0x0(%esi),%esi
  pid = fork();
  if(pid == 0){
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    3458:	c7 04 85 c0 5e 00 00 	movl   $0x545c,0x5ec0(,%eax,4)
    345f:	5c 54 00 00 
  unlink("bigarg-ok");
  pid = fork();
  if(pid == 0){
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    3463:	40                   	inc    %eax
    3464:	83 f8 1f             	cmp    $0x1f,%eax
    3467:	75 ef                	jne    3458 <bigargtest+0x5c>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    args[MAXARG-1] = 0;
    3469:	c7 05 3c 5f 00 00 00 	movl   $0x0,0x5f3c
    3470:	00 00 00 
    printf(stdout, "bigarg test\n");
    3473:	c7 44 24 04 0c 4d 00 	movl   $0x4d0c,0x4(%esp)
    347a:	00 
    347b:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    3480:	89 04 24             	mov    %eax,(%esp)
    3483:	e8 d8 06 00 00       	call   3b60 <printf>
    exec("echo", args);
    3488:	c7 44 24 04 c0 5e 00 	movl   $0x5ec0,0x4(%esp)
    348f:	00 
    3490:	c7 04 24 d9 3e 00 00 	movl   $0x3ed9,(%esp)
    3497:	e8 cc 05 00 00       	call   3a68 <exec>
    printf(stdout, "bigarg test ok\n");
    349c:	c7 44 24 04 19 4d 00 	movl   $0x4d19,0x4(%esp)
    34a3:	00 
    34a4:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    34a9:	89 04 24             	mov    %eax,(%esp)
    34ac:	e8 af 06 00 00       	call   3b60 <printf>
    fd = open("bigarg-ok", O_CREATE);
    34b1:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    34b8:	00 
    34b9:	c7 04 24 02 4d 00 00 	movl   $0x4d02,(%esp)
    34c0:	e8 ab 05 00 00       	call   3a70 <open>
    close(fd);
    34c5:	89 04 24             	mov    %eax,(%esp)
    34c8:	e8 8b 05 00 00       	call   3a58 <close>
    exit();
    34cd:	e8 5e 05 00 00       	call   3a30 <exit>
    exit();
  }
  wait();
  fd = open("bigarg-ok", 0);
  if(fd < 0){
    printf(stdout, "bigarg test failed!\n");
    34d2:	c7 44 24 04 42 4d 00 	movl   $0x4d42,0x4(%esp)
    34d9:	00 
    34da:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    34df:	89 04 24             	mov    %eax,(%esp)
    34e2:	e8 79 06 00 00       	call   3b60 <printf>
    exit();
    34e7:	e8 44 05 00 00       	call   3a30 <exit>
    printf(stdout, "bigarg test ok\n");
    fd = open("bigarg-ok", O_CREATE);
    close(fd);
    exit();
  } else if(pid < 0){
    printf(stdout, "bigargtest: fork failed\n");
    34ec:	c7 44 24 04 29 4d 00 	movl   $0x4d29,0x4(%esp)
    34f3:	00 
    34f4:	a1 a4 5e 00 00       	mov    0x5ea4,%eax
    34f9:	89 04 24             	mov    %eax,(%esp)
    34fc:	e8 5f 06 00 00       	call   3b60 <printf>
    exit();
    3501:	e8 2a 05 00 00       	call   3a30 <exit>
    3506:	66 90                	xchg   %ax,%ax

00003508 <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    3508:	55                   	push   %ebp
    3509:	89 e5                	mov    %esp,%ebp
    350b:	57                   	push   %edi
    350c:	56                   	push   %esi
    350d:	53                   	push   %ebx
    350e:	83 ec 6c             	sub    $0x6c,%esp
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");
    3511:	c7 44 24 04 57 4d 00 	movl   $0x4d57,0x4(%esp)
    3518:	00 
    3519:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3520:	e8 3b 06 00 00       	call   3b60 <printf>

  for(nfiles = 0; ; nfiles++){
    3525:	31 db                	xor    %ebx,%ebx
    3527:	90                   	nop
    char name[64];
    name[0] = 'f';
    3528:	c6 45 a8 66          	movb   $0x66,-0x58(%ebp)
    name[1] = '0' + nfiles / 1000;
    352c:	b8 d3 4d 62 10       	mov    $0x10624dd3,%eax
    3531:	f7 eb                	imul   %ebx
    3533:	89 55 a4             	mov    %edx,-0x5c(%ebp)
    3536:	8b 45 a4             	mov    -0x5c(%ebp),%eax
    3539:	c1 f8 06             	sar    $0x6,%eax
    353c:	89 df                	mov    %ebx,%edi
    353e:	c1 ff 1f             	sar    $0x1f,%edi
    3541:	29 f8                	sub    %edi,%eax
    3543:	8d 50 30             	lea    0x30(%eax),%edx
    3546:	88 55 a9             	mov    %dl,-0x57(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    3549:	8d 04 80             	lea    (%eax,%eax,4),%eax
    354c:	8d 04 80             	lea    (%eax,%eax,4),%eax
    354f:	8d 04 80             	lea    (%eax,%eax,4),%eax
    3552:	c1 e0 03             	shl    $0x3,%eax
    3555:	89 d9                	mov    %ebx,%ecx
    3557:	29 c1                	sub    %eax,%ecx
    3559:	b8 1f 85 eb 51       	mov    $0x51eb851f,%eax
    355e:	f7 e9                	imul   %ecx
    3560:	89 55 a4             	mov    %edx,-0x5c(%ebp)
    3563:	8b 45 a4             	mov    -0x5c(%ebp),%eax
    3566:	c1 f8 05             	sar    $0x5,%eax
    3569:	c1 f9 1f             	sar    $0x1f,%ecx
    356c:	29 c8                	sub    %ecx,%eax
    356e:	83 c0 30             	add    $0x30,%eax
    3571:	88 45 aa             	mov    %al,-0x56(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3574:	b8 1f 85 eb 51       	mov    $0x51eb851f,%eax
    3579:	f7 eb                	imul   %ebx
    357b:	89 45 a0             	mov    %eax,-0x60(%ebp)
    357e:	89 55 a4             	mov    %edx,-0x5c(%ebp)
    3581:	8b 45 a4             	mov    -0x5c(%ebp),%eax
    3584:	c1 f8 05             	sar    $0x5,%eax
    3587:	29 f8                	sub    %edi,%eax
    3589:	8d 04 80             	lea    (%eax,%eax,4),%eax
    358c:	8d 04 80             	lea    (%eax,%eax,4),%eax
    358f:	c1 e0 02             	shl    $0x2,%eax
    3592:	89 d9                	mov    %ebx,%ecx
    3594:	29 c1                	sub    %eax,%ecx
    3596:	be 67 66 66 66       	mov    $0x66666667,%esi
    359b:	89 c8                	mov    %ecx,%eax
    359d:	f7 ee                	imul   %esi
    359f:	c1 fa 02             	sar    $0x2,%edx
    35a2:	c1 f9 1f             	sar    $0x1f,%ecx
    35a5:	29 ca                	sub    %ecx,%edx
    35a7:	83 c2 30             	add    $0x30,%edx
    35aa:	88 55 ab             	mov    %dl,-0x55(%ebp)
    name[4] = '0' + (nfiles % 10);
    35ad:	89 d8                	mov    %ebx,%eax
    35af:	f7 ee                	imul   %esi
    35b1:	c1 fa 02             	sar    $0x2,%edx
    35b4:	29 fa                	sub    %edi,%edx
    35b6:	8d 04 92             	lea    (%edx,%edx,4),%eax
    35b9:	d1 e0                	shl    %eax
    35bb:	89 da                	mov    %ebx,%edx
    35bd:	29 c2                	sub    %eax,%edx
    35bf:	89 d0                	mov    %edx,%eax
    35c1:	83 c0 30             	add    $0x30,%eax
    35c4:	88 45 ac             	mov    %al,-0x54(%ebp)
    name[5] = '\0';
    35c7:	c6 45 ad 00          	movb   $0x0,-0x53(%ebp)
    printf(1, "writing %s\n", name);
    35cb:	8d 45 a8             	lea    -0x58(%ebp),%eax
    35ce:	89 44 24 08          	mov    %eax,0x8(%esp)
    35d2:	c7 44 24 04 64 4d 00 	movl   $0x4d64,0x4(%esp)
    35d9:	00 
    35da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    35e1:	e8 7a 05 00 00       	call   3b60 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    35e6:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    35ed:	00 
    35ee:	8d 55 a8             	lea    -0x58(%ebp),%edx
    35f1:	89 14 24             	mov    %edx,(%esp)
    35f4:	e8 77 04 00 00       	call   3a70 <open>
    35f9:	89 c7                	mov    %eax,%edi
    if(fd < 0){
    35fb:	85 c0                	test   %eax,%eax
    35fd:	78 50                	js     364f <fsfull+0x147>
    35ff:	31 f6                	xor    %esi,%esi
    3601:	eb 03                	jmp    3606 <fsfull+0xfe>
    3603:	90                   	nop
    int total = 0;
    while(1){
      int cc = write(fd, buf, 512);
      if(cc < 512)
        break;
      total += cc;
    3604:	01 c6                	add    %eax,%esi
      printf(1, "open %s failed\n", name);
      break;
    }
    int total = 0;
    while(1){
      int cc = write(fd, buf, 512);
    3606:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    360d:	00 
    360e:	c7 44 24 04 80 86 00 	movl   $0x8680,0x4(%esp)
    3615:	00 
    3616:	89 3c 24             	mov    %edi,(%esp)
    3619:	e8 32 04 00 00       	call   3a50 <write>
      if(cc < 512)
    361e:	3d ff 01 00 00       	cmp    $0x1ff,%eax
    3623:	7f df                	jg     3604 <fsfull+0xfc>
        break;
      total += cc;
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    3625:	89 74 24 08          	mov    %esi,0x8(%esp)
    3629:	c7 44 24 04 80 4d 00 	movl   $0x4d80,0x4(%esp)
    3630:	00 
    3631:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3638:	e8 23 05 00 00       	call   3b60 <printf>
    close(fd);
    363d:	89 3c 24             	mov    %edi,(%esp)
    3640:	e8 13 04 00 00       	call   3a58 <close>
    if(total == 0)
    3645:	85 f6                	test   %esi,%esi
    3647:	74 23                	je     366c <fsfull+0x164>
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");

  for(nfiles = 0; ; nfiles++){
    3649:	43                   	inc    %ebx
    }
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
  }
    364a:	e9 d9 fe ff ff       	jmp    3528 <fsfull+0x20>
    name[4] = '0' + (nfiles % 10);
    name[5] = '\0';
    printf(1, "writing %s\n", name);
    int fd = open(name, O_CREATE|O_RDWR);
    if(fd < 0){
      printf(1, "open %s failed\n", name);
    364f:	8d 45 a8             	lea    -0x58(%ebp),%eax
    3652:	89 44 24 08          	mov    %eax,0x8(%esp)
    3656:	c7 44 24 04 70 4d 00 	movl   $0x4d70,0x4(%esp)
    365d:	00 
    365e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3665:	e8 f6 04 00 00       	call   3b60 <printf>
    366a:	66 90                	xchg   %ax,%ax
      break;
  }

  while(nfiles >= 0){
    char name[64];
    name[0] = 'f';
    366c:	c6 45 a8 66          	movb   $0x66,-0x58(%ebp)
    name[1] = '0' + nfiles / 1000;
    3670:	b8 d3 4d 62 10       	mov    $0x10624dd3,%eax
    3675:	f7 eb                	imul   %ebx
    3677:	89 55 a4             	mov    %edx,-0x5c(%ebp)
    367a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
    367d:	c1 f8 06             	sar    $0x6,%eax
    3680:	89 df                	mov    %ebx,%edi
    3682:	c1 ff 1f             	sar    $0x1f,%edi
    3685:	29 f8                	sub    %edi,%eax
    3687:	8d 50 30             	lea    0x30(%eax),%edx
    368a:	88 55 a9             	mov    %dl,-0x57(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    368d:	8d 04 80             	lea    (%eax,%eax,4),%eax
    3690:	8d 04 80             	lea    (%eax,%eax,4),%eax
    3693:	8d 04 80             	lea    (%eax,%eax,4),%eax
    3696:	c1 e0 03             	shl    $0x3,%eax
    3699:	89 d9                	mov    %ebx,%ecx
    369b:	29 c1                	sub    %eax,%ecx
    369d:	b8 1f 85 eb 51       	mov    $0x51eb851f,%eax
    36a2:	f7 e9                	imul   %ecx
    36a4:	89 55 a4             	mov    %edx,-0x5c(%ebp)
    36a7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
    36aa:	c1 f8 05             	sar    $0x5,%eax
    36ad:	c1 f9 1f             	sar    $0x1f,%ecx
    36b0:	29 c8                	sub    %ecx,%eax
    36b2:	83 c0 30             	add    $0x30,%eax
    36b5:	88 45 aa             	mov    %al,-0x56(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    36b8:	b8 1f 85 eb 51       	mov    $0x51eb851f,%eax
    36bd:	f7 eb                	imul   %ebx
    36bf:	89 45 a0             	mov    %eax,-0x60(%ebp)
    36c2:	89 55 a4             	mov    %edx,-0x5c(%ebp)
    36c5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
    36c8:	c1 f8 05             	sar    $0x5,%eax
    36cb:	29 f8                	sub    %edi,%eax
    36cd:	8d 04 80             	lea    (%eax,%eax,4),%eax
    36d0:	8d 04 80             	lea    (%eax,%eax,4),%eax
    36d3:	c1 e0 02             	shl    $0x2,%eax
    36d6:	89 d9                	mov    %ebx,%ecx
    36d8:	29 c1                	sub    %eax,%ecx
    36da:	be 67 66 66 66       	mov    $0x66666667,%esi
    36df:	89 c8                	mov    %ecx,%eax
    36e1:	f7 ee                	imul   %esi
    36e3:	c1 fa 02             	sar    $0x2,%edx
    36e6:	c1 f9 1f             	sar    $0x1f,%ecx
    36e9:	29 ca                	sub    %ecx,%edx
    36eb:	83 c2 30             	add    $0x30,%edx
    36ee:	88 55 ab             	mov    %dl,-0x55(%ebp)
    name[4] = '0' + (nfiles % 10);
    36f1:	89 d8                	mov    %ebx,%eax
    36f3:	f7 ee                	imul   %esi
    36f5:	c1 fa 02             	sar    $0x2,%edx
    36f8:	29 fa                	sub    %edi,%edx
    36fa:	8d 04 92             	lea    (%edx,%edx,4),%eax
    36fd:	d1 e0                	shl    %eax
    36ff:	89 da                	mov    %ebx,%edx
    3701:	29 c2                	sub    %eax,%edx
    3703:	89 d0                	mov    %edx,%eax
    3705:	83 c0 30             	add    $0x30,%eax
    3708:	88 45 ac             	mov    %al,-0x54(%ebp)
    name[5] = '\0';
    370b:	c6 45 ad 00          	movb   $0x0,-0x53(%ebp)
    unlink(name);
    370f:	8d 45 a8             	lea    -0x58(%ebp),%eax
    3712:	89 04 24             	mov    %eax,(%esp)
    3715:	e8 66 03 00 00       	call   3a80 <unlink>
    nfiles--;
    371a:	4b                   	dec    %ebx
    close(fd);
    if(total == 0)
      break;
  }

  while(nfiles >= 0){
    371b:	83 fb ff             	cmp    $0xffffffff,%ebx
    371e:	0f 85 48 ff ff ff    	jne    366c <fsfull+0x164>
    name[5] = '\0';
    unlink(name);
    nfiles--;
  }

  printf(1, "fsfull test finished\n");
    3724:	c7 44 24 04 90 4d 00 	movl   $0x4d90,0x4(%esp)
    372b:	00 
    372c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3733:	e8 28 04 00 00       	call   3b60 <printf>
}
    3738:	83 c4 6c             	add    $0x6c,%esp
    373b:	5b                   	pop    %ebx
    373c:	5e                   	pop    %esi
    373d:	5f                   	pop    %edi
    373e:	5d                   	pop    %ebp
    373f:	c3                   	ret    

00003740 <uio>:

void
uio()
{
    3740:	55                   	push   %ebp
    3741:	89 e5                	mov    %esp,%ebp
    3743:	83 ec 18             	sub    $0x18,%esp

  ushort port = 0;
  uchar val = 0;
  int pid;

  printf(1, "uio test\n");
    3746:	c7 44 24 04 a6 4d 00 	movl   $0x4da6,0x4(%esp)
    374d:	00 
    374e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3755:	e8 06 04 00 00       	call   3b60 <printf>
  pid = fork();
    375a:	e8 c9 02 00 00       	call   3a28 <fork>
  if(pid == 0){
    375f:	83 f8 00             	cmp    $0x0,%eax
    3762:	74 1d                	je     3781 <uio+0x41>
    asm volatile("outb %0,%1"::"a"(val), "d" (port));
    port = RTC_DATA;
    asm volatile("inb %1,%0" : "=a" (val) : "d" (port));
    printf(1, "uio: uio succeeded; test FAILED\n");
    exit();
  } else if(pid < 0){
    3764:	7c 3f                	jl     37a5 <uio+0x65>
    printf (1, "fork failed\n");
    exit();
  }
  wait();
    3766:	e8 cd 02 00 00       	call   3a38 <wait>
  printf(1, "uio test done\n");
    376b:	c7 44 24 04 b0 4d 00 	movl   $0x4db0,0x4(%esp)
    3772:	00 
    3773:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    377a:	e8 e1 03 00 00       	call   3b60 <printf>
}
    377f:	c9                   	leave  
    3780:	c3                   	ret    
  pid = fork();
  if(pid == 0){
    port = RTC_ADDR;
    val = 0x09;  /* year */
    /* http://wiki.osdev.org/Inline_Assembly/Examples */
    asm volatile("outb %0,%1"::"a"(val), "d" (port));
    3781:	ba 70 00 00 00       	mov    $0x70,%edx
    3786:	b0 09                	mov    $0x9,%al
    3788:	ee                   	out    %al,(%dx)
    port = RTC_DATA;
    asm volatile("inb %1,%0" : "=a" (val) : "d" (port));
    3789:	b2 71                	mov    $0x71,%dl
    378b:	ec                   	in     (%dx),%al
    printf(1, "uio: uio succeeded; test FAILED\n");
    378c:	c7 44 24 04 3c 55 00 	movl   $0x553c,0x4(%esp)
    3793:	00 
    3794:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    379b:	e8 c0 03 00 00       	call   3b60 <printf>
    exit();
    37a0:	e8 8b 02 00 00       	call   3a30 <exit>
  } else if(pid < 0){
    printf (1, "fork failed\n");
    37a5:	c7 44 24 04 35 4d 00 	movl   $0x4d35,0x4(%esp)
    37ac:	00 
    37ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    37b4:	e8 a7 03 00 00       	call   3b60 <printf>
    exit();
    37b9:	e8 72 02 00 00       	call   3a30 <exit>
    37be:	66 90                	xchg   %ax,%ax

000037c0 <argptest>:
  wait();
  printf(1, "uio test done\n");
}

void argptest()
{
    37c0:	55                   	push   %ebp
    37c1:	89 e5                	mov    %esp,%ebp
    37c3:	53                   	push   %ebx
    37c4:	83 ec 14             	sub    $0x14,%esp
  int fd;
  fd = open("init", O_RDONLY);
    37c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    37ce:	00 
    37cf:	c7 04 24 bf 4d 00 00 	movl   $0x4dbf,(%esp)
    37d6:	e8 95 02 00 00       	call   3a70 <open>
    37db:	89 c3                	mov    %eax,%ebx
  if (fd < 0) {
    37dd:	85 c0                	test   %eax,%eax
    37df:	78 43                	js     3824 <argptest+0x64>
    printf(2, "open failed\n");
    exit();
  }
  read(fd, sbrk(0) - 1, -1);
    37e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    37e8:	e8 cb 02 00 00       	call   3ab8 <sbrk>
    37ed:	c7 44 24 08 ff ff ff 	movl   $0xffffffff,0x8(%esp)
    37f4:	ff 
    37f5:	48                   	dec    %eax
    37f6:	89 44 24 04          	mov    %eax,0x4(%esp)
    37fa:	89 1c 24             	mov    %ebx,(%esp)
    37fd:	e8 46 02 00 00       	call   3a48 <read>
  close(fd);
    3802:	89 1c 24             	mov    %ebx,(%esp)
    3805:	e8 4e 02 00 00       	call   3a58 <close>
  printf(1, "arg test passed\n");
    380a:	c7 44 24 04 d1 4d 00 	movl   $0x4dd1,0x4(%esp)
    3811:	00 
    3812:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3819:	e8 42 03 00 00       	call   3b60 <printf>
}
    381e:	83 c4 14             	add    $0x14,%esp
    3821:	5b                   	pop    %ebx
    3822:	5d                   	pop    %ebp
    3823:	c3                   	ret    
void argptest()
{
  int fd;
  fd = open("init", O_RDONLY);
  if (fd < 0) {
    printf(2, "open failed\n");
    3824:	c7 44 24 04 c4 4d 00 	movl   $0x4dc4,0x4(%esp)
    382b:	00 
    382c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3833:	e8 28 03 00 00       	call   3b60 <printf>
    exit();
    3838:	e8 f3 01 00 00       	call   3a30 <exit>
    383d:	8d 76 00             	lea    0x0(%esi),%esi

00003840 <rand>:
}

unsigned long randstate = 1;
unsigned int
rand()
{
    3840:	55                   	push   %ebp
    3841:	89 e5                	mov    %esp,%ebp
  randstate = randstate * 1664525 + 1013904223;
    3843:	a1 a0 5e 00 00       	mov    0x5ea0,%eax
    3848:	8d 14 40             	lea    (%eax,%eax,2),%edx
    384b:	8d 14 90             	lea    (%eax,%edx,4),%edx
    384e:	c1 e2 08             	shl    $0x8,%edx
    3851:	01 c2                	add    %eax,%edx
    3853:	8d 14 92             	lea    (%edx,%edx,4),%edx
    3856:	8d 04 90             	lea    (%eax,%edx,4),%eax
    3859:	8d 04 80             	lea    (%eax,%eax,4),%eax
    385c:	8d 84 80 5f f3 6e 3c 	lea    0x3c6ef35f(%eax,%eax,4),%eax
    3863:	a3 a0 5e 00 00       	mov    %eax,0x5ea0
  return randstate;
}
    3868:	5d                   	pop    %ebp
    3869:	c3                   	ret    
    386a:	90                   	nop
    386b:	90                   	nop

0000386c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
    386c:	55                   	push   %ebp
    386d:	89 e5                	mov    %esp,%ebp
    386f:	53                   	push   %ebx
    3870:	8b 45 08             	mov    0x8(%ebp),%eax
    3873:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    3876:	31 d2                	xor    %edx,%edx
    3878:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
    387b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    387e:	42                   	inc    %edx
    387f:	84 c9                	test   %cl,%cl
    3881:	75 f5                	jne    3878 <strcpy+0xc>
    ;
  return os;
}
    3883:	5b                   	pop    %ebx
    3884:	5d                   	pop    %ebp
    3885:	c3                   	ret    
    3886:	66 90                	xchg   %ax,%ax

00003888 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    3888:	55                   	push   %ebp
    3889:	89 e5                	mov    %esp,%ebp
    388b:	56                   	push   %esi
    388c:	53                   	push   %ebx
    388d:	8b 4d 08             	mov    0x8(%ebp),%ecx
    3890:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
    3893:	8a 01                	mov    (%ecx),%al
    3895:	8a 1a                	mov    (%edx),%bl
    3897:	84 c0                	test   %al,%al
    3899:	74 1d                	je     38b8 <strcmp+0x30>
    389b:	38 d8                	cmp    %bl,%al
    389d:	74 0c                	je     38ab <strcmp+0x23>
    389f:	eb 23                	jmp    38c4 <strcmp+0x3c>
    38a1:	8d 76 00             	lea    0x0(%esi),%esi
    38a4:	41                   	inc    %ecx
    38a5:	38 d8                	cmp    %bl,%al
    38a7:	75 1b                	jne    38c4 <strcmp+0x3c>
    p++, q++;
    38a9:	89 f2                	mov    %esi,%edx
    38ab:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    38ae:	8a 41 01             	mov    0x1(%ecx),%al
    38b1:	8a 5a 01             	mov    0x1(%edx),%bl
    38b4:	84 c0                	test   %al,%al
    38b6:	75 ec                	jne    38a4 <strcmp+0x1c>
    38b8:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
    38ba:	0f b6 db             	movzbl %bl,%ebx
    38bd:	29 d8                	sub    %ebx,%eax
}
    38bf:	5b                   	pop    %ebx
    38c0:	5e                   	pop    %esi
    38c1:	5d                   	pop    %ebp
    38c2:	c3                   	ret    
    38c3:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    38c4:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
    38c7:	0f b6 db             	movzbl %bl,%ebx
    38ca:	29 d8                	sub    %ebx,%eax
}
    38cc:	5b                   	pop    %ebx
    38cd:	5e                   	pop    %esi
    38ce:	5d                   	pop    %ebp
    38cf:	c3                   	ret    

000038d0 <strlen>:

uint
strlen(const char *s)
{
    38d0:	55                   	push   %ebp
    38d1:	89 e5                	mov    %esp,%ebp
    38d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
    38d6:	80 39 00             	cmpb   $0x0,(%ecx)
    38d9:	74 10                	je     38eb <strlen+0x1b>
    38db:	31 d2                	xor    %edx,%edx
    38dd:	8d 76 00             	lea    0x0(%esi),%esi
    38e0:	42                   	inc    %edx
    38e1:	89 d0                	mov    %edx,%eax
    38e3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
    38e7:	75 f7                	jne    38e0 <strlen+0x10>
    ;
  return n;
}
    38e9:	5d                   	pop    %ebp
    38ea:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
    38eb:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
    38ed:	5d                   	pop    %ebp
    38ee:	c3                   	ret    
    38ef:	90                   	nop

000038f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
    38f0:	55                   	push   %ebp
    38f1:	89 e5                	mov    %esp,%ebp
    38f3:	57                   	push   %edi
    38f4:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
    38f7:	89 d7                	mov    %edx,%edi
    38f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
    38fc:	8b 45 0c             	mov    0xc(%ebp),%eax
    38ff:	fc                   	cld    
    3900:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
    3902:	89 d0                	mov    %edx,%eax
    3904:	5f                   	pop    %edi
    3905:	5d                   	pop    %ebp
    3906:	c3                   	ret    
    3907:	90                   	nop

00003908 <strchr>:

char*
strchr(const char *s, char c)
{
    3908:	55                   	push   %ebp
    3909:	89 e5                	mov    %esp,%ebp
    390b:	8b 45 08             	mov    0x8(%ebp),%eax
    390e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
    3911:	8a 10                	mov    (%eax),%dl
    3913:	84 d2                	test   %dl,%dl
    3915:	75 0d                	jne    3924 <strchr+0x1c>
    3917:	eb 13                	jmp    392c <strchr+0x24>
    3919:	8d 76 00             	lea    0x0(%esi),%esi
    391c:	8a 50 01             	mov    0x1(%eax),%dl
    391f:	84 d2                	test   %dl,%dl
    3921:	74 09                	je     392c <strchr+0x24>
    3923:	40                   	inc    %eax
    if(*s == c)
    3924:	38 ca                	cmp    %cl,%dl
    3926:	75 f4                	jne    391c <strchr+0x14>
      return (char*)s;
  return 0;
}
    3928:	5d                   	pop    %ebp
    3929:	c3                   	ret    
    392a:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
    392c:	31 c0                	xor    %eax,%eax
}
    392e:	5d                   	pop    %ebp
    392f:	c3                   	ret    

00003930 <gets>:

char*
gets(char *buf, int max)
{
    3930:	55                   	push   %ebp
    3931:	89 e5                	mov    %esp,%ebp
    3933:	57                   	push   %edi
    3934:	56                   	push   %esi
    3935:	53                   	push   %ebx
    3936:	83 ec 2c             	sub    $0x2c,%esp
    3939:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    393c:	31 f6                	xor    %esi,%esi
    393e:	eb 30                	jmp    3970 <gets+0x40>
    cc = read(0, &c, 1);
    3940:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3947:	00 
    3948:	8d 45 e7             	lea    -0x19(%ebp),%eax
    394b:	89 44 24 04          	mov    %eax,0x4(%esp)
    394f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3956:	e8 ed 00 00 00       	call   3a48 <read>
    if(cc < 1)
    395b:	85 c0                	test   %eax,%eax
    395d:	7e 19                	jle    3978 <gets+0x48>
      break;
    buf[i++] = c;
    395f:	8a 45 e7             	mov    -0x19(%ebp),%al
    3962:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3966:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    3968:	3c 0a                	cmp    $0xa,%al
    396a:	74 0c                	je     3978 <gets+0x48>
    396c:	3c 0d                	cmp    $0xd,%al
    396e:	74 08                	je     3978 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3970:	8d 5e 01             	lea    0x1(%esi),%ebx
    3973:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
    3976:	7c c8                	jl     3940 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    3978:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
    397c:	89 f8                	mov    %edi,%eax
    397e:	83 c4 2c             	add    $0x2c,%esp
    3981:	5b                   	pop    %ebx
    3982:	5e                   	pop    %esi
    3983:	5f                   	pop    %edi
    3984:	5d                   	pop    %ebp
    3985:	c3                   	ret    
    3986:	66 90                	xchg   %ax,%ax

00003988 <stat>:

int
stat(const char *n, struct stat *st)
{
    3988:	55                   	push   %ebp
    3989:	89 e5                	mov    %esp,%ebp
    398b:	56                   	push   %esi
    398c:	53                   	push   %ebx
    398d:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    3990:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3997:	00 
    3998:	8b 45 08             	mov    0x8(%ebp),%eax
    399b:	89 04 24             	mov    %eax,(%esp)
    399e:	e8 cd 00 00 00       	call   3a70 <open>
    39a3:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
    39a5:	85 c0                	test   %eax,%eax
    39a7:	78 23                	js     39cc <stat+0x44>
    return -1;
  r = fstat(fd, st);
    39a9:	8b 45 0c             	mov    0xc(%ebp),%eax
    39ac:	89 44 24 04          	mov    %eax,0x4(%esp)
    39b0:	89 1c 24             	mov    %ebx,(%esp)
    39b3:	e8 d0 00 00 00       	call   3a88 <fstat>
    39b8:	89 c6                	mov    %eax,%esi
  close(fd);
    39ba:	89 1c 24             	mov    %ebx,(%esp)
    39bd:	e8 96 00 00 00       	call   3a58 <close>
  return r;
}
    39c2:	89 f0                	mov    %esi,%eax
    39c4:	83 c4 10             	add    $0x10,%esp
    39c7:	5b                   	pop    %ebx
    39c8:	5e                   	pop    %esi
    39c9:	5d                   	pop    %ebp
    39ca:	c3                   	ret    
    39cb:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
    39cc:	be ff ff ff ff       	mov    $0xffffffff,%esi
    39d1:	eb ef                	jmp    39c2 <stat+0x3a>
    39d3:	90                   	nop

000039d4 <atoi>:
  return r;
}

int
atoi(const char *s)
{
    39d4:	55                   	push   %ebp
    39d5:	89 e5                	mov    %esp,%ebp
    39d7:	53                   	push   %ebx
    39d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    39db:	8a 11                	mov    (%ecx),%dl
    39dd:	8d 42 d0             	lea    -0x30(%edx),%eax
    39e0:	3c 09                	cmp    $0x9,%al
    39e2:	b8 00 00 00 00       	mov    $0x0,%eax
    39e7:	77 18                	ja     3a01 <atoi+0x2d>
    39e9:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
    39ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
    39ef:	0f be d2             	movsbl %dl,%edx
    39f2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
    39f6:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    39f7:	8a 11                	mov    (%ecx),%dl
    39f9:	8d 5a d0             	lea    -0x30(%edx),%ebx
    39fc:	80 fb 09             	cmp    $0x9,%bl
    39ff:	76 eb                	jbe    39ec <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
    3a01:	5b                   	pop    %ebx
    3a02:	5d                   	pop    %ebp
    3a03:	c3                   	ret    

00003a04 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    3a04:	55                   	push   %ebp
    3a05:	89 e5                	mov    %esp,%ebp
    3a07:	56                   	push   %esi
    3a08:	53                   	push   %ebx
    3a09:	8b 45 08             	mov    0x8(%ebp),%eax
    3a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
    3a0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    3a12:	85 db                	test   %ebx,%ebx
    3a14:	7e 0d                	jle    3a23 <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
    3a16:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
    3a18:	8a 0c 16             	mov    (%esi,%edx,1),%cl
    3a1b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    3a1e:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    3a1f:	39 da                	cmp    %ebx,%edx
    3a21:	75 f5                	jne    3a18 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
    3a23:	5b                   	pop    %ebx
    3a24:	5e                   	pop    %esi
    3a25:	5d                   	pop    %ebp
    3a26:	c3                   	ret    
    3a27:	90                   	nop

00003a28 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    3a28:	b8 01 00 00 00       	mov    $0x1,%eax
    3a2d:	cd 40                	int    $0x40
    3a2f:	c3                   	ret    

00003a30 <exit>:
SYSCALL(exit)
    3a30:	b8 02 00 00 00       	mov    $0x2,%eax
    3a35:	cd 40                	int    $0x40
    3a37:	c3                   	ret    

00003a38 <wait>:
SYSCALL(wait)
    3a38:	b8 03 00 00 00       	mov    $0x3,%eax
    3a3d:	cd 40                	int    $0x40
    3a3f:	c3                   	ret    

00003a40 <pipe>:
SYSCALL(pipe)
    3a40:	b8 04 00 00 00       	mov    $0x4,%eax
    3a45:	cd 40                	int    $0x40
    3a47:	c3                   	ret    

00003a48 <read>:
SYSCALL(read)
    3a48:	b8 05 00 00 00       	mov    $0x5,%eax
    3a4d:	cd 40                	int    $0x40
    3a4f:	c3                   	ret    

00003a50 <write>:
SYSCALL(write)
    3a50:	b8 10 00 00 00       	mov    $0x10,%eax
    3a55:	cd 40                	int    $0x40
    3a57:	c3                   	ret    

00003a58 <close>:
SYSCALL(close)
    3a58:	b8 15 00 00 00       	mov    $0x15,%eax
    3a5d:	cd 40                	int    $0x40
    3a5f:	c3                   	ret    

00003a60 <kill>:
SYSCALL(kill)
    3a60:	b8 06 00 00 00       	mov    $0x6,%eax
    3a65:	cd 40                	int    $0x40
    3a67:	c3                   	ret    

00003a68 <exec>:
SYSCALL(exec)
    3a68:	b8 07 00 00 00       	mov    $0x7,%eax
    3a6d:	cd 40                	int    $0x40
    3a6f:	c3                   	ret    

00003a70 <open>:
SYSCALL(open)
    3a70:	b8 0f 00 00 00       	mov    $0xf,%eax
    3a75:	cd 40                	int    $0x40
    3a77:	c3                   	ret    

00003a78 <mknod>:
SYSCALL(mknod)
    3a78:	b8 11 00 00 00       	mov    $0x11,%eax
    3a7d:	cd 40                	int    $0x40
    3a7f:	c3                   	ret    

00003a80 <unlink>:
SYSCALL(unlink)
    3a80:	b8 12 00 00 00       	mov    $0x12,%eax
    3a85:	cd 40                	int    $0x40
    3a87:	c3                   	ret    

00003a88 <fstat>:
SYSCALL(fstat)
    3a88:	b8 08 00 00 00       	mov    $0x8,%eax
    3a8d:	cd 40                	int    $0x40
    3a8f:	c3                   	ret    

00003a90 <link>:
SYSCALL(link)
    3a90:	b8 13 00 00 00       	mov    $0x13,%eax
    3a95:	cd 40                	int    $0x40
    3a97:	c3                   	ret    

00003a98 <mkdir>:
SYSCALL(mkdir)
    3a98:	b8 14 00 00 00       	mov    $0x14,%eax
    3a9d:	cd 40                	int    $0x40
    3a9f:	c3                   	ret    

00003aa0 <chdir>:
SYSCALL(chdir)
    3aa0:	b8 09 00 00 00       	mov    $0x9,%eax
    3aa5:	cd 40                	int    $0x40
    3aa7:	c3                   	ret    

00003aa8 <dup>:
SYSCALL(dup)
    3aa8:	b8 0a 00 00 00       	mov    $0xa,%eax
    3aad:	cd 40                	int    $0x40
    3aaf:	c3                   	ret    

00003ab0 <getpid>:
SYSCALL(getpid)
    3ab0:	b8 0b 00 00 00       	mov    $0xb,%eax
    3ab5:	cd 40                	int    $0x40
    3ab7:	c3                   	ret    

00003ab8 <sbrk>:
SYSCALL(sbrk)
    3ab8:	b8 0c 00 00 00       	mov    $0xc,%eax
    3abd:	cd 40                	int    $0x40
    3abf:	c3                   	ret    

00003ac0 <sleep>:
SYSCALL(sleep)
    3ac0:	b8 0d 00 00 00       	mov    $0xd,%eax
    3ac5:	cd 40                	int    $0x40
    3ac7:	c3                   	ret    

00003ac8 <uptime>:
SYSCALL(uptime)
    3ac8:	b8 0e 00 00 00       	mov    $0xe,%eax
    3acd:	cd 40                	int    $0x40
    3acf:	c3                   	ret    

00003ad0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    3ad0:	55                   	push   %ebp
    3ad1:	89 e5                	mov    %esp,%ebp
    3ad3:	83 ec 28             	sub    $0x28,%esp
    3ad6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
    3ad9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3ae0:	00 
    3ae1:	8d 55 f4             	lea    -0xc(%ebp),%edx
    3ae4:	89 54 24 04          	mov    %edx,0x4(%esp)
    3ae8:	89 04 24             	mov    %eax,(%esp)
    3aeb:	e8 60 ff ff ff       	call   3a50 <write>
}
    3af0:	c9                   	leave  
    3af1:	c3                   	ret    
    3af2:	66 90                	xchg   %ax,%ax

00003af4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    3af4:	55                   	push   %ebp
    3af5:	89 e5                	mov    %esp,%ebp
    3af7:	57                   	push   %edi
    3af8:	56                   	push   %esi
    3af9:	53                   	push   %ebx
    3afa:	83 ec 1c             	sub    $0x1c,%esp
    3afd:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
    3aff:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    3b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
    3b04:	85 db                	test   %ebx,%ebx
    3b06:	74 04                	je     3b0c <printint+0x18>
    3b08:	85 d2                	test   %edx,%edx
    3b0a:	78 4a                	js     3b56 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    3b0c:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    3b0e:	31 db                	xor    %ebx,%ebx
    3b10:	eb 04                	jmp    3b16 <printint+0x22>
    3b12:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
    3b14:	89 d3                	mov    %edx,%ebx
    3b16:	31 d2                	xor    %edx,%edx
    3b18:	f7 f1                	div    %ecx
    3b1a:	8a 92 a3 55 00 00    	mov    0x55a3(%edx),%dl
    3b20:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
    3b24:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
    3b27:	85 c0                	test   %eax,%eax
    3b29:	75 e9                	jne    3b14 <printint+0x20>
  if(neg)
    3b2b:	85 ff                	test   %edi,%edi
    3b2d:	74 08                	je     3b37 <printint+0x43>
    buf[i++] = '-';
    3b2f:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
    3b34:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
    3b37:	8d 5a ff             	lea    -0x1(%edx),%ebx
    3b3a:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
    3b3c:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
    3b41:	89 f0                	mov    %esi,%eax
    3b43:	e8 88 ff ff ff       	call   3ad0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    3b48:	4b                   	dec    %ebx
    3b49:	83 fb ff             	cmp    $0xffffffff,%ebx
    3b4c:	75 ee                	jne    3b3c <printint+0x48>
    putc(fd, buf[i]);
}
    3b4e:	83 c4 1c             	add    $0x1c,%esp
    3b51:	5b                   	pop    %ebx
    3b52:	5e                   	pop    %esi
    3b53:	5f                   	pop    %edi
    3b54:	5d                   	pop    %ebp
    3b55:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
    3b56:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    3b58:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
    3b5d:	eb af                	jmp    3b0e <printint+0x1a>
    3b5f:	90                   	nop

00003b60 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
    3b60:	55                   	push   %ebp
    3b61:	89 e5                	mov    %esp,%ebp
    3b63:	57                   	push   %edi
    3b64:	56                   	push   %esi
    3b65:	53                   	push   %ebx
    3b66:	83 ec 2c             	sub    $0x2c,%esp
    3b69:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    3b6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    3b6f:	8a 0b                	mov    (%ebx),%cl
    3b71:	84 c9                	test   %cl,%cl
    3b73:	74 7b                	je     3bf0 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
    3b75:	8d 45 10             	lea    0x10(%ebp),%eax
    3b78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    3b7b:	31 f6                	xor    %esi,%esi
    3b7d:	eb 17                	jmp    3b96 <printf+0x36>
    3b7f:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
    3b80:	83 f9 25             	cmp    $0x25,%ecx
    3b83:	74 73                	je     3bf8 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
    3b85:	0f be d1             	movsbl %cl,%edx
    3b88:	89 f8                	mov    %edi,%eax
    3b8a:	e8 41 ff ff ff       	call   3ad0 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
    3b8f:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    3b90:	8a 0b                	mov    (%ebx),%cl
    3b92:	84 c9                	test   %cl,%cl
    3b94:	74 5a                	je     3bf0 <printf+0x90>
    c = fmt[i] & 0xff;
    3b96:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
    3b99:	85 f6                	test   %esi,%esi
    3b9b:	74 e3                	je     3b80 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    3b9d:	83 fe 25             	cmp    $0x25,%esi
    3ba0:	75 ed                	jne    3b8f <printf+0x2f>
      if(c == 'd'){
    3ba2:	83 f9 64             	cmp    $0x64,%ecx
    3ba5:	0f 84 c1 00 00 00    	je     3c6c <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
    3bab:	83 f9 78             	cmp    $0x78,%ecx
    3bae:	74 50                	je     3c00 <printf+0xa0>
    3bb0:	83 f9 70             	cmp    $0x70,%ecx
    3bb3:	74 4b                	je     3c00 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
    3bb5:	83 f9 73             	cmp    $0x73,%ecx
    3bb8:	74 6a                	je     3c24 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    3bba:	83 f9 63             	cmp    $0x63,%ecx
    3bbd:	0f 84 91 00 00 00    	je     3c54 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
    3bc3:	ba 25 00 00 00       	mov    $0x25,%edx
    3bc8:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
    3bca:	83 f9 25             	cmp    $0x25,%ecx
    3bcd:	74 10                	je     3bdf <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    3bcf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
    3bd2:	e8 f9 fe ff ff       	call   3ad0 <putc>
        putc(fd, c);
    3bd7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
    3bda:	0f be d1             	movsbl %cl,%edx
    3bdd:	89 f8                	mov    %edi,%eax
    3bdf:	e8 ec fe ff ff       	call   3ad0 <putc>
      }
      state = 0;
    3be4:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
    3be6:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    3be7:	8a 0b                	mov    (%ebx),%cl
    3be9:	84 c9                	test   %cl,%cl
    3beb:	75 a9                	jne    3b96 <printf+0x36>
    3bed:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    3bf0:	83 c4 2c             	add    $0x2c,%esp
    3bf3:	5b                   	pop    %ebx
    3bf4:	5e                   	pop    %esi
    3bf5:	5f                   	pop    %edi
    3bf6:	5d                   	pop    %ebp
    3bf7:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
    3bf8:	be 25 00 00 00       	mov    $0x25,%esi
    3bfd:	eb 90                	jmp    3b8f <printf+0x2f>
    3bff:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
    3c00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3c07:	b9 10 00 00 00       	mov    $0x10,%ecx
    3c0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3c0f:	8b 10                	mov    (%eax),%edx
    3c11:	89 f8                	mov    %edi,%eax
    3c13:	e8 dc fe ff ff       	call   3af4 <printint>
        ap++;
    3c18:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    3c1c:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
    3c1e:	e9 6c ff ff ff       	jmp    3b8f <printf+0x2f>
    3c23:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
    3c24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3c27:	8b 30                	mov    (%eax),%esi
        ap++;
    3c29:	83 c0 04             	add    $0x4,%eax
    3c2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
    3c2f:	85 f6                	test   %esi,%esi
    3c31:	74 5a                	je     3c8d <printf+0x12d>
          s = "(null)";
        while(*s != 0){
    3c33:	8a 16                	mov    (%esi),%dl
    3c35:	84 d2                	test   %dl,%dl
    3c37:	74 14                	je     3c4d <printf+0xed>
    3c39:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
    3c3c:	0f be d2             	movsbl %dl,%edx
    3c3f:	89 f8                	mov    %edi,%eax
    3c41:	e8 8a fe ff ff       	call   3ad0 <putc>
          s++;
    3c46:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    3c47:	8a 16                	mov    (%esi),%dl
    3c49:	84 d2                	test   %dl,%dl
    3c4b:	75 ef                	jne    3c3c <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    3c4d:	31 f6                	xor    %esi,%esi
    3c4f:	e9 3b ff ff ff       	jmp    3b8f <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
    3c54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3c57:	0f be 10             	movsbl (%eax),%edx
    3c5a:	89 f8                	mov    %edi,%eax
    3c5c:	e8 6f fe ff ff       	call   3ad0 <putc>
        ap++;
    3c61:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    3c65:	31 f6                	xor    %esi,%esi
    3c67:	e9 23 ff ff ff       	jmp    3b8f <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
    3c6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3c73:	b1 0a                	mov    $0xa,%cl
    3c75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3c78:	8b 10                	mov    (%eax),%edx
    3c7a:	89 f8                	mov    %edi,%eax
    3c7c:	e8 73 fe ff ff       	call   3af4 <printint>
        ap++;
    3c81:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    3c85:	66 31 f6             	xor    %si,%si
    3c88:	e9 02 ff ff ff       	jmp    3b8f <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
    3c8d:	be 9c 55 00 00       	mov    $0x559c,%esi
    3c92:	eb 9f                	jmp    3c33 <printf+0xd3>

00003c94 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    3c94:	55                   	push   %ebp
    3c95:	89 e5                	mov    %esp,%ebp
    3c97:	57                   	push   %edi
    3c98:	56                   	push   %esi
    3c99:	53                   	push   %ebx
    3c9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
    3c9d:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    3ca0:	a1 40 5f 00 00       	mov    0x5f40,%eax
    3ca5:	8d 76 00             	lea    0x0(%esi),%esi
    3ca8:	8b 10                	mov    (%eax),%edx
    3caa:	39 c8                	cmp    %ecx,%eax
    3cac:	73 04                	jae    3cb2 <free+0x1e>
    3cae:	39 d1                	cmp    %edx,%ecx
    3cb0:	72 12                	jb     3cc4 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    3cb2:	39 d0                	cmp    %edx,%eax
    3cb4:	72 08                	jb     3cbe <free+0x2a>
    3cb6:	39 c8                	cmp    %ecx,%eax
    3cb8:	72 0a                	jb     3cc4 <free+0x30>
    3cba:	39 d1                	cmp    %edx,%ecx
    3cbc:	72 06                	jb     3cc4 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
    3cbe:	89 d0                	mov    %edx,%eax
    3cc0:	eb e6                	jmp    3ca8 <free+0x14>
    3cc2:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    3cc4:	8b 73 fc             	mov    -0x4(%ebx),%esi
    3cc7:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
    3cca:	39 d7                	cmp    %edx,%edi
    3ccc:	74 19                	je     3ce7 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
    3cce:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
    3cd1:	8b 50 04             	mov    0x4(%eax),%edx
    3cd4:	8d 34 d0             	lea    (%eax,%edx,8),%esi
    3cd7:	39 f1                	cmp    %esi,%ecx
    3cd9:	74 23                	je     3cfe <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
    3cdb:	89 08                	mov    %ecx,(%eax)
  freep = p;
    3cdd:	a3 40 5f 00 00       	mov    %eax,0x5f40
}
    3ce2:	5b                   	pop    %ebx
    3ce3:	5e                   	pop    %esi
    3ce4:	5f                   	pop    %edi
    3ce5:	5d                   	pop    %ebp
    3ce6:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    3ce7:	03 72 04             	add    0x4(%edx),%esi
    3cea:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
    3ced:	8b 10                	mov    (%eax),%edx
    3cef:	8b 12                	mov    (%edx),%edx
    3cf1:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    3cf4:	8b 50 04             	mov    0x4(%eax),%edx
    3cf7:	8d 34 d0             	lea    (%eax,%edx,8),%esi
    3cfa:	39 f1                	cmp    %esi,%ecx
    3cfc:	75 dd                	jne    3cdb <free+0x47>
    p->s.size += bp->s.size;
    3cfe:	03 53 fc             	add    -0x4(%ebx),%edx
    3d01:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    3d04:	8b 53 f8             	mov    -0x8(%ebx),%edx
    3d07:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
    3d09:	a3 40 5f 00 00       	mov    %eax,0x5f40
}
    3d0e:	5b                   	pop    %ebx
    3d0f:	5e                   	pop    %esi
    3d10:	5f                   	pop    %edi
    3d11:	5d                   	pop    %ebp
    3d12:	c3                   	ret    
    3d13:	90                   	nop

00003d14 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    3d14:	55                   	push   %ebp
    3d15:	89 e5                	mov    %esp,%ebp
    3d17:	57                   	push   %edi
    3d18:	56                   	push   %esi
    3d19:	53                   	push   %ebx
    3d1a:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    3d1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
    3d20:	83 c3 07             	add    $0x7,%ebx
    3d23:	c1 eb 03             	shr    $0x3,%ebx
    3d26:	43                   	inc    %ebx
  if((prevp = freep) == 0){
    3d27:	8b 0d 40 5f 00 00    	mov    0x5f40,%ecx
    3d2d:	85 c9                	test   %ecx,%ecx
    3d2f:	0f 84 95 00 00 00    	je     3dca <malloc+0xb6>
    3d35:	8b 01                	mov    (%ecx),%eax
    3d37:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
    3d3a:	39 da                	cmp    %ebx,%edx
    3d3c:	73 66                	jae    3da4 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    3d3e:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
    3d45:	eb 0c                	jmp    3d53 <malloc+0x3f>
    3d47:	90                   	nop
    }
    if(p == freep)
    3d48:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    3d4a:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
    3d4c:	8b 50 04             	mov    0x4(%eax),%edx
    3d4f:	39 d3                	cmp    %edx,%ebx
    3d51:	76 51                	jbe    3da4 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    3d53:	3b 05 40 5f 00 00    	cmp    0x5f40,%eax
    3d59:	75 ed                	jne    3d48 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
    3d5b:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
    3d61:	76 35                	jbe    3d98 <malloc+0x84>
    3d63:	89 f8                	mov    %edi,%eax
    3d65:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
    3d67:	89 04 24             	mov    %eax,(%esp)
    3d6a:	e8 49 fd ff ff       	call   3ab8 <sbrk>
  if(p == (char*)-1)
    3d6f:	83 f8 ff             	cmp    $0xffffffff,%eax
    3d72:	74 18                	je     3d8c <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
    3d74:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
    3d77:	83 c0 08             	add    $0x8,%eax
    3d7a:	89 04 24             	mov    %eax,(%esp)
    3d7d:	e8 12 ff ff ff       	call   3c94 <free>
  return freep;
    3d82:	8b 0d 40 5f 00 00    	mov    0x5f40,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
    3d88:	85 c9                	test   %ecx,%ecx
    3d8a:	75 be                	jne    3d4a <malloc+0x36>
        return 0;
    3d8c:	31 c0                	xor    %eax,%eax
  }
}
    3d8e:	83 c4 1c             	add    $0x1c,%esp
    3d91:	5b                   	pop    %ebx
    3d92:	5e                   	pop    %esi
    3d93:	5f                   	pop    %edi
    3d94:	5d                   	pop    %ebp
    3d95:	c3                   	ret    
    3d96:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
    3d98:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
    3d9d:	be 00 10 00 00       	mov    $0x1000,%esi
    3da2:	eb c3                	jmp    3d67 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
    3da4:	39 d3                	cmp    %edx,%ebx
    3da6:	74 1c                	je     3dc4 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
    3da8:	29 da                	sub    %ebx,%edx
    3daa:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    3dad:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
    3db0:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
    3db3:	89 0d 40 5f 00 00    	mov    %ecx,0x5f40
      return (void*)(p + 1);
    3db9:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    3dbc:	83 c4 1c             	add    $0x1c,%esp
    3dbf:	5b                   	pop    %ebx
    3dc0:	5e                   	pop    %esi
    3dc1:	5f                   	pop    %edi
    3dc2:	5d                   	pop    %ebp
    3dc3:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
    3dc4:	8b 10                	mov    (%eax),%edx
    3dc6:	89 11                	mov    %edx,(%ecx)
    3dc8:	eb e9                	jmp    3db3 <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    3dca:	c7 05 40 5f 00 00 44 	movl   $0x5f44,0x5f40
    3dd1:	5f 00 00 
    3dd4:	c7 05 44 5f 00 00 44 	movl   $0x5f44,0x5f44
    3ddb:	5f 00 00 
    base.s.size = 0;
    3dde:	c7 05 48 5f 00 00 00 	movl   $0x0,0x5f48
    3de5:	00 00 00 
    3de8:	b8 44 5f 00 00       	mov    $0x5f44,%eax
    3ded:	e9 4c ff ff ff       	jmp    3d3e <malloc+0x2a>
