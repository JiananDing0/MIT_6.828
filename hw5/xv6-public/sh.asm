
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
  return 0;
}

int
main(void)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 e4 f0             	and    $0xfffffff0,%esp
       6:	83 ec 10             	sub    $0x10,%esp
  static char buf[100];
  int fd;

  // Ensure that three file descriptors are open.
  while((fd = open("console", O_RDWR)) >= 0){
       9:	eb 0a                	jmp    15 <main+0x15>
       b:	90                   	nop
    if(fd >= 3){
       c:	83 f8 02             	cmp    $0x2,%eax
       f:	0f 8f c5 00 00 00    	jg     da <main+0xda>
{
  static char buf[100];
  int fd;

  // Ensure that three file descriptors are open.
  while((fd = open("console", O_RDWR)) >= 0){
      15:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
      1c:	00 
      1d:	c7 04 24 31 11 00 00 	movl   $0x1131,(%esp)
      24:	e8 e3 0c 00 00       	call   d0c <open>
      29:	85 c0                	test   %eax,%eax
      2b:	79 df                	jns    c <main+0xc>
      2d:	eb 1b                	jmp    4a <main+0x4a>
      2f:	90                   	nop
    }
  }

  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
      30:	80 3d 82 17 00 00 20 	cmpb   $0x20,0x1782
      37:	74 5d                	je     96 <main+0x96>
      39:	8d 76 00             	lea    0x0(%esi),%esi
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
    }
    if(fork1() == 0)
      3c:	e8 1f 01 00 00       	call   160 <fork1>
      41:	85 c0                	test   %eax,%eax
      43:	74 38                	je     7d <main+0x7d>
      runcmd(parsecmd(buf));
    wait();
      45:	e8 8a 0c 00 00       	call   cd4 <wait>
      break;
    }
  }

  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
      4a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
      51:	00 
      52:	c7 04 24 80 17 00 00 	movl   $0x1780,(%esp)
      59:	e8 8a 00 00 00       	call   e8 <getcmd>
      5e:	85 c0                	test   %eax,%eax
      60:	78 2f                	js     91 <main+0x91>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
      62:	80 3d 80 17 00 00 63 	cmpb   $0x63,0x1780
      69:	75 d1                	jne    3c <main+0x3c>
      6b:	80 3d 81 17 00 00 64 	cmpb   $0x64,0x1781
      72:	74 bc                	je     30 <main+0x30>
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
    }
    if(fork1() == 0)
      74:	e8 e7 00 00 00       	call   160 <fork1>
      79:	85 c0                	test   %eax,%eax
      7b:	75 c8                	jne    45 <main+0x45>
      runcmd(parsecmd(buf));
      7d:	c7 04 24 80 17 00 00 	movl   $0x1780,(%esp)
      84:	e8 03 0a 00 00       	call   a8c <parsecmd>
      89:	89 04 24             	mov    %eax,(%esp)
      8c:	e8 ef 00 00 00       	call   180 <runcmd>
    wait();
  }
  exit();
      91:	e8 36 0c 00 00       	call   ccc <exit>

  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
      // Chdir must be called by the parent, not the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      96:	c7 04 24 80 17 00 00 	movl   $0x1780,(%esp)
      9d:	e8 ca 0a 00 00       	call   b6c <strlen>
      a2:	c6 80 7f 17 00 00 00 	movb   $0x0,0x177f(%eax)
      if(chdir(buf+3) < 0)
      a9:	c7 04 24 83 17 00 00 	movl   $0x1783,(%esp)
      b0:	e8 87 0c 00 00       	call   d3c <chdir>
      b5:	85 c0                	test   %eax,%eax
      b7:	79 91                	jns    4a <main+0x4a>
        printf(2, "cannot cd %s\n", buf+3);
      b9:	c7 44 24 08 83 17 00 	movl   $0x1783,0x8(%esp)
      c0:	00 
      c1:	c7 44 24 04 39 11 00 	movl   $0x1139,0x4(%esp)
      c8:	00 
      c9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      d0:	e8 27 0d 00 00       	call   dfc <printf>
      d5:	e9 70 ff ff ff       	jmp    4a <main+0x4a>
  int fd;

  // Ensure that three file descriptors are open.
  while((fd = open("console", O_RDWR)) >= 0){
    if(fd >= 3){
      close(fd);
      da:	89 04 24             	mov    %eax,(%esp)
      dd:	e8 12 0c 00 00       	call   cf4 <close>
      break;
      e2:	e9 63 ff ff ff       	jmp    4a <main+0x4a>
      e7:	90                   	nop

000000e8 <getcmd>:
  exit();
}

int
getcmd(char *buf, int nbuf)
{
      e8:	55                   	push   %ebp
      e9:	89 e5                	mov    %esp,%ebp
      eb:	56                   	push   %esi
      ec:	53                   	push   %ebx
      ed:	83 ec 10             	sub    $0x10,%esp
      f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
      f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  printf(2, "$ ");
      f6:	c7 44 24 04 90 10 00 	movl   $0x1090,0x4(%esp)
      fd:	00 
      fe:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     105:	e8 f2 0c 00 00       	call   dfc <printf>
  memset(buf, 0, nbuf);
     10a:	89 74 24 08          	mov    %esi,0x8(%esp)
     10e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     115:	00 
     116:	89 1c 24             	mov    %ebx,(%esp)
     119:	e8 6e 0a 00 00       	call   b8c <memset>
  gets(buf, nbuf);
     11e:	89 74 24 04          	mov    %esi,0x4(%esp)
     122:	89 1c 24             	mov    %ebx,(%esp)
     125:	e8 a2 0a 00 00       	call   bcc <gets>
  if(buf[0] == 0) // EOF
    return -1;
     12a:	80 3b 01             	cmpb   $0x1,(%ebx)
     12d:	19 c0                	sbb    %eax,%eax
  return 0;
}
     12f:	83 c4 10             	add    $0x10,%esp
     132:	5b                   	pop    %ebx
     133:	5e                   	pop    %esi
     134:	5d                   	pop    %ebp
     135:	c3                   	ret    
     136:	66 90                	xchg   %ax,%ax

00000138 <panic>:
  exit();
}

void
panic(char *s)
{
     138:	55                   	push   %ebp
     139:	89 e5                	mov    %esp,%ebp
     13b:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     13e:	8b 45 08             	mov    0x8(%ebp),%eax
     141:	89 44 24 08          	mov    %eax,0x8(%esp)
     145:	c7 44 24 04 2d 11 00 	movl   $0x112d,0x4(%esp)
     14c:	00 
     14d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     154:	e8 a3 0c 00 00       	call   dfc <printf>
  exit();
     159:	e8 6e 0b 00 00       	call   ccc <exit>
     15e:	66 90                	xchg   %ax,%ax

00000160 <fork1>:
}

int
fork1(void)
{
     160:	55                   	push   %ebp
     161:	89 e5                	mov    %esp,%ebp
     163:	83 ec 18             	sub    $0x18,%esp
  int pid;

  pid = fork();
     166:	e8 59 0b 00 00       	call   cc4 <fork>
  if(pid == -1)
     16b:	83 f8 ff             	cmp    $0xffffffff,%eax
     16e:	74 02                	je     172 <fork1+0x12>
    panic("fork");
  return pid;
}
     170:	c9                   	leave  
     171:	c3                   	ret    
{
  int pid;

  pid = fork();
  if(pid == -1)
    panic("fork");
     172:	c7 04 24 93 10 00 00 	movl   $0x1093,(%esp)
     179:	e8 ba ff ff ff       	call   138 <panic>
     17e:	66 90                	xchg   %ax,%ax

00000180 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
     180:	55                   	push   %ebp
     181:	89 e5                	mov    %esp,%ebp
     183:	53                   	push   %ebx
     184:	83 ec 24             	sub    $0x24,%esp
     187:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     18a:	85 db                	test   %ebx,%ebx
     18c:	74 5e                	je     1ec <runcmd+0x6c>
    exit();

  switch(cmd->type){
     18e:	83 3b 05             	cmpl   $0x5,(%ebx)
     191:	76 5e                	jbe    1f1 <runcmd+0x71>
  default:
    panic("runcmd");
     193:	c7 04 24 98 10 00 00 	movl   $0x1098,(%esp)
     19a:	e8 99 ff ff ff       	call   138 <panic>
    runcmd(lcmd->right);
    break;

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
    if(pipe(p) < 0)
     19f:	8d 45 f0             	lea    -0x10(%ebp),%eax
     1a2:	89 04 24             	mov    %eax,(%esp)
     1a5:	e8 32 0b 00 00       	call   cdc <pipe>
     1aa:	85 c0                	test   %eax,%eax
     1ac:	0f 88 ee 00 00 00    	js     2a0 <runcmd+0x120>
      panic("pipe");
    if(fork1() == 0){
     1b2:	e8 a9 ff ff ff       	call   160 <fork1>
     1b7:	85 c0                	test   %eax,%eax
     1b9:	0f 84 25 01 00 00    	je     2e4 <runcmd+0x164>
      dup(p[1]);
      close(p[0]);
      close(p[1]);
      runcmd(pcmd->left);
    }
    if(fork1() == 0){
     1bf:	e8 9c ff ff ff       	call   160 <fork1>
     1c4:	85 c0                	test   %eax,%eax
     1c6:	0f 84 e0 00 00 00    	je     2ac <runcmd+0x12c>
      dup(p[0]);
      close(p[0]);
      close(p[1]);
      runcmd(pcmd->right);
    }
    close(p[0]);
     1cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
     1cf:	89 04 24             	mov    %eax,(%esp)
     1d2:	e8 1d 0b 00 00       	call   cf4 <close>
    close(p[1]);
     1d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1da:	89 04 24             	mov    %eax,(%esp)
     1dd:	e8 12 0b 00 00       	call   cf4 <close>
    wait();
     1e2:	e8 ed 0a 00 00       	call   cd4 <wait>
    wait();
     1e7:	e8 e8 0a 00 00       	call   cd4 <wait>
    bcmd = (struct backcmd*)cmd;
    if(fork1() == 0)
      runcmd(bcmd->cmd);
    break;
  }
  exit();
     1ec:	e8 db 0a 00 00       	call   ccc <exit>
  struct redircmd *rcmd;

  if(cmd == 0)
    exit();

  switch(cmd->type){
     1f1:	8b 03                	mov    (%ebx),%eax
     1f3:	ff 24 85 48 11 00 00 	jmp    *0x1148(,%eax,4)
    wait();
    break;

  case BACK:
    bcmd = (struct backcmd*)cmd;
    if(fork1() == 0)
     1fa:	e8 61 ff ff ff       	call   160 <fork1>
     1ff:	85 c0                	test   %eax,%eax
     201:	75 e9                	jne    1ec <runcmd+0x6c>
     203:	eb 3a                	jmp    23f <runcmd+0xbf>
    runcmd(rcmd->cmd);
    break;

  case LIST:
    lcmd = (struct listcmd*)cmd;
    if(fork1() == 0)
     205:	e8 56 ff ff ff       	call   160 <fork1>
     20a:	85 c0                	test   %eax,%eax
     20c:	74 31                	je     23f <runcmd+0xbf>
      runcmd(lcmd->left);
    wait();
     20e:	e8 c1 0a 00 00       	call   cd4 <wait>
    runcmd(lcmd->right);
     213:	8b 43 08             	mov    0x8(%ebx),%eax
     216:	89 04 24             	mov    %eax,(%esp)
     219:	e8 62 ff ff ff       	call   180 <runcmd>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    close(rcmd->fd);
     21e:	8b 43 14             	mov    0x14(%ebx),%eax
     221:	89 04 24             	mov    %eax,(%esp)
     224:	e8 cb 0a 00 00       	call   cf4 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     229:	8b 43 10             	mov    0x10(%ebx),%eax
     22c:	89 44 24 04          	mov    %eax,0x4(%esp)
     230:	8b 43 08             	mov    0x8(%ebx),%eax
     233:	89 04 24             	mov    %eax,(%esp)
     236:	e8 d1 0a 00 00       	call   d0c <open>
     23b:	85 c0                	test   %eax,%eax
     23d:	78 41                	js     280 <runcmd+0x100>
    break;

  case BACK:
    bcmd = (struct backcmd*)cmd;
    if(fork1() == 0)
      runcmd(bcmd->cmd);
     23f:	8b 43 04             	mov    0x4(%ebx),%eax
     242:	89 04 24             	mov    %eax,(%esp)
     245:	e8 36 ff ff ff       	call   180 <runcmd>
  default:
    panic("runcmd");

  case EXEC:
    ecmd = (struct execcmd*)cmd;
    if(ecmd->argv[0] == 0)
     24a:	8b 43 04             	mov    0x4(%ebx),%eax
     24d:	85 c0                	test   %eax,%eax
     24f:	74 9b                	je     1ec <runcmd+0x6c>
      exit();
    exec(ecmd->argv[0], ecmd->argv);
     251:	8d 53 04             	lea    0x4(%ebx),%edx
     254:	89 54 24 04          	mov    %edx,0x4(%esp)
     258:	89 04 24             	mov    %eax,(%esp)
     25b:	e8 a4 0a 00 00       	call   d04 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
     260:	8b 43 04             	mov    0x4(%ebx),%eax
     263:	89 44 24 08          	mov    %eax,0x8(%esp)
     267:	c7 44 24 04 9f 10 00 	movl   $0x109f,0x4(%esp)
     26e:	00 
     26f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     276:	e8 81 0b 00 00       	call   dfc <printf>
    break;
     27b:	e9 6c ff ff ff       	jmp    1ec <runcmd+0x6c>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    close(rcmd->fd);
    if(open(rcmd->file, rcmd->mode) < 0){
      printf(2, "open %s failed\n", rcmd->file);
     280:	8b 43 08             	mov    0x8(%ebx),%eax
     283:	89 44 24 08          	mov    %eax,0x8(%esp)
     287:	c7 44 24 04 af 10 00 	movl   $0x10af,0x4(%esp)
     28e:	00 
     28f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     296:	e8 61 0b 00 00       	call   dfc <printf>
      exit();
     29b:	e8 2c 0a 00 00       	call   ccc <exit>
    break;

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
    if(pipe(p) < 0)
      panic("pipe");
     2a0:	c7 04 24 bf 10 00 00 	movl   $0x10bf,(%esp)
     2a7:	e8 8c fe ff ff       	call   138 <panic>
      close(p[0]);
      close(p[1]);
      runcmd(pcmd->left);
    }
    if(fork1() == 0){
      close(0);
     2ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     2b3:	e8 3c 0a 00 00       	call   cf4 <close>
      dup(p[0]);
     2b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
     2bb:	89 04 24             	mov    %eax,(%esp)
     2be:	e8 81 0a 00 00       	call   d44 <dup>
      close(p[0]);
     2c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     2c6:	89 04 24             	mov    %eax,(%esp)
     2c9:	e8 26 0a 00 00       	call   cf4 <close>
      close(p[1]);
     2ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2d1:	89 04 24             	mov    %eax,(%esp)
     2d4:	e8 1b 0a 00 00       	call   cf4 <close>
      runcmd(pcmd->right);
     2d9:	8b 43 08             	mov    0x8(%ebx),%eax
     2dc:	89 04 24             	mov    %eax,(%esp)
     2df:	e8 9c fe ff ff       	call   180 <runcmd>
  case PIPE:
    pcmd = (struct pipecmd*)cmd;
    if(pipe(p) < 0)
      panic("pipe");
    if(fork1() == 0){
      close(1);
     2e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     2eb:	e8 04 0a 00 00       	call   cf4 <close>
      dup(p[1]);
     2f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2f3:	89 04 24             	mov    %eax,(%esp)
     2f6:	e8 49 0a 00 00       	call   d44 <dup>
      close(p[0]);
     2fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
     2fe:	89 04 24             	mov    %eax,(%esp)
     301:	e8 ee 09 00 00       	call   cf4 <close>
      close(p[1]);
     306:	8b 45 f4             	mov    -0xc(%ebp),%eax
     309:	89 04 24             	mov    %eax,(%esp)
     30c:	e8 e3 09 00 00       	call   cf4 <close>
      runcmd(pcmd->left);
     311:	8b 43 04             	mov    0x4(%ebx),%eax
     314:	89 04 24             	mov    %eax,(%esp)
     317:	e8 64 fe ff ff       	call   180 <runcmd>

0000031c <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     31c:	55                   	push   %ebp
     31d:	89 e5                	mov    %esp,%ebp
     31f:	53                   	push   %ebx
     320:	83 ec 14             	sub    $0x14,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     323:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     32a:	e8 81 0c 00 00       	call   fb0 <malloc>
     32f:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
     331:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     338:	00 
     339:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     340:	00 
     341:	89 04 24             	mov    %eax,(%esp)
     344:	e8 43 08 00 00       	call   b8c <memset>
  cmd->type = EXEC;
     349:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  return (struct cmd*)cmd;
}
     34f:	89 d8                	mov    %ebx,%eax
     351:	83 c4 14             	add    $0x14,%esp
     354:	5b                   	pop    %ebx
     355:	5d                   	pop    %ebp
     356:	c3                   	ret    
     357:	90                   	nop

00000358 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     358:	55                   	push   %ebp
     359:	89 e5                	mov    %esp,%ebp
     35b:	53                   	push   %ebx
     35c:	83 ec 14             	sub    $0x14,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     35f:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     366:	e8 45 0c 00 00       	call   fb0 <malloc>
     36b:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
     36d:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     374:	00 
     375:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     37c:	00 
     37d:	89 04 24             	mov    %eax,(%esp)
     380:	e8 07 08 00 00       	call   b8c <memset>
  cmd->type = REDIR;
     385:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  cmd->cmd = subcmd;
     38b:	8b 45 08             	mov    0x8(%ebp),%eax
     38e:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->file = file;
     391:	8b 45 0c             	mov    0xc(%ebp),%eax
     394:	89 43 08             	mov    %eax,0x8(%ebx)
  cmd->efile = efile;
     397:	8b 45 10             	mov    0x10(%ebp),%eax
     39a:	89 43 0c             	mov    %eax,0xc(%ebx)
  cmd->mode = mode;
     39d:	8b 45 14             	mov    0x14(%ebp),%eax
     3a0:	89 43 10             	mov    %eax,0x10(%ebx)
  cmd->fd = fd;
     3a3:	8b 45 18             	mov    0x18(%ebp),%eax
     3a6:	89 43 14             	mov    %eax,0x14(%ebx)
  return (struct cmd*)cmd;
}
     3a9:	89 d8                	mov    %ebx,%eax
     3ab:	83 c4 14             	add    $0x14,%esp
     3ae:	5b                   	pop    %ebx
     3af:	5d                   	pop    %ebp
     3b0:	c3                   	ret    
     3b1:	8d 76 00             	lea    0x0(%esi),%esi

000003b4 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     3b4:	55                   	push   %ebp
     3b5:	89 e5                	mov    %esp,%ebp
     3b7:	53                   	push   %ebx
     3b8:	83 ec 14             	sub    $0x14,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3bb:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     3c2:	e8 e9 0b 00 00       	call   fb0 <malloc>
     3c7:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
     3c9:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     3d0:	00 
     3d1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     3d8:	00 
     3d9:	89 04 24             	mov    %eax,(%esp)
     3dc:	e8 ab 07 00 00       	call   b8c <memset>
  cmd->type = PIPE;
     3e1:	c7 03 03 00 00 00    	movl   $0x3,(%ebx)
  cmd->left = left;
     3e7:	8b 45 08             	mov    0x8(%ebp),%eax
     3ea:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->right = right;
     3ed:	8b 45 0c             	mov    0xc(%ebp),%eax
     3f0:	89 43 08             	mov    %eax,0x8(%ebx)
  return (struct cmd*)cmd;
}
     3f3:	89 d8                	mov    %ebx,%eax
     3f5:	83 c4 14             	add    $0x14,%esp
     3f8:	5b                   	pop    %ebx
     3f9:	5d                   	pop    %ebp
     3fa:	c3                   	ret    
     3fb:	90                   	nop

000003fc <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     3fc:	55                   	push   %ebp
     3fd:	89 e5                	mov    %esp,%ebp
     3ff:	53                   	push   %ebx
     400:	83 ec 14             	sub    $0x14,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     403:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     40a:	e8 a1 0b 00 00       	call   fb0 <malloc>
     40f:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
     411:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     418:	00 
     419:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     420:	00 
     421:	89 04 24             	mov    %eax,(%esp)
     424:	e8 63 07 00 00       	call   b8c <memset>
  cmd->type = LIST;
     429:	c7 03 04 00 00 00    	movl   $0x4,(%ebx)
  cmd->left = left;
     42f:	8b 45 08             	mov    0x8(%ebp),%eax
     432:	89 43 04             	mov    %eax,0x4(%ebx)
  cmd->right = right;
     435:	8b 45 0c             	mov    0xc(%ebp),%eax
     438:	89 43 08             	mov    %eax,0x8(%ebx)
  return (struct cmd*)cmd;
}
     43b:	89 d8                	mov    %ebx,%eax
     43d:	83 c4 14             	add    $0x14,%esp
     440:	5b                   	pop    %ebx
     441:	5d                   	pop    %ebp
     442:	c3                   	ret    
     443:	90                   	nop

00000444 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     444:	55                   	push   %ebp
     445:	89 e5                	mov    %esp,%ebp
     447:	53                   	push   %ebx
     448:	83 ec 14             	sub    $0x14,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     44b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     452:	e8 59 0b 00 00       	call   fb0 <malloc>
     457:	89 c3                	mov    %eax,%ebx
  memset(cmd, 0, sizeof(*cmd));
     459:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     460:	00 
     461:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     468:	00 
     469:	89 04 24             	mov    %eax,(%esp)
     46c:	e8 1b 07 00 00       	call   b8c <memset>
  cmd->type = BACK;
     471:	c7 03 05 00 00 00    	movl   $0x5,(%ebx)
  cmd->cmd = subcmd;
     477:	8b 45 08             	mov    0x8(%ebp),%eax
     47a:	89 43 04             	mov    %eax,0x4(%ebx)
  return (struct cmd*)cmd;
}
     47d:	89 d8                	mov    %ebx,%eax
     47f:	83 c4 14             	add    $0x14,%esp
     482:	5b                   	pop    %ebx
     483:	5d                   	pop    %ebp
     484:	c3                   	ret    
     485:	8d 76 00             	lea    0x0(%esi),%esi

00000488 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     488:	55                   	push   %ebp
     489:	89 e5                	mov    %esp,%ebp
     48b:	57                   	push   %edi
     48c:	56                   	push   %esi
     48d:	53                   	push   %ebx
     48e:	83 ec 1c             	sub    $0x1c,%esp
     491:	8b 75 0c             	mov    0xc(%ebp),%esi
     494:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *s;
  int ret;

  s = *ps;
     497:	8b 45 08             	mov    0x8(%ebp),%eax
     49a:	8b 18                	mov    (%eax),%ebx
  while(s < es && strchr(whitespace, *s))
     49c:	39 f3                	cmp    %esi,%ebx
     49e:	72 09                	jb     4a9 <gettoken+0x21>
     4a0:	eb 1e                	jmp    4c0 <gettoken+0x38>
     4a2:	66 90                	xchg   %ax,%ax
    s++;
     4a4:	43                   	inc    %ebx
{
  char *s;
  int ret;

  s = *ps;
  while(s < es && strchr(whitespace, *s))
     4a5:	39 f3                	cmp    %esi,%ebx
     4a7:	74 17                	je     4c0 <gettoken+0x38>
     4a9:	0f be 03             	movsbl (%ebx),%eax
     4ac:	89 44 24 04          	mov    %eax,0x4(%esp)
     4b0:	c7 04 24 6c 17 00 00 	movl   $0x176c,(%esp)
     4b7:	e8 e8 06 00 00       	call   ba4 <strchr>
     4bc:	85 c0                	test   %eax,%eax
     4be:	75 e4                	jne    4a4 <gettoken+0x1c>
    s++;
  if(q)
     4c0:	85 ff                	test   %edi,%edi
     4c2:	74 02                	je     4c6 <gettoken+0x3e>
    *q = s;
     4c4:	89 1f                	mov    %ebx,(%edi)
  ret = *s;
     4c6:	8a 13                	mov    (%ebx),%dl
     4c8:	0f be fa             	movsbl %dl,%edi
     4cb:	89 f8                	mov    %edi,%eax
  switch(*s){
     4cd:	80 fa 3c             	cmp    $0x3c,%dl
     4d0:	7f 4a                	jg     51c <gettoken+0x94>
     4d2:	80 fa 3b             	cmp    $0x3b,%dl
     4d5:	0f 8c 91 00 00 00    	jl     56c <gettoken+0xe4>
  case '&':
  case '<':
    s++;
    break;
  case '>':
    s++;
     4db:	43                   	inc    %ebx
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     4dc:	8b 45 14             	mov    0x14(%ebp),%eax
     4df:	85 c0                	test   %eax,%eax
     4e1:	74 05                	je     4e8 <gettoken+0x60>
    *eq = s;
     4e3:	8b 45 14             	mov    0x14(%ebp),%eax
     4e6:	89 18                	mov    %ebx,(%eax)

  while(s < es && strchr(whitespace, *s))
     4e8:	39 f3                	cmp    %esi,%ebx
     4ea:	72 09                	jb     4f5 <gettoken+0x6d>
     4ec:	eb 1e                	jmp    50c <gettoken+0x84>
     4ee:	66 90                	xchg   %ax,%ax
    s++;
     4f0:	43                   	inc    %ebx
    break;
  }
  if(eq)
    *eq = s;

  while(s < es && strchr(whitespace, *s))
     4f1:	39 f3                	cmp    %esi,%ebx
     4f3:	74 17                	je     50c <gettoken+0x84>
     4f5:	0f be 03             	movsbl (%ebx),%eax
     4f8:	89 44 24 04          	mov    %eax,0x4(%esp)
     4fc:	c7 04 24 6c 17 00 00 	movl   $0x176c,(%esp)
     503:	e8 9c 06 00 00       	call   ba4 <strchr>
     508:	85 c0                	test   %eax,%eax
     50a:	75 e4                	jne    4f0 <gettoken+0x68>
    s++;
  *ps = s;
     50c:	8b 45 08             	mov    0x8(%ebp),%eax
     50f:	89 18                	mov    %ebx,(%eax)
  return ret;
}
     511:	89 f8                	mov    %edi,%eax
     513:	83 c4 1c             	add    $0x1c,%esp
     516:	5b                   	pop    %ebx
     517:	5e                   	pop    %esi
     518:	5f                   	pop    %edi
     519:	5d                   	pop    %ebp
     51a:	c3                   	ret    
     51b:	90                   	nop
  while(s < es && strchr(whitespace, *s))
    s++;
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
     51c:	80 fa 3e             	cmp    $0x3e,%dl
     51f:	74 6b                	je     58c <gettoken+0x104>
     521:	80 fa 7c             	cmp    $0x7c,%dl
     524:	74 b5                	je     4db <gettoken+0x53>
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     526:	39 de                	cmp    %ebx,%esi
     528:	77 21                	ja     54b <gettoken+0xc3>
     52a:	eb 33                	jmp    55f <gettoken+0xd7>
     52c:	0f be 03             	movsbl (%ebx),%eax
     52f:	89 44 24 04          	mov    %eax,0x4(%esp)
     533:	c7 04 24 64 17 00 00 	movl   $0x1764,(%esp)
     53a:	e8 65 06 00 00       	call   ba4 <strchr>
     53f:	85 c0                	test   %eax,%eax
     541:	75 1c                	jne    55f <gettoken+0xd7>
      s++;
     543:	43                   	inc    %ebx
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     544:	39 f3                	cmp    %esi,%ebx
     546:	74 17                	je     55f <gettoken+0xd7>
     548:	0f be 03             	movsbl (%ebx),%eax
     54b:	89 44 24 04          	mov    %eax,0x4(%esp)
     54f:	c7 04 24 6c 17 00 00 	movl   $0x176c,(%esp)
     556:	e8 49 06 00 00       	call   ba4 <strchr>
     55b:	85 c0                	test   %eax,%eax
     55d:	74 cd                	je     52c <gettoken+0xa4>
      ret = '+';
      s++;
    }
    break;
  default:
    ret = 'a';
     55f:	bf 61 00 00 00       	mov    $0x61,%edi
     564:	e9 73 ff ff ff       	jmp    4dc <gettoken+0x54>
     569:	8d 76 00             	lea    0x0(%esi),%esi
  while(s < es && strchr(whitespace, *s))
    s++;
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
     56c:	80 fa 29             	cmp    $0x29,%dl
     56f:	7f b5                	jg     526 <gettoken+0x9e>
     571:	80 fa 28             	cmp    $0x28,%dl
     574:	0f 8d 61 ff ff ff    	jge    4db <gettoken+0x53>
     57a:	84 d2                	test   %dl,%dl
     57c:	0f 84 5a ff ff ff    	je     4dc <gettoken+0x54>
     582:	80 fa 26             	cmp    $0x26,%dl
     585:	75 9f                	jne    526 <gettoken+0x9e>
     587:	e9 4f ff ff ff       	jmp    4db <gettoken+0x53>
  case '<':
    s++;
    break;
  case '>':
    s++;
    if(*s == '>'){
     58c:	80 7b 01 3e          	cmpb   $0x3e,0x1(%ebx)
     590:	0f 85 45 ff ff ff    	jne    4db <gettoken+0x53>
      ret = '+';
      s++;
     596:	83 c3 02             	add    $0x2,%ebx
    s++;
    break;
  case '>':
    s++;
    if(*s == '>'){
      ret = '+';
     599:	bf 2b 00 00 00       	mov    $0x2b,%edi
     59e:	e9 39 ff ff ff       	jmp    4dc <gettoken+0x54>
     5a3:	90                   	nop

000005a4 <peek>:
  return ret;
}

int
peek(char **ps, char *es, char *toks)
{
     5a4:	55                   	push   %ebp
     5a5:	89 e5                	mov    %esp,%ebp
     5a7:	57                   	push   %edi
     5a8:	56                   	push   %esi
     5a9:	53                   	push   %ebx
     5aa:	83 ec 1c             	sub    $0x1c,%esp
     5ad:	8b 7d 08             	mov    0x8(%ebp),%edi
     5b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *s;

  s = *ps;
     5b3:	8b 1f                	mov    (%edi),%ebx
  while(s < es && strchr(whitespace, *s))
     5b5:	39 f3                	cmp    %esi,%ebx
     5b7:	72 08                	jb     5c1 <peek+0x1d>
     5b9:	eb 1d                	jmp    5d8 <peek+0x34>
     5bb:	90                   	nop
    s++;
     5bc:	43                   	inc    %ebx
peek(char **ps, char *es, char *toks)
{
  char *s;

  s = *ps;
  while(s < es && strchr(whitespace, *s))
     5bd:	39 f3                	cmp    %esi,%ebx
     5bf:	74 17                	je     5d8 <peek+0x34>
     5c1:	0f be 03             	movsbl (%ebx),%eax
     5c4:	89 44 24 04          	mov    %eax,0x4(%esp)
     5c8:	c7 04 24 6c 17 00 00 	movl   $0x176c,(%esp)
     5cf:	e8 d0 05 00 00       	call   ba4 <strchr>
     5d4:	85 c0                	test   %eax,%eax
     5d6:	75 e4                	jne    5bc <peek+0x18>
    s++;
  *ps = s;
     5d8:	89 1f                	mov    %ebx,(%edi)
  return *s && strchr(toks, *s);
     5da:	8a 03                	mov    (%ebx),%al
     5dc:	84 c0                	test   %al,%al
     5de:	75 0c                	jne    5ec <peek+0x48>
     5e0:	31 c0                	xor    %eax,%eax
}
     5e2:	83 c4 1c             	add    $0x1c,%esp
     5e5:	5b                   	pop    %ebx
     5e6:	5e                   	pop    %esi
     5e7:	5f                   	pop    %edi
     5e8:	5d                   	pop    %ebp
     5e9:	c3                   	ret    
     5ea:	66 90                	xchg   %ax,%ax

  s = *ps;
  while(s < es && strchr(whitespace, *s))
    s++;
  *ps = s;
  return *s && strchr(toks, *s);
     5ec:	0f be c0             	movsbl %al,%eax
     5ef:	89 44 24 04          	mov    %eax,0x4(%esp)
     5f3:	8b 45 10             	mov    0x10(%ebp),%eax
     5f6:	89 04 24             	mov    %eax,(%esp)
     5f9:	e8 a6 05 00 00       	call   ba4 <strchr>
  *ps = s;
  return ret;
}

int
peek(char **ps, char *es, char *toks)
     5fe:	85 c0                	test   %eax,%eax

  s = *ps;
  while(s < es && strchr(whitespace, *s))
    s++;
  *ps = s;
  return *s && strchr(toks, *s);
     600:	0f 95 c0             	setne  %al
     603:	0f b6 c0             	movzbl %al,%eax
}
     606:	83 c4 1c             	add    $0x1c,%esp
     609:	5b                   	pop    %ebx
     60a:	5e                   	pop    %esi
     60b:	5f                   	pop    %edi
     60c:	5d                   	pop    %ebp
     60d:	c3                   	ret    
     60e:	66 90                	xchg   %ax,%ax

00000610 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     610:	55                   	push   %ebp
     611:	89 e5                	mov    %esp,%ebp
     613:	57                   	push   %edi
     614:	56                   	push   %esi
     615:	53                   	push   %ebx
     616:	83 ec 3c             	sub    $0x3c,%esp
     619:	8b 7d 0c             	mov    0xc(%ebp),%edi
     61c:	8b 75 10             	mov    0x10(%ebp),%esi
     61f:	90                   	nop
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     620:	c7 44 24 08 e1 10 00 	movl   $0x10e1,0x8(%esp)
     627:	00 
     628:	89 74 24 04          	mov    %esi,0x4(%esp)
     62c:	89 3c 24             	mov    %edi,(%esp)
     62f:	e8 70 ff ff ff       	call   5a4 <peek>
     634:	85 c0                	test   %eax,%eax
     636:	0f 84 94 00 00 00    	je     6d0 <parseredirs+0xc0>
    tok = gettoken(ps, es, 0, 0);
     63c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     643:	00 
     644:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     64b:	00 
     64c:	89 74 24 04          	mov    %esi,0x4(%esp)
     650:	89 3c 24             	mov    %edi,(%esp)
     653:	e8 30 fe ff ff       	call   488 <gettoken>
     658:	89 c3                	mov    %eax,%ebx
    if(gettoken(ps, es, &q, &eq) != 'a')
     65a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     65d:	89 44 24 0c          	mov    %eax,0xc(%esp)
     661:	8d 45 e0             	lea    -0x20(%ebp),%eax
     664:	89 44 24 08          	mov    %eax,0x8(%esp)
     668:	89 74 24 04          	mov    %esi,0x4(%esp)
     66c:	89 3c 24             	mov    %edi,(%esp)
     66f:	e8 14 fe ff ff       	call   488 <gettoken>
     674:	83 f8 61             	cmp    $0x61,%eax
     677:	75 62                	jne    6db <parseredirs+0xcb>
      panic("missing file for redirection");
    switch(tok){
     679:	83 fb 3c             	cmp    $0x3c,%ebx
     67c:	74 3e                	je     6bc <parseredirs+0xac>
     67e:	83 fb 3e             	cmp    $0x3e,%ebx
     681:	74 05                	je     688 <parseredirs+0x78>
     683:	83 fb 2b             	cmp    $0x2b,%ebx
     686:	75 98                	jne    620 <parseredirs+0x10>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     688:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     68f:	00 
     690:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     697:	00 
     698:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     69b:	89 44 24 08          	mov    %eax,0x8(%esp)
     69f:	8b 45 e0             	mov    -0x20(%ebp),%eax
     6a2:	89 44 24 04          	mov    %eax,0x4(%esp)
     6a6:	8b 45 08             	mov    0x8(%ebp),%eax
     6a9:	89 04 24             	mov    %eax,(%esp)
     6ac:	e8 a7 fc ff ff       	call   358 <redircmd>
     6b1:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     6b4:	e9 67 ff ff ff       	jmp    620 <parseredirs+0x10>
     6b9:	8d 76 00             	lea    0x0(%esi),%esi
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
      panic("missing file for redirection");
    switch(tok){
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     6bc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     6c3:	00 
     6c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     6cb:	00 
     6cc:	eb ca                	jmp    698 <parseredirs+0x88>
     6ce:	66 90                	xchg   %ax,%ax
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
}
     6d0:	8b 45 08             	mov    0x8(%ebp),%eax
     6d3:	83 c4 3c             	add    $0x3c,%esp
     6d6:	5b                   	pop    %ebx
     6d7:	5e                   	pop    %esi
     6d8:	5f                   	pop    %edi
     6d9:	5d                   	pop    %ebp
     6da:	c3                   	ret    
  char *q, *eq;

  while(peek(ps, es, "<>")){
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
      panic("missing file for redirection");
     6db:	c7 04 24 c4 10 00 00 	movl   $0x10c4,(%esp)
     6e2:	e8 51 fa ff ff       	call   138 <panic>
     6e7:	90                   	nop

000006e8 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     6e8:	55                   	push   %ebp
     6e9:	89 e5                	mov    %esp,%ebp
     6eb:	57                   	push   %edi
     6ec:	56                   	push   %esi
     6ed:	53                   	push   %ebx
     6ee:	83 ec 3c             	sub    $0x3c,%esp
     6f1:	8b 75 08             	mov    0x8(%ebp),%esi
     6f4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     6f7:	c7 44 24 08 e4 10 00 	movl   $0x10e4,0x8(%esp)
     6fe:	00 
     6ff:	89 7c 24 04          	mov    %edi,0x4(%esp)
     703:	89 34 24             	mov    %esi,(%esp)
     706:	e8 99 fe ff ff       	call   5a4 <peek>
     70b:	85 c0                	test   %eax,%eax
     70d:	0f 85 a1 00 00 00    	jne    7b4 <parseexec+0xcc>
    return parseblock(ps, es);

  ret = execcmd();
     713:	e8 04 fc ff ff       	call   31c <execcmd>
     718:	89 45 cc             	mov    %eax,-0x34(%ebp)
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     71b:	89 7c 24 08          	mov    %edi,0x8(%esp)
     71f:	89 74 24 04          	mov    %esi,0x4(%esp)
     723:	89 04 24             	mov    %eax,(%esp)
     726:	e8 e5 fe ff ff       	call   610 <parseredirs>
     72b:	89 45 d0             	mov    %eax,-0x30(%ebp)
     72e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
    return parseblock(ps, es);

  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
     731:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     738:	eb 18                	jmp    752 <parseexec+0x6a>
     73a:	66 90                	xchg   %ax,%ax
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
     73c:	89 7c 24 08          	mov    %edi,0x8(%esp)
     740:	89 74 24 04          	mov    %esi,0x4(%esp)
     744:	8b 45 d0             	mov    -0x30(%ebp),%eax
     747:	89 04 24             	mov    %eax,(%esp)
     74a:	e8 c1 fe ff ff       	call   610 <parseredirs>
     74f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     752:	c7 44 24 08 fb 10 00 	movl   $0x10fb,0x8(%esp)
     759:	00 
     75a:	89 7c 24 04          	mov    %edi,0x4(%esp)
     75e:	89 34 24             	mov    %esi,(%esp)
     761:	e8 3e fe ff ff       	call   5a4 <peek>
     766:	85 c0                	test   %eax,%eax
     768:	75 66                	jne    7d0 <parseexec+0xe8>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     76a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     76d:	89 44 24 0c          	mov    %eax,0xc(%esp)
     771:	8d 55 e0             	lea    -0x20(%ebp),%edx
     774:	89 54 24 08          	mov    %edx,0x8(%esp)
     778:	89 7c 24 04          	mov    %edi,0x4(%esp)
     77c:	89 34 24             	mov    %esi,(%esp)
     77f:	e8 04 fd ff ff       	call   488 <gettoken>
     784:	85 c0                	test   %eax,%eax
     786:	74 48                	je     7d0 <parseexec+0xe8>
      break;
    if(tok != 'a')
     788:	83 f8 61             	cmp    $0x61,%eax
     78b:	75 64                	jne    7f1 <parseexec+0x109>
      panic("syntax");
    cmd->argv[argc] = q;
     78d:	8b 45 e0             	mov    -0x20(%ebp),%eax
     790:	89 43 04             	mov    %eax,0x4(%ebx)
    cmd->eargv[argc] = eq;
     793:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     796:	89 43 2c             	mov    %eax,0x2c(%ebx)
    argc++;
     799:	ff 45 d4             	incl   -0x2c(%ebp)
     79c:	83 c3 04             	add    $0x4,%ebx
    if(argc >= MAXARGS)
     79f:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
     7a3:	75 97                	jne    73c <parseexec+0x54>
      panic("too many args");
     7a5:	c7 04 24 ed 10 00 00 	movl   $0x10ed,(%esp)
     7ac:	e8 87 f9 ff ff       	call   138 <panic>
     7b1:	8d 76 00             	lea    0x0(%esi),%esi
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
    return parseblock(ps, es);
     7b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
     7b8:	89 34 24             	mov    %esi,(%esp)
     7bb:	e8 78 01 00 00       	call   938 <parseblock>
     7c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     7c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
     7c6:	83 c4 3c             	add    $0x3c,%esp
     7c9:	5b                   	pop    %ebx
     7ca:	5e                   	pop    %esi
     7cb:	5f                   	pop    %edi
     7cc:	5d                   	pop    %ebp
     7cd:	c3                   	ret    
     7ce:	66 90                	xchg   %ax,%ax
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     7d0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
     7d3:	8b 45 cc             	mov    -0x34(%ebp),%eax
     7d6:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     7dd:	00 
  cmd->eargv[argc] = 0;
     7de:	c7 44 90 2c 00 00 00 	movl   $0x0,0x2c(%eax,%edx,4)
     7e5:	00 
  return ret;
}
     7e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
     7e9:	83 c4 3c             	add    $0x3c,%esp
     7ec:	5b                   	pop    %ebx
     7ed:	5e                   	pop    %esi
     7ee:	5f                   	pop    %edi
     7ef:	5d                   	pop    %ebp
     7f0:	c3                   	ret    
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
      panic("syntax");
     7f1:	c7 04 24 e6 10 00 00 	movl   $0x10e6,(%esp)
     7f8:	e8 3b f9 ff ff       	call   138 <panic>
     7fd:	8d 76 00             	lea    0x0(%esi),%esi

00000800 <parsepipe>:
  return cmd;
}

struct cmd*
parsepipe(char **ps, char *es)
{
     800:	55                   	push   %ebp
     801:	89 e5                	mov    %esp,%ebp
     803:	57                   	push   %edi
     804:	56                   	push   %esi
     805:	53                   	push   %ebx
     806:	83 ec 1c             	sub    $0x1c,%esp
     809:	8b 5d 08             	mov    0x8(%ebp),%ebx
     80c:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     80f:	89 74 24 04          	mov    %esi,0x4(%esp)
     813:	89 1c 24             	mov    %ebx,(%esp)
     816:	e8 cd fe ff ff       	call   6e8 <parseexec>
     81b:	89 c7                	mov    %eax,%edi
  if(peek(ps, es, "|")){
     81d:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
     824:	00 
     825:	89 74 24 04          	mov    %esi,0x4(%esp)
     829:	89 1c 24             	mov    %ebx,(%esp)
     82c:	e8 73 fd ff ff       	call   5a4 <peek>
     831:	85 c0                	test   %eax,%eax
     833:	75 0b                	jne    840 <parsepipe+0x40>
    gettoken(ps, es, 0, 0);
    cmd = pipecmd(cmd, parsepipe(ps, es));
  }
  return cmd;
}
     835:	89 f8                	mov    %edi,%eax
     837:	83 c4 1c             	add    $0x1c,%esp
     83a:	5b                   	pop    %ebx
     83b:	5e                   	pop    %esi
     83c:	5f                   	pop    %edi
     83d:	5d                   	pop    %ebp
     83e:	c3                   	ret    
     83f:	90                   	nop
{
  struct cmd *cmd;

  cmd = parseexec(ps, es);
  if(peek(ps, es, "|")){
    gettoken(ps, es, 0, 0);
     840:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     847:	00 
     848:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     84f:	00 
     850:	89 74 24 04          	mov    %esi,0x4(%esp)
     854:	89 1c 24             	mov    %ebx,(%esp)
     857:	e8 2c fc ff ff       	call   488 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     85c:	89 74 24 04          	mov    %esi,0x4(%esp)
     860:	89 1c 24             	mov    %ebx,(%esp)
     863:	e8 98 ff ff ff       	call   800 <parsepipe>
     868:	89 45 0c             	mov    %eax,0xc(%ebp)
     86b:	89 7d 08             	mov    %edi,0x8(%ebp)
  }
  return cmd;
}
     86e:	83 c4 1c             	add    $0x1c,%esp
     871:	5b                   	pop    %ebx
     872:	5e                   	pop    %esi
     873:	5f                   	pop    %edi
     874:	5d                   	pop    %ebp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
  if(peek(ps, es, "|")){
    gettoken(ps, es, 0, 0);
    cmd = pipecmd(cmd, parsepipe(ps, es));
     875:	e9 3a fb ff ff       	jmp    3b4 <pipecmd>
     87a:	66 90                	xchg   %ax,%ax

0000087c <parseline>:
  return cmd;
}

struct cmd*
parseline(char **ps, char *es)
{
     87c:	55                   	push   %ebp
     87d:	89 e5                	mov    %esp,%ebp
     87f:	57                   	push   %edi
     880:	56                   	push   %esi
     881:	53                   	push   %ebx
     882:	83 ec 1c             	sub    $0x1c,%esp
     885:	8b 5d 08             	mov    0x8(%ebp),%ebx
     888:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     88b:	89 74 24 04          	mov    %esi,0x4(%esp)
     88f:	89 1c 24             	mov    %ebx,(%esp)
     892:	e8 69 ff ff ff       	call   800 <parsepipe>
     897:	89 c7                	mov    %eax,%edi
  while(peek(ps, es, "&")){
     899:	eb 27                	jmp    8c2 <parseline+0x46>
     89b:	90                   	nop
    gettoken(ps, es, 0, 0);
     89c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     8a3:	00 
     8a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     8ab:	00 
     8ac:	89 74 24 04          	mov    %esi,0x4(%esp)
     8b0:	89 1c 24             	mov    %ebx,(%esp)
     8b3:	e8 d0 fb ff ff       	call   488 <gettoken>
    cmd = backcmd(cmd);
     8b8:	89 3c 24             	mov    %edi,(%esp)
     8bb:	e8 84 fb ff ff       	call   444 <backcmd>
     8c0:	89 c7                	mov    %eax,%edi
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     8c2:	c7 44 24 08 02 11 00 	movl   $0x1102,0x8(%esp)
     8c9:	00 
     8ca:	89 74 24 04          	mov    %esi,0x4(%esp)
     8ce:	89 1c 24             	mov    %ebx,(%esp)
     8d1:	e8 ce fc ff ff       	call   5a4 <peek>
     8d6:	85 c0                	test   %eax,%eax
     8d8:	75 c2                	jne    89c <parseline+0x20>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     8da:	c7 44 24 08 fe 10 00 	movl   $0x10fe,0x8(%esp)
     8e1:	00 
     8e2:	89 74 24 04          	mov    %esi,0x4(%esp)
     8e6:	89 1c 24             	mov    %ebx,(%esp)
     8e9:	e8 b6 fc ff ff       	call   5a4 <peek>
     8ee:	85 c0                	test   %eax,%eax
     8f0:	75 0a                	jne    8fc <parseline+0x80>
    gettoken(ps, es, 0, 0);
    cmd = listcmd(cmd, parseline(ps, es));
  }
  return cmd;
}
     8f2:	89 f8                	mov    %edi,%eax
     8f4:	83 c4 1c             	add    $0x1c,%esp
     8f7:	5b                   	pop    %ebx
     8f8:	5e                   	pop    %esi
     8f9:	5f                   	pop    %edi
     8fa:	5d                   	pop    %ebp
     8fb:	c3                   	ret    
  while(peek(ps, es, "&")){
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
    gettoken(ps, es, 0, 0);
     8fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     903:	00 
     904:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     90b:	00 
     90c:	89 74 24 04          	mov    %esi,0x4(%esp)
     910:	89 1c 24             	mov    %ebx,(%esp)
     913:	e8 70 fb ff ff       	call   488 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     918:	89 74 24 04          	mov    %esi,0x4(%esp)
     91c:	89 1c 24             	mov    %ebx,(%esp)
     91f:	e8 58 ff ff ff       	call   87c <parseline>
     924:	89 45 0c             	mov    %eax,0xc(%ebp)
     927:	89 7d 08             	mov    %edi,0x8(%ebp)
  }
  return cmd;
}
     92a:	83 c4 1c             	add    $0x1c,%esp
     92d:	5b                   	pop    %ebx
     92e:	5e                   	pop    %esi
     92f:	5f                   	pop    %edi
     930:	5d                   	pop    %ebp
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
    gettoken(ps, es, 0, 0);
    cmd = listcmd(cmd, parseline(ps, es));
     931:	e9 c6 fa ff ff       	jmp    3fc <listcmd>
     936:	66 90                	xchg   %ax,%ax

00000938 <parseblock>:
  return cmd;
}

struct cmd*
parseblock(char **ps, char *es)
{
     938:	55                   	push   %ebp
     939:	89 e5                	mov    %esp,%ebp
     93b:	57                   	push   %edi
     93c:	56                   	push   %esi
     93d:	53                   	push   %ebx
     93e:	83 ec 1c             	sub    $0x1c,%esp
     941:	8b 5d 08             	mov    0x8(%ebp),%ebx
     944:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     947:	c7 44 24 08 e4 10 00 	movl   $0x10e4,0x8(%esp)
     94e:	00 
     94f:	89 74 24 04          	mov    %esi,0x4(%esp)
     953:	89 1c 24             	mov    %ebx,(%esp)
     956:	e8 49 fc ff ff       	call   5a4 <peek>
     95b:	85 c0                	test   %eax,%eax
     95d:	74 76                	je     9d5 <parseblock+0x9d>
    panic("parseblock");
  gettoken(ps, es, 0, 0);
     95f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     966:	00 
     967:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     96e:	00 
     96f:	89 74 24 04          	mov    %esi,0x4(%esp)
     973:	89 1c 24             	mov    %ebx,(%esp)
     976:	e8 0d fb ff ff       	call   488 <gettoken>
  cmd = parseline(ps, es);
     97b:	89 74 24 04          	mov    %esi,0x4(%esp)
     97f:	89 1c 24             	mov    %ebx,(%esp)
     982:	e8 f5 fe ff ff       	call   87c <parseline>
     987:	89 c7                	mov    %eax,%edi
  if(!peek(ps, es, ")"))
     989:	c7 44 24 08 20 11 00 	movl   $0x1120,0x8(%esp)
     990:	00 
     991:	89 74 24 04          	mov    %esi,0x4(%esp)
     995:	89 1c 24             	mov    %ebx,(%esp)
     998:	e8 07 fc ff ff       	call   5a4 <peek>
     99d:	85 c0                	test   %eax,%eax
     99f:	74 40                	je     9e1 <parseblock+0xa9>
    panic("syntax - missing )");
  gettoken(ps, es, 0, 0);
     9a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     9a8:	00 
     9a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     9b0:	00 
     9b1:	89 74 24 04          	mov    %esi,0x4(%esp)
     9b5:	89 1c 24             	mov    %ebx,(%esp)
     9b8:	e8 cb fa ff ff       	call   488 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     9bd:	89 74 24 08          	mov    %esi,0x8(%esp)
     9c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     9c5:	89 3c 24             	mov    %edi,(%esp)
     9c8:	e8 43 fc ff ff       	call   610 <parseredirs>
  return cmd;
}
     9cd:	83 c4 1c             	add    $0x1c,%esp
     9d0:	5b                   	pop    %ebx
     9d1:	5e                   	pop    %esi
     9d2:	5f                   	pop    %edi
     9d3:	5d                   	pop    %ebp
     9d4:	c3                   	ret    
parseblock(char **ps, char *es)
{
  struct cmd *cmd;

  if(!peek(ps, es, "("))
    panic("parseblock");
     9d5:	c7 04 24 04 11 00 00 	movl   $0x1104,(%esp)
     9dc:	e8 57 f7 ff ff       	call   138 <panic>
  gettoken(ps, es, 0, 0);
  cmd = parseline(ps, es);
  if(!peek(ps, es, ")"))
    panic("syntax - missing )");
     9e1:	c7 04 24 0f 11 00 00 	movl   $0x110f,(%esp)
     9e8:	e8 4b f7 ff ff       	call   138 <panic>
     9ed:	8d 76 00             	lea    0x0(%esi),%esi

000009f0 <nulterminate>:
}

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     9f0:	55                   	push   %ebp
     9f1:	89 e5                	mov    %esp,%ebp
     9f3:	53                   	push   %ebx
     9f4:	83 ec 14             	sub    $0x14,%esp
     9f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     9fa:	85 db                	test   %ebx,%ebx
     9fc:	74 05                	je     a03 <nulterminate+0x13>
    return 0;

  switch(cmd->type){
     9fe:	83 3b 05             	cmpl   $0x5,(%ebx)
     a01:	76 09                	jbe    a0c <nulterminate+0x1c>
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     a03:	89 d8                	mov    %ebx,%eax
     a05:	83 c4 14             	add    $0x14,%esp
     a08:	5b                   	pop    %ebx
     a09:	5d                   	pop    %ebp
     a0a:	c3                   	ret    
     a0b:	90                   	nop
  struct redircmd *rcmd;

  if(cmd == 0)
    return 0;

  switch(cmd->type){
     a0c:	8b 03                	mov    (%ebx),%eax
     a0e:	ff 24 85 60 11 00 00 	jmp    *0x1160(,%eax,4)
     a15:	8d 76 00             	lea    0x0(%esi),%esi
    nulterminate(pcmd->right);
    break;

  case LIST:
    lcmd = (struct listcmd*)cmd;
    nulterminate(lcmd->left);
     a18:	8b 43 04             	mov    0x4(%ebx),%eax
     a1b:	89 04 24             	mov    %eax,(%esp)
     a1e:	e8 cd ff ff ff       	call   9f0 <nulterminate>
    nulterminate(lcmd->right);
     a23:	8b 43 08             	mov    0x8(%ebx),%eax
     a26:	89 04 24             	mov    %eax,(%esp)
     a29:	e8 c2 ff ff ff       	call   9f0 <nulterminate>
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     a2e:	89 d8                	mov    %ebx,%eax
     a30:	83 c4 14             	add    $0x14,%esp
     a33:	5b                   	pop    %ebx
     a34:	5d                   	pop    %ebp
     a35:	c3                   	ret    
     a36:	66 90                	xchg   %ax,%ax
    nulterminate(lcmd->right);
    break;

  case BACK:
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
     a38:	8b 43 04             	mov    0x4(%ebx),%eax
     a3b:	89 04 24             	mov    %eax,(%esp)
     a3e:	e8 ad ff ff ff       	call   9f0 <nulterminate>
    break;
  }
  return cmd;
}
     a43:	89 d8                	mov    %ebx,%eax
     a45:	83 c4 14             	add    $0x14,%esp
     a48:	5b                   	pop    %ebx
     a49:	5d                   	pop    %ebp
     a4a:	c3                   	ret    
     a4b:	90                   	nop
      *ecmd->eargv[i] = 0;
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     a4c:	8b 43 04             	mov    0x4(%ebx),%eax
     a4f:	89 04 24             	mov    %eax,(%esp)
     a52:	e8 99 ff ff ff       	call   9f0 <nulterminate>
    *rcmd->efile = 0;
     a57:	8b 43 0c             	mov    0xc(%ebx),%eax
     a5a:	c6 00 00             	movb   $0x0,(%eax)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     a5d:	89 d8                	mov    %ebx,%eax
     a5f:	83 c4 14             	add    $0x14,%esp
     a62:	5b                   	pop    %ebx
     a63:	5d                   	pop    %ebp
     a64:	c3                   	ret    
     a65:	8d 76 00             	lea    0x0(%esi),%esi
    return 0;

  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     a68:	8b 4b 04             	mov    0x4(%ebx),%ecx
     a6b:	85 c9                	test   %ecx,%ecx
     a6d:	74 94                	je     a03 <nulterminate+0x13>
     a6f:	89 d8                	mov    %ebx,%eax
     a71:	8d 76 00             	lea    0x0(%esi),%esi
      *ecmd->eargv[i] = 0;
     a74:	8b 50 2c             	mov    0x2c(%eax),%edx
     a77:	c6 02 00             	movb   $0x0,(%edx)
     a7a:	83 c0 04             	add    $0x4,%eax
    return 0;

  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     a7d:	8b 50 04             	mov    0x4(%eax),%edx
     a80:	85 d2                	test   %edx,%edx
     a82:	75 f0                	jne    a74 <nulterminate+0x84>
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     a84:	89 d8                	mov    %ebx,%eax
     a86:	83 c4 14             	add    $0x14,%esp
     a89:	5b                   	pop    %ebx
     a8a:	5d                   	pop    %ebp
     a8b:	c3                   	ret    

00000a8c <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     a8c:	55                   	push   %ebp
     a8d:	89 e5                	mov    %esp,%ebp
     a8f:	56                   	push   %esi
     a90:	53                   	push   %ebx
     a91:	83 ec 10             	sub    $0x10,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     a94:	8b 5d 08             	mov    0x8(%ebp),%ebx
     a97:	89 1c 24             	mov    %ebx,(%esp)
     a9a:	e8 cd 00 00 00       	call   b6c <strlen>
     a9f:	01 c3                	add    %eax,%ebx
  cmd = parseline(&s, es);
     aa1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     aa5:	8d 45 08             	lea    0x8(%ebp),%eax
     aa8:	89 04 24             	mov    %eax,(%esp)
     aab:	e8 cc fd ff ff       	call   87c <parseline>
     ab0:	89 c6                	mov    %eax,%esi
  peek(&s, es, "");
     ab2:	c7 44 24 08 ae 10 00 	movl   $0x10ae,0x8(%esp)
     ab9:	00 
     aba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
     abe:	8d 45 08             	lea    0x8(%ebp),%eax
     ac1:	89 04 24             	mov    %eax,(%esp)
     ac4:	e8 db fa ff ff       	call   5a4 <peek>
  if(s != es){
     ac9:	8b 45 08             	mov    0x8(%ebp),%eax
     acc:	39 d8                	cmp    %ebx,%eax
     ace:	75 11                	jne    ae1 <parsecmd+0x55>
    printf(2, "leftovers: %s\n", s);
    panic("syntax");
  }
  nulterminate(cmd);
     ad0:	89 34 24             	mov    %esi,(%esp)
     ad3:	e8 18 ff ff ff       	call   9f0 <nulterminate>
  return cmd;
}
     ad8:	89 f0                	mov    %esi,%eax
     ada:	83 c4 10             	add    $0x10,%esp
     add:	5b                   	pop    %ebx
     ade:	5e                   	pop    %esi
     adf:	5d                   	pop    %ebp
     ae0:	c3                   	ret    

  es = s + strlen(s);
  cmd = parseline(&s, es);
  peek(&s, es, "");
  if(s != es){
    printf(2, "leftovers: %s\n", s);
     ae1:	89 44 24 08          	mov    %eax,0x8(%esp)
     ae5:	c7 44 24 04 22 11 00 	movl   $0x1122,0x4(%esp)
     aec:	00 
     aed:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     af4:	e8 03 03 00 00       	call   dfc <printf>
    panic("syntax");
     af9:	c7 04 24 e6 10 00 00 	movl   $0x10e6,(%esp)
     b00:	e8 33 f6 ff ff       	call   138 <panic>
     b05:	90                   	nop
     b06:	90                   	nop
     b07:	90                   	nop

00000b08 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
     b08:	55                   	push   %ebp
     b09:	89 e5                	mov    %esp,%ebp
     b0b:	53                   	push   %ebx
     b0c:	8b 45 08             	mov    0x8(%ebp),%eax
     b0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     b12:	31 d2                	xor    %edx,%edx
     b14:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
     b17:	88 0c 10             	mov    %cl,(%eax,%edx,1)
     b1a:	42                   	inc    %edx
     b1b:	84 c9                	test   %cl,%cl
     b1d:	75 f5                	jne    b14 <strcpy+0xc>
    ;
  return os;
}
     b1f:	5b                   	pop    %ebx
     b20:	5d                   	pop    %ebp
     b21:	c3                   	ret    
     b22:	66 90                	xchg   %ax,%ax

00000b24 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     b24:	55                   	push   %ebp
     b25:	89 e5                	mov    %esp,%ebp
     b27:	56                   	push   %esi
     b28:	53                   	push   %ebx
     b29:	8b 4d 08             	mov    0x8(%ebp),%ecx
     b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
     b2f:	8a 01                	mov    (%ecx),%al
     b31:	8a 1a                	mov    (%edx),%bl
     b33:	84 c0                	test   %al,%al
     b35:	74 1d                	je     b54 <strcmp+0x30>
     b37:	38 d8                	cmp    %bl,%al
     b39:	74 0c                	je     b47 <strcmp+0x23>
     b3b:	eb 23                	jmp    b60 <strcmp+0x3c>
     b3d:	8d 76 00             	lea    0x0(%esi),%esi
     b40:	41                   	inc    %ecx
     b41:	38 d8                	cmp    %bl,%al
     b43:	75 1b                	jne    b60 <strcmp+0x3c>
    p++, q++;
     b45:	89 f2                	mov    %esi,%edx
     b47:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     b4a:	8a 41 01             	mov    0x1(%ecx),%al
     b4d:	8a 5a 01             	mov    0x1(%edx),%bl
     b50:	84 c0                	test   %al,%al
     b52:	75 ec                	jne    b40 <strcmp+0x1c>
     b54:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
     b56:	0f b6 db             	movzbl %bl,%ebx
     b59:	29 d8                	sub    %ebx,%eax
}
     b5b:	5b                   	pop    %ebx
     b5c:	5e                   	pop    %esi
     b5d:	5d                   	pop    %ebp
     b5e:	c3                   	ret    
     b5f:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     b60:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
     b63:	0f b6 db             	movzbl %bl,%ebx
     b66:	29 d8                	sub    %ebx,%eax
}
     b68:	5b                   	pop    %ebx
     b69:	5e                   	pop    %esi
     b6a:	5d                   	pop    %ebp
     b6b:	c3                   	ret    

00000b6c <strlen>:

uint
strlen(const char *s)
{
     b6c:	55                   	push   %ebp
     b6d:	89 e5                	mov    %esp,%ebp
     b6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
     b72:	80 39 00             	cmpb   $0x0,(%ecx)
     b75:	74 10                	je     b87 <strlen+0x1b>
     b77:	31 d2                	xor    %edx,%edx
     b79:	8d 76 00             	lea    0x0(%esi),%esi
     b7c:	42                   	inc    %edx
     b7d:	89 d0                	mov    %edx,%eax
     b7f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
     b83:	75 f7                	jne    b7c <strlen+0x10>
    ;
  return n;
}
     b85:	5d                   	pop    %ebp
     b86:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
     b87:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
     b89:	5d                   	pop    %ebp
     b8a:	c3                   	ret    
     b8b:	90                   	nop

00000b8c <memset>:

void*
memset(void *dst, int c, uint n)
{
     b8c:	55                   	push   %ebp
     b8d:	89 e5                	mov    %esp,%ebp
     b8f:	57                   	push   %edi
     b90:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
     b93:	89 d7                	mov    %edx,%edi
     b95:	8b 4d 10             	mov    0x10(%ebp),%ecx
     b98:	8b 45 0c             	mov    0xc(%ebp),%eax
     b9b:	fc                   	cld    
     b9c:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
     b9e:	89 d0                	mov    %edx,%eax
     ba0:	5f                   	pop    %edi
     ba1:	5d                   	pop    %ebp
     ba2:	c3                   	ret    
     ba3:	90                   	nop

00000ba4 <strchr>:

char*
strchr(const char *s, char c)
{
     ba4:	55                   	push   %ebp
     ba5:	89 e5                	mov    %esp,%ebp
     ba7:	8b 45 08             	mov    0x8(%ebp),%eax
     baa:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
     bad:	8a 10                	mov    (%eax),%dl
     baf:	84 d2                	test   %dl,%dl
     bb1:	75 0d                	jne    bc0 <strchr+0x1c>
     bb3:	eb 13                	jmp    bc8 <strchr+0x24>
     bb5:	8d 76 00             	lea    0x0(%esi),%esi
     bb8:	8a 50 01             	mov    0x1(%eax),%dl
     bbb:	84 d2                	test   %dl,%dl
     bbd:	74 09                	je     bc8 <strchr+0x24>
     bbf:	40                   	inc    %eax
    if(*s == c)
     bc0:	38 ca                	cmp    %cl,%dl
     bc2:	75 f4                	jne    bb8 <strchr+0x14>
      return (char*)s;
  return 0;
}
     bc4:	5d                   	pop    %ebp
     bc5:	c3                   	ret    
     bc6:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
     bc8:	31 c0                	xor    %eax,%eax
}
     bca:	5d                   	pop    %ebp
     bcb:	c3                   	ret    

00000bcc <gets>:

char*
gets(char *buf, int max)
{
     bcc:	55                   	push   %ebp
     bcd:	89 e5                	mov    %esp,%ebp
     bcf:	57                   	push   %edi
     bd0:	56                   	push   %esi
     bd1:	53                   	push   %ebx
     bd2:	83 ec 2c             	sub    $0x2c,%esp
     bd5:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     bd8:	31 f6                	xor    %esi,%esi
     bda:	eb 30                	jmp    c0c <gets+0x40>
    cc = read(0, &c, 1);
     bdc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     be3:	00 
     be4:	8d 45 e7             	lea    -0x19(%ebp),%eax
     be7:	89 44 24 04          	mov    %eax,0x4(%esp)
     beb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     bf2:	e8 ed 00 00 00       	call   ce4 <read>
    if(cc < 1)
     bf7:	85 c0                	test   %eax,%eax
     bf9:	7e 19                	jle    c14 <gets+0x48>
      break;
    buf[i++] = c;
     bfb:	8a 45 e7             	mov    -0x19(%ebp),%al
     bfe:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c02:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     c04:	3c 0a                	cmp    $0xa,%al
     c06:	74 0c                	je     c14 <gets+0x48>
     c08:	3c 0d                	cmp    $0xd,%al
     c0a:	74 08                	je     c14 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c0c:	8d 5e 01             	lea    0x1(%esi),%ebx
     c0f:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
     c12:	7c c8                	jl     bdc <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     c14:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
     c18:	89 f8                	mov    %edi,%eax
     c1a:	83 c4 2c             	add    $0x2c,%esp
     c1d:	5b                   	pop    %ebx
     c1e:	5e                   	pop    %esi
     c1f:	5f                   	pop    %edi
     c20:	5d                   	pop    %ebp
     c21:	c3                   	ret    
     c22:	66 90                	xchg   %ax,%ax

00000c24 <stat>:

int
stat(const char *n, struct stat *st)
{
     c24:	55                   	push   %ebp
     c25:	89 e5                	mov    %esp,%ebp
     c27:	56                   	push   %esi
     c28:	53                   	push   %ebx
     c29:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     c2c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     c33:	00 
     c34:	8b 45 08             	mov    0x8(%ebp),%eax
     c37:	89 04 24             	mov    %eax,(%esp)
     c3a:	e8 cd 00 00 00       	call   d0c <open>
     c3f:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
     c41:	85 c0                	test   %eax,%eax
     c43:	78 23                	js     c68 <stat+0x44>
    return -1;
  r = fstat(fd, st);
     c45:	8b 45 0c             	mov    0xc(%ebp),%eax
     c48:	89 44 24 04          	mov    %eax,0x4(%esp)
     c4c:	89 1c 24             	mov    %ebx,(%esp)
     c4f:	e8 d0 00 00 00       	call   d24 <fstat>
     c54:	89 c6                	mov    %eax,%esi
  close(fd);
     c56:	89 1c 24             	mov    %ebx,(%esp)
     c59:	e8 96 00 00 00       	call   cf4 <close>
  return r;
}
     c5e:	89 f0                	mov    %esi,%eax
     c60:	83 c4 10             	add    $0x10,%esp
     c63:	5b                   	pop    %ebx
     c64:	5e                   	pop    %esi
     c65:	5d                   	pop    %ebp
     c66:	c3                   	ret    
     c67:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
     c68:	be ff ff ff ff       	mov    $0xffffffff,%esi
     c6d:	eb ef                	jmp    c5e <stat+0x3a>
     c6f:	90                   	nop

00000c70 <atoi>:
  return r;
}

int
atoi(const char *s)
{
     c70:	55                   	push   %ebp
     c71:	89 e5                	mov    %esp,%ebp
     c73:	53                   	push   %ebx
     c74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     c77:	8a 11                	mov    (%ecx),%dl
     c79:	8d 42 d0             	lea    -0x30(%edx),%eax
     c7c:	3c 09                	cmp    $0x9,%al
     c7e:	b8 00 00 00 00       	mov    $0x0,%eax
     c83:	77 18                	ja     c9d <atoi+0x2d>
     c85:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
     c88:	8d 04 80             	lea    (%eax,%eax,4),%eax
     c8b:	0f be d2             	movsbl %dl,%edx
     c8e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
     c92:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     c93:	8a 11                	mov    (%ecx),%dl
     c95:	8d 5a d0             	lea    -0x30(%edx),%ebx
     c98:	80 fb 09             	cmp    $0x9,%bl
     c9b:	76 eb                	jbe    c88 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
     c9d:	5b                   	pop    %ebx
     c9e:	5d                   	pop    %ebp
     c9f:	c3                   	ret    

00000ca0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     ca0:	55                   	push   %ebp
     ca1:	89 e5                	mov    %esp,%ebp
     ca3:	56                   	push   %esi
     ca4:	53                   	push   %ebx
     ca5:	8b 45 08             	mov    0x8(%ebp),%eax
     ca8:	8b 75 0c             	mov    0xc(%ebp),%esi
     cab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     cae:	85 db                	test   %ebx,%ebx
     cb0:	7e 0d                	jle    cbf <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
     cb2:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
     cb4:	8a 0c 16             	mov    (%esi,%edx,1),%cl
     cb7:	88 0c 10             	mov    %cl,(%eax,%edx,1)
     cba:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     cbb:	39 da                	cmp    %ebx,%edx
     cbd:	75 f5                	jne    cb4 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
     cbf:	5b                   	pop    %ebx
     cc0:	5e                   	pop    %esi
     cc1:	5d                   	pop    %ebp
     cc2:	c3                   	ret    
     cc3:	90                   	nop

00000cc4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     cc4:	b8 01 00 00 00       	mov    $0x1,%eax
     cc9:	cd 40                	int    $0x40
     ccb:	c3                   	ret    

00000ccc <exit>:
SYSCALL(exit)
     ccc:	b8 02 00 00 00       	mov    $0x2,%eax
     cd1:	cd 40                	int    $0x40
     cd3:	c3                   	ret    

00000cd4 <wait>:
SYSCALL(wait)
     cd4:	b8 03 00 00 00       	mov    $0x3,%eax
     cd9:	cd 40                	int    $0x40
     cdb:	c3                   	ret    

00000cdc <pipe>:
SYSCALL(pipe)
     cdc:	b8 04 00 00 00       	mov    $0x4,%eax
     ce1:	cd 40                	int    $0x40
     ce3:	c3                   	ret    

00000ce4 <read>:
SYSCALL(read)
     ce4:	b8 05 00 00 00       	mov    $0x5,%eax
     ce9:	cd 40                	int    $0x40
     ceb:	c3                   	ret    

00000cec <write>:
SYSCALL(write)
     cec:	b8 10 00 00 00       	mov    $0x10,%eax
     cf1:	cd 40                	int    $0x40
     cf3:	c3                   	ret    

00000cf4 <close>:
SYSCALL(close)
     cf4:	b8 15 00 00 00       	mov    $0x15,%eax
     cf9:	cd 40                	int    $0x40
     cfb:	c3                   	ret    

00000cfc <kill>:
SYSCALL(kill)
     cfc:	b8 06 00 00 00       	mov    $0x6,%eax
     d01:	cd 40                	int    $0x40
     d03:	c3                   	ret    

00000d04 <exec>:
SYSCALL(exec)
     d04:	b8 07 00 00 00       	mov    $0x7,%eax
     d09:	cd 40                	int    $0x40
     d0b:	c3                   	ret    

00000d0c <open>:
SYSCALL(open)
     d0c:	b8 0f 00 00 00       	mov    $0xf,%eax
     d11:	cd 40                	int    $0x40
     d13:	c3                   	ret    

00000d14 <mknod>:
SYSCALL(mknod)
     d14:	b8 11 00 00 00       	mov    $0x11,%eax
     d19:	cd 40                	int    $0x40
     d1b:	c3                   	ret    

00000d1c <unlink>:
SYSCALL(unlink)
     d1c:	b8 12 00 00 00       	mov    $0x12,%eax
     d21:	cd 40                	int    $0x40
     d23:	c3                   	ret    

00000d24 <fstat>:
SYSCALL(fstat)
     d24:	b8 08 00 00 00       	mov    $0x8,%eax
     d29:	cd 40                	int    $0x40
     d2b:	c3                   	ret    

00000d2c <link>:
SYSCALL(link)
     d2c:	b8 13 00 00 00       	mov    $0x13,%eax
     d31:	cd 40                	int    $0x40
     d33:	c3                   	ret    

00000d34 <mkdir>:
SYSCALL(mkdir)
     d34:	b8 14 00 00 00       	mov    $0x14,%eax
     d39:	cd 40                	int    $0x40
     d3b:	c3                   	ret    

00000d3c <chdir>:
SYSCALL(chdir)
     d3c:	b8 09 00 00 00       	mov    $0x9,%eax
     d41:	cd 40                	int    $0x40
     d43:	c3                   	ret    

00000d44 <dup>:
SYSCALL(dup)
     d44:	b8 0a 00 00 00       	mov    $0xa,%eax
     d49:	cd 40                	int    $0x40
     d4b:	c3                   	ret    

00000d4c <getpid>:
SYSCALL(getpid)
     d4c:	b8 0b 00 00 00       	mov    $0xb,%eax
     d51:	cd 40                	int    $0x40
     d53:	c3                   	ret    

00000d54 <sbrk>:
SYSCALL(sbrk)
     d54:	b8 0c 00 00 00       	mov    $0xc,%eax
     d59:	cd 40                	int    $0x40
     d5b:	c3                   	ret    

00000d5c <sleep>:
SYSCALL(sleep)
     d5c:	b8 0d 00 00 00       	mov    $0xd,%eax
     d61:	cd 40                	int    $0x40
     d63:	c3                   	ret    

00000d64 <uptime>:
SYSCALL(uptime)
     d64:	b8 0e 00 00 00       	mov    $0xe,%eax
     d69:	cd 40                	int    $0x40
     d6b:	c3                   	ret    

00000d6c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
     d6c:	55                   	push   %ebp
     d6d:	89 e5                	mov    %esp,%ebp
     d6f:	83 ec 28             	sub    $0x28,%esp
     d72:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
     d75:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     d7c:	00 
     d7d:	8d 55 f4             	lea    -0xc(%ebp),%edx
     d80:	89 54 24 04          	mov    %edx,0x4(%esp)
     d84:	89 04 24             	mov    %eax,(%esp)
     d87:	e8 60 ff ff ff       	call   cec <write>
}
     d8c:	c9                   	leave  
     d8d:	c3                   	ret    
     d8e:	66 90                	xchg   %ax,%ax

00000d90 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     d90:	55                   	push   %ebp
     d91:	89 e5                	mov    %esp,%ebp
     d93:	57                   	push   %edi
     d94:	56                   	push   %esi
     d95:	53                   	push   %ebx
     d96:	83 ec 1c             	sub    $0x1c,%esp
     d99:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
     d9b:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     d9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
     da0:	85 db                	test   %ebx,%ebx
     da2:	74 04                	je     da8 <printint+0x18>
     da4:	85 d2                	test   %edx,%edx
     da6:	78 4a                	js     df2 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
     da8:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     daa:	31 db                	xor    %ebx,%ebx
     dac:	eb 04                	jmp    db2 <printint+0x22>
     dae:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
     db0:	89 d3                	mov    %edx,%ebx
     db2:	31 d2                	xor    %edx,%edx
     db4:	f7 f1                	div    %ecx
     db6:	8a 92 7f 11 00 00    	mov    0x117f(%edx),%dl
     dbc:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
     dc0:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
     dc3:	85 c0                	test   %eax,%eax
     dc5:	75 e9                	jne    db0 <printint+0x20>
  if(neg)
     dc7:	85 ff                	test   %edi,%edi
     dc9:	74 08                	je     dd3 <printint+0x43>
    buf[i++] = '-';
     dcb:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
     dd0:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
     dd3:	8d 5a ff             	lea    -0x1(%edx),%ebx
     dd6:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
     dd8:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
     ddd:	89 f0                	mov    %esi,%eax
     ddf:	e8 88 ff ff ff       	call   d6c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
     de4:	4b                   	dec    %ebx
     de5:	83 fb ff             	cmp    $0xffffffff,%ebx
     de8:	75 ee                	jne    dd8 <printint+0x48>
    putc(fd, buf[i]);
}
     dea:	83 c4 1c             	add    $0x1c,%esp
     ded:	5b                   	pop    %ebx
     dee:	5e                   	pop    %esi
     def:	5f                   	pop    %edi
     df0:	5d                   	pop    %ebp
     df1:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
     df2:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
     df4:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
     df9:	eb af                	jmp    daa <printint+0x1a>
     dfb:	90                   	nop

00000dfc <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
     dfc:	55                   	push   %ebp
     dfd:	89 e5                	mov    %esp,%ebp
     dff:	57                   	push   %edi
     e00:	56                   	push   %esi
     e01:	53                   	push   %ebx
     e02:	83 ec 2c             	sub    $0x2c,%esp
     e05:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
     e08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
     e0b:	8a 0b                	mov    (%ebx),%cl
     e0d:	84 c9                	test   %cl,%cl
     e0f:	74 7b                	je     e8c <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
     e11:	8d 45 10             	lea    0x10(%ebp),%eax
     e14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
     e17:	31 f6                	xor    %esi,%esi
     e19:	eb 17                	jmp    e32 <printf+0x36>
     e1b:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
     e1c:	83 f9 25             	cmp    $0x25,%ecx
     e1f:	74 73                	je     e94 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
     e21:	0f be d1             	movsbl %cl,%edx
     e24:	89 f8                	mov    %edi,%eax
     e26:	e8 41 ff ff ff       	call   d6c <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
     e2b:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
     e2c:	8a 0b                	mov    (%ebx),%cl
     e2e:	84 c9                	test   %cl,%cl
     e30:	74 5a                	je     e8c <printf+0x90>
    c = fmt[i] & 0xff;
     e32:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
     e35:	85 f6                	test   %esi,%esi
     e37:	74 e3                	je     e1c <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     e39:	83 fe 25             	cmp    $0x25,%esi
     e3c:	75 ed                	jne    e2b <printf+0x2f>
      if(c == 'd'){
     e3e:	83 f9 64             	cmp    $0x64,%ecx
     e41:	0f 84 c1 00 00 00    	je     f08 <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
     e47:	83 f9 78             	cmp    $0x78,%ecx
     e4a:	74 50                	je     e9c <printf+0xa0>
     e4c:	83 f9 70             	cmp    $0x70,%ecx
     e4f:	74 4b                	je     e9c <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
     e51:	83 f9 73             	cmp    $0x73,%ecx
     e54:	74 6a                	je     ec0 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     e56:	83 f9 63             	cmp    $0x63,%ecx
     e59:	0f 84 91 00 00 00    	je     ef0 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
     e5f:	ba 25 00 00 00       	mov    $0x25,%edx
     e64:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
     e66:	83 f9 25             	cmp    $0x25,%ecx
     e69:	74 10                	je     e7b <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     e6b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
     e6e:	e8 f9 fe ff ff       	call   d6c <putc>
        putc(fd, c);
     e73:	8b 4d e0             	mov    -0x20(%ebp),%ecx
     e76:	0f be d1             	movsbl %cl,%edx
     e79:	89 f8                	mov    %edi,%eax
     e7b:	e8 ec fe ff ff       	call   d6c <putc>
      }
      state = 0;
     e80:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
     e82:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
     e83:	8a 0b                	mov    (%ebx),%cl
     e85:	84 c9                	test   %cl,%cl
     e87:	75 a9                	jne    e32 <printf+0x36>
     e89:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
     e8c:	83 c4 2c             	add    $0x2c,%esp
     e8f:	5b                   	pop    %ebx
     e90:	5e                   	pop    %esi
     e91:	5f                   	pop    %edi
     e92:	5d                   	pop    %ebp
     e93:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
     e94:	be 25 00 00 00       	mov    $0x25,%esi
     e99:	eb 90                	jmp    e2b <printf+0x2f>
     e9b:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
     e9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     ea3:	b9 10 00 00 00       	mov    $0x10,%ecx
     ea8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     eab:	8b 10                	mov    (%eax),%edx
     ead:	89 f8                	mov    %edi,%eax
     eaf:	e8 dc fe ff ff       	call   d90 <printint>
        ap++;
     eb4:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
     eb8:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
     eba:	e9 6c ff ff ff       	jmp    e2b <printf+0x2f>
     ebf:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
     ec0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     ec3:	8b 30                	mov    (%eax),%esi
        ap++;
     ec5:	83 c0 04             	add    $0x4,%eax
     ec8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
     ecb:	85 f6                	test   %esi,%esi
     ecd:	74 5a                	je     f29 <printf+0x12d>
          s = "(null)";
        while(*s != 0){
     ecf:	8a 16                	mov    (%esi),%dl
     ed1:	84 d2                	test   %dl,%dl
     ed3:	74 14                	je     ee9 <printf+0xed>
     ed5:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
     ed8:	0f be d2             	movsbl %dl,%edx
     edb:	89 f8                	mov    %edi,%eax
     edd:	e8 8a fe ff ff       	call   d6c <putc>
          s++;
     ee2:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
     ee3:	8a 16                	mov    (%esi),%dl
     ee5:	84 d2                	test   %dl,%dl
     ee7:	75 ef                	jne    ed8 <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
     ee9:	31 f6                	xor    %esi,%esi
     eeb:	e9 3b ff ff ff       	jmp    e2b <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
     ef0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     ef3:	0f be 10             	movsbl (%eax),%edx
     ef6:	89 f8                	mov    %edi,%eax
     ef8:	e8 6f fe ff ff       	call   d6c <putc>
        ap++;
     efd:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
     f01:	31 f6                	xor    %esi,%esi
     f03:	e9 23 ff ff ff       	jmp    e2b <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
     f08:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f0f:	b1 0a                	mov    $0xa,%cl
     f11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     f14:	8b 10                	mov    (%eax),%edx
     f16:	89 f8                	mov    %edi,%eax
     f18:	e8 73 fe ff ff       	call   d90 <printint>
        ap++;
     f1d:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
     f21:	66 31 f6             	xor    %si,%si
     f24:	e9 02 ff ff ff       	jmp    e2b <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
     f29:	be 78 11 00 00       	mov    $0x1178,%esi
     f2e:	eb 9f                	jmp    ecf <printf+0xd3>

00000f30 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     f30:	55                   	push   %ebp
     f31:	89 e5                	mov    %esp,%ebp
     f33:	57                   	push   %edi
     f34:	56                   	push   %esi
     f35:	53                   	push   %ebx
     f36:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
     f39:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     f3c:	a1 e4 17 00 00       	mov    0x17e4,%eax
     f41:	8d 76 00             	lea    0x0(%esi),%esi
     f44:	8b 10                	mov    (%eax),%edx
     f46:	39 c8                	cmp    %ecx,%eax
     f48:	73 04                	jae    f4e <free+0x1e>
     f4a:	39 d1                	cmp    %edx,%ecx
     f4c:	72 12                	jb     f60 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     f4e:	39 d0                	cmp    %edx,%eax
     f50:	72 08                	jb     f5a <free+0x2a>
     f52:	39 c8                	cmp    %ecx,%eax
     f54:	72 0a                	jb     f60 <free+0x30>
     f56:	39 d1                	cmp    %edx,%ecx
     f58:	72 06                	jb     f60 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
     f5a:	89 d0                	mov    %edx,%eax
     f5c:	eb e6                	jmp    f44 <free+0x14>
     f5e:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
     f60:	8b 73 fc             	mov    -0x4(%ebx),%esi
     f63:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
     f66:	39 d7                	cmp    %edx,%edi
     f68:	74 19                	je     f83 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
     f6a:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
     f6d:	8b 50 04             	mov    0x4(%eax),%edx
     f70:	8d 34 d0             	lea    (%eax,%edx,8),%esi
     f73:	39 f1                	cmp    %esi,%ecx
     f75:	74 23                	je     f9a <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
     f77:	89 08                	mov    %ecx,(%eax)
  freep = p;
     f79:	a3 e4 17 00 00       	mov    %eax,0x17e4
}
     f7e:	5b                   	pop    %ebx
     f7f:	5e                   	pop    %esi
     f80:	5f                   	pop    %edi
     f81:	5d                   	pop    %ebp
     f82:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
     f83:	03 72 04             	add    0x4(%edx),%esi
     f86:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
     f89:	8b 10                	mov    (%eax),%edx
     f8b:	8b 12                	mov    (%edx),%edx
     f8d:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
     f90:	8b 50 04             	mov    0x4(%eax),%edx
     f93:	8d 34 d0             	lea    (%eax,%edx,8),%esi
     f96:	39 f1                	cmp    %esi,%ecx
     f98:	75 dd                	jne    f77 <free+0x47>
    p->s.size += bp->s.size;
     f9a:	03 53 fc             	add    -0x4(%ebx),%edx
     f9d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
     fa0:	8b 53 f8             	mov    -0x8(%ebx),%edx
     fa3:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
     fa5:	a3 e4 17 00 00       	mov    %eax,0x17e4
}
     faa:	5b                   	pop    %ebx
     fab:	5e                   	pop    %esi
     fac:	5f                   	pop    %edi
     fad:	5d                   	pop    %ebp
     fae:	c3                   	ret    
     faf:	90                   	nop

00000fb0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
     fb0:	55                   	push   %ebp
     fb1:	89 e5                	mov    %esp,%ebp
     fb3:	57                   	push   %edi
     fb4:	56                   	push   %esi
     fb5:	53                   	push   %ebx
     fb6:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
     fb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
     fbc:	83 c3 07             	add    $0x7,%ebx
     fbf:	c1 eb 03             	shr    $0x3,%ebx
     fc2:	43                   	inc    %ebx
  if((prevp = freep) == 0){
     fc3:	8b 0d e4 17 00 00    	mov    0x17e4,%ecx
     fc9:	85 c9                	test   %ecx,%ecx
     fcb:	0f 84 95 00 00 00    	je     1066 <malloc+0xb6>
     fd1:	8b 01                	mov    (%ecx),%eax
     fd3:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
     fd6:	39 da                	cmp    %ebx,%edx
     fd8:	73 66                	jae    1040 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
     fda:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
     fe1:	eb 0c                	jmp    fef <malloc+0x3f>
     fe3:	90                   	nop
    }
    if(p == freep)
     fe4:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
     fe6:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
     fe8:	8b 50 04             	mov    0x4(%eax),%edx
     feb:	39 d3                	cmp    %edx,%ebx
     fed:	76 51                	jbe    1040 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
     fef:	3b 05 e4 17 00 00    	cmp    0x17e4,%eax
     ff5:	75 ed                	jne    fe4 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
     ff7:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
     ffd:	76 35                	jbe    1034 <malloc+0x84>
     fff:	89 f8                	mov    %edi,%eax
    1001:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
    1003:	89 04 24             	mov    %eax,(%esp)
    1006:	e8 49 fd ff ff       	call   d54 <sbrk>
  if(p == (char*)-1)
    100b:	83 f8 ff             	cmp    $0xffffffff,%eax
    100e:	74 18                	je     1028 <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
    1010:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
    1013:	83 c0 08             	add    $0x8,%eax
    1016:	89 04 24             	mov    %eax,(%esp)
    1019:	e8 12 ff ff ff       	call   f30 <free>
  return freep;
    101e:	8b 0d e4 17 00 00    	mov    0x17e4,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
    1024:	85 c9                	test   %ecx,%ecx
    1026:	75 be                	jne    fe6 <malloc+0x36>
        return 0;
    1028:	31 c0                	xor    %eax,%eax
  }
}
    102a:	83 c4 1c             	add    $0x1c,%esp
    102d:	5b                   	pop    %ebx
    102e:	5e                   	pop    %esi
    102f:	5f                   	pop    %edi
    1030:	5d                   	pop    %ebp
    1031:	c3                   	ret    
    1032:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
    1034:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
    1039:	be 00 10 00 00       	mov    $0x1000,%esi
    103e:	eb c3                	jmp    1003 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
    1040:	39 d3                	cmp    %edx,%ebx
    1042:	74 1c                	je     1060 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
    1044:	29 da                	sub    %ebx,%edx
    1046:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1049:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
    104c:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
    104f:	89 0d e4 17 00 00    	mov    %ecx,0x17e4
      return (void*)(p + 1);
    1055:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1058:	83 c4 1c             	add    $0x1c,%esp
    105b:	5b                   	pop    %ebx
    105c:	5e                   	pop    %esi
    105d:	5f                   	pop    %edi
    105e:	5d                   	pop    %ebp
    105f:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
    1060:	8b 10                	mov    (%eax),%edx
    1062:	89 11                	mov    %edx,(%ecx)
    1064:	eb e9                	jmp    104f <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    1066:	c7 05 e4 17 00 00 e8 	movl   $0x17e8,0x17e4
    106d:	17 00 00 
    1070:	c7 05 e8 17 00 00 e8 	movl   $0x17e8,0x17e8
    1077:	17 00 00 
    base.s.size = 0;
    107a:	c7 05 ec 17 00 00 00 	movl   $0x0,0x17ec
    1081:	00 00 00 
    1084:	b8 e8 17 00 00       	mov    $0x17e8,%eax
    1089:	e9 4c ff ff ff       	jmp    fda <malloc+0x2a>
