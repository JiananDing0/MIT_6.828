
_alarmtest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

void periodic();

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	83 e4 f0             	and    $0xfffffff0,%esp
   8:	83 ec 10             	sub    $0x10,%esp
  int i;
  printf(1, "alarmtest starting\n");
   b:	c7 44 24 04 2a 06 00 	movl   $0x62a,0x4(%esp)
  12:	00 
  13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1a:	e8 71 03 00 00       	call   390 <printf>
  alarm(10, periodic);
  1f:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  26:	00 
  27:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  2e:	e8 c5 02 00 00       	call   2f8 <alarm>
  for(i = 0; i < 25*5000000; i++){
  33:	31 db                	xor    %ebx,%ebx
    if((i % 250000) == 0)
  35:	be 90 d0 03 00       	mov    $0x3d090,%esi
  3a:	eb 09                	jmp    45 <main+0x45>
main(int argc, char *argv[])
{
  int i;
  printf(1, "alarmtest starting\n");
  alarm(10, periodic);
  for(i = 0; i < 25*5000000; i++){
  3c:	43                   	inc    %ebx
  3d:	81 fb 40 59 73 07    	cmp    $0x7735940,%ebx
  43:	74 2e                	je     73 <main+0x73>
    if((i % 250000) == 0)
  45:	89 d8                	mov    %ebx,%eax
  47:	99                   	cltd   
  48:	f7 fe                	idiv   %esi
  4a:	85 d2                	test   %edx,%edx
  4c:	75 ee                	jne    3c <main+0x3c>
      write(2, ".", 1);
  4e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  55:	00 
  56:	c7 44 24 04 3e 06 00 	movl   $0x63e,0x4(%esp)
  5d:	00 
  5e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  65:	e8 0e 02 00 00       	call   278 <write>
main(int argc, char *argv[])
{
  int i;
  printf(1, "alarmtest starting\n");
  alarm(10, periodic);
  for(i = 0; i < 25*5000000; i++){
  6a:	43                   	inc    %ebx
  6b:	81 fb 40 59 73 07    	cmp    $0x7735940,%ebx
  71:	75 d2                	jne    45 <main+0x45>
    if((i % 250000) == 0)
      write(2, ".", 1);
  }
  exit();
  73:	e8 e0 01 00 00       	call   258 <exit>

00000078 <periodic>:
}

void
periodic()
{
  78:	55                   	push   %ebp
  79:	89 e5                	mov    %esp,%ebp
  7b:	83 ec 18             	sub    $0x18,%esp
  printf(1, "alarm!\n");
  7e:	c7 44 24 04 22 06 00 	movl   $0x622,0x4(%esp)
  85:	00 
  86:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8d:	e8 fe 02 00 00       	call   390 <printf>
  92:	c9                   	leave  
  93:	c3                   	ret    

00000094 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  94:	55                   	push   %ebp
  95:	89 e5                	mov    %esp,%ebp
  97:	53                   	push   %ebx
  98:	8b 45 08             	mov    0x8(%ebp),%eax
  9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  9e:	31 d2                	xor    %edx,%edx
  a0:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  a3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  a6:	42                   	inc    %edx
  a7:	84 c9                	test   %cl,%cl
  a9:	75 f5                	jne    a0 <strcpy+0xc>
    ;
  return os;
}
  ab:	5b                   	pop    %ebx
  ac:	5d                   	pop    %ebp
  ad:	c3                   	ret    
  ae:	66 90                	xchg   %ax,%ax

000000b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b0:	55                   	push   %ebp
  b1:	89 e5                	mov    %esp,%ebp
  b3:	56                   	push   %esi
  b4:	53                   	push   %ebx
  b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  bb:	8a 01                	mov    (%ecx),%al
  bd:	8a 1a                	mov    (%edx),%bl
  bf:	84 c0                	test   %al,%al
  c1:	74 1d                	je     e0 <strcmp+0x30>
  c3:	38 d8                	cmp    %bl,%al
  c5:	74 0c                	je     d3 <strcmp+0x23>
  c7:	eb 23                	jmp    ec <strcmp+0x3c>
  c9:	8d 76 00             	lea    0x0(%esi),%esi
  cc:	41                   	inc    %ecx
  cd:	38 d8                	cmp    %bl,%al
  cf:	75 1b                	jne    ec <strcmp+0x3c>
    p++, q++;
  d1:	89 f2                	mov    %esi,%edx
  d3:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  d6:	8a 41 01             	mov    0x1(%ecx),%al
  d9:	8a 5a 01             	mov    0x1(%edx),%bl
  dc:	84 c0                	test   %al,%al
  de:	75 ec                	jne    cc <strcmp+0x1c>
  e0:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  e2:	0f b6 db             	movzbl %bl,%ebx
  e5:	29 d8                	sub    %ebx,%eax
}
  e7:	5b                   	pop    %ebx
  e8:	5e                   	pop    %esi
  e9:	5d                   	pop    %ebp
  ea:	c3                   	ret    
  eb:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ec:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  ef:	0f b6 db             	movzbl %bl,%ebx
  f2:	29 d8                	sub    %ebx,%eax
}
  f4:	5b                   	pop    %ebx
  f5:	5e                   	pop    %esi
  f6:	5d                   	pop    %ebp
  f7:	c3                   	ret    

000000f8 <strlen>:

uint
strlen(const char *s)
{
  f8:	55                   	push   %ebp
  f9:	89 e5                	mov    %esp,%ebp
  fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  fe:	80 39 00             	cmpb   $0x0,(%ecx)
 101:	74 10                	je     113 <strlen+0x1b>
 103:	31 d2                	xor    %edx,%edx
 105:	8d 76 00             	lea    0x0(%esi),%esi
 108:	42                   	inc    %edx
 109:	89 d0                	mov    %edx,%eax
 10b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 10f:	75 f7                	jne    108 <strlen+0x10>
    ;
  return n;
}
 111:	5d                   	pop    %ebp
 112:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
 113:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
 115:	5d                   	pop    %ebp
 116:	c3                   	ret    
 117:	90                   	nop

00000118 <memset>:

void*
memset(void *dst, int c, uint n)
{
 118:	55                   	push   %ebp
 119:	89 e5                	mov    %esp,%ebp
 11b:	57                   	push   %edi
 11c:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 11f:	89 d7                	mov    %edx,%edi
 121:	8b 4d 10             	mov    0x10(%ebp),%ecx
 124:	8b 45 0c             	mov    0xc(%ebp),%eax
 127:	fc                   	cld    
 128:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 12a:	89 d0                	mov    %edx,%eax
 12c:	5f                   	pop    %edi
 12d:	5d                   	pop    %ebp
 12e:	c3                   	ret    
 12f:	90                   	nop

00000130 <strchr>:

char*
strchr(const char *s, char c)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
 133:	8b 45 08             	mov    0x8(%ebp),%eax
 136:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 139:	8a 10                	mov    (%eax),%dl
 13b:	84 d2                	test   %dl,%dl
 13d:	75 0d                	jne    14c <strchr+0x1c>
 13f:	eb 13                	jmp    154 <strchr+0x24>
 141:	8d 76 00             	lea    0x0(%esi),%esi
 144:	8a 50 01             	mov    0x1(%eax),%dl
 147:	84 d2                	test   %dl,%dl
 149:	74 09                	je     154 <strchr+0x24>
 14b:	40                   	inc    %eax
    if(*s == c)
 14c:	38 ca                	cmp    %cl,%dl
 14e:	75 f4                	jne    144 <strchr+0x14>
      return (char*)s;
  return 0;
}
 150:	5d                   	pop    %ebp
 151:	c3                   	ret    
 152:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 154:	31 c0                	xor    %eax,%eax
}
 156:	5d                   	pop    %ebp
 157:	c3                   	ret    

00000158 <gets>:

char*
gets(char *buf, int max)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	57                   	push   %edi
 15c:	56                   	push   %esi
 15d:	53                   	push   %ebx
 15e:	83 ec 2c             	sub    $0x2c,%esp
 161:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 164:	31 f6                	xor    %esi,%esi
 166:	eb 30                	jmp    198 <gets+0x40>
    cc = read(0, &c, 1);
 168:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 16f:	00 
 170:	8d 45 e7             	lea    -0x19(%ebp),%eax
 173:	89 44 24 04          	mov    %eax,0x4(%esp)
 177:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 17e:	e8 ed 00 00 00       	call   270 <read>
    if(cc < 1)
 183:	85 c0                	test   %eax,%eax
 185:	7e 19                	jle    1a0 <gets+0x48>
      break;
    buf[i++] = c;
 187:	8a 45 e7             	mov    -0x19(%ebp),%al
 18a:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18e:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 190:	3c 0a                	cmp    $0xa,%al
 192:	74 0c                	je     1a0 <gets+0x48>
 194:	3c 0d                	cmp    $0xd,%al
 196:	74 08                	je     1a0 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 198:	8d 5e 01             	lea    0x1(%esi),%ebx
 19b:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 19e:	7c c8                	jl     168 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1a0:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 1a4:	89 f8                	mov    %edi,%eax
 1a6:	83 c4 2c             	add    $0x2c,%esp
 1a9:	5b                   	pop    %ebx
 1aa:	5e                   	pop    %esi
 1ab:	5f                   	pop    %edi
 1ac:	5d                   	pop    %ebp
 1ad:	c3                   	ret    
 1ae:	66 90                	xchg   %ax,%ax

000001b0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b0:	55                   	push   %ebp
 1b1:	89 e5                	mov    %esp,%ebp
 1b3:	56                   	push   %esi
 1b4:	53                   	push   %ebx
 1b5:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1bf:	00 
 1c0:	8b 45 08             	mov    0x8(%ebp),%eax
 1c3:	89 04 24             	mov    %eax,(%esp)
 1c6:	e8 cd 00 00 00       	call   298 <open>
 1cb:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 1cd:	85 c0                	test   %eax,%eax
 1cf:	78 23                	js     1f4 <stat+0x44>
    return -1;
  r = fstat(fd, st);
 1d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d8:	89 1c 24             	mov    %ebx,(%esp)
 1db:	e8 d0 00 00 00       	call   2b0 <fstat>
 1e0:	89 c6                	mov    %eax,%esi
  close(fd);
 1e2:	89 1c 24             	mov    %ebx,(%esp)
 1e5:	e8 96 00 00 00       	call   280 <close>
  return r;
}
 1ea:	89 f0                	mov    %esi,%eax
 1ec:	83 c4 10             	add    $0x10,%esp
 1ef:	5b                   	pop    %ebx
 1f0:	5e                   	pop    %esi
 1f1:	5d                   	pop    %ebp
 1f2:	c3                   	ret    
 1f3:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 1f4:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1f9:	eb ef                	jmp    1ea <stat+0x3a>
 1fb:	90                   	nop

000001fc <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1fc:	55                   	push   %ebp
 1fd:	89 e5                	mov    %esp,%ebp
 1ff:	53                   	push   %ebx
 200:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 203:	8a 11                	mov    (%ecx),%dl
 205:	8d 42 d0             	lea    -0x30(%edx),%eax
 208:	3c 09                	cmp    $0x9,%al
 20a:	b8 00 00 00 00       	mov    $0x0,%eax
 20f:	77 18                	ja     229 <atoi+0x2d>
 211:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 214:	8d 04 80             	lea    (%eax,%eax,4),%eax
 217:	0f be d2             	movsbl %dl,%edx
 21a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 21e:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21f:	8a 11                	mov    (%ecx),%dl
 221:	8d 5a d0             	lea    -0x30(%edx),%ebx
 224:	80 fb 09             	cmp    $0x9,%bl
 227:	76 eb                	jbe    214 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 229:	5b                   	pop    %ebx
 22a:	5d                   	pop    %ebp
 22b:	c3                   	ret    

0000022c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 22c:	55                   	push   %ebp
 22d:	89 e5                	mov    %esp,%ebp
 22f:	56                   	push   %esi
 230:	53                   	push   %ebx
 231:	8b 45 08             	mov    0x8(%ebp),%eax
 234:	8b 75 0c             	mov    0xc(%ebp),%esi
 237:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 23a:	85 db                	test   %ebx,%ebx
 23c:	7e 0d                	jle    24b <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 23e:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 240:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 243:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 246:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 247:	39 da                	cmp    %ebx,%edx
 249:	75 f5                	jne    240 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 24b:	5b                   	pop    %ebx
 24c:	5e                   	pop    %esi
 24d:	5d                   	pop    %ebp
 24e:	c3                   	ret    
 24f:	90                   	nop

00000250 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 250:	b8 01 00 00 00       	mov    $0x1,%eax
 255:	cd 40                	int    $0x40
 257:	c3                   	ret    

00000258 <exit>:
SYSCALL(exit)
 258:	b8 02 00 00 00       	mov    $0x2,%eax
 25d:	cd 40                	int    $0x40
 25f:	c3                   	ret    

00000260 <wait>:
SYSCALL(wait)
 260:	b8 03 00 00 00       	mov    $0x3,%eax
 265:	cd 40                	int    $0x40
 267:	c3                   	ret    

00000268 <pipe>:
SYSCALL(pipe)
 268:	b8 04 00 00 00       	mov    $0x4,%eax
 26d:	cd 40                	int    $0x40
 26f:	c3                   	ret    

00000270 <read>:
SYSCALL(read)
 270:	b8 05 00 00 00       	mov    $0x5,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <write>:
SYSCALL(write)
 278:	b8 10 00 00 00       	mov    $0x10,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <close>:
SYSCALL(close)
 280:	b8 15 00 00 00       	mov    $0x15,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <kill>:
SYSCALL(kill)
 288:	b8 06 00 00 00       	mov    $0x6,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <exec>:
SYSCALL(exec)
 290:	b8 07 00 00 00       	mov    $0x7,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <open>:
SYSCALL(open)
 298:	b8 0f 00 00 00       	mov    $0xf,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <mknod>:
SYSCALL(mknod)
 2a0:	b8 11 00 00 00       	mov    $0x11,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <unlink>:
SYSCALL(unlink)
 2a8:	b8 12 00 00 00       	mov    $0x12,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <fstat>:
SYSCALL(fstat)
 2b0:	b8 08 00 00 00       	mov    $0x8,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <link>:
SYSCALL(link)
 2b8:	b8 13 00 00 00       	mov    $0x13,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <mkdir>:
SYSCALL(mkdir)
 2c0:	b8 14 00 00 00       	mov    $0x14,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <chdir>:
SYSCALL(chdir)
 2c8:	b8 09 00 00 00       	mov    $0x9,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <dup>:
SYSCALL(dup)
 2d0:	b8 0a 00 00 00       	mov    $0xa,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <getpid>:
SYSCALL(getpid)
 2d8:	b8 0b 00 00 00       	mov    $0xb,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <sbrk>:
SYSCALL(sbrk)
 2e0:	b8 0c 00 00 00       	mov    $0xc,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <sleep>:
SYSCALL(sleep)
 2e8:	b8 0d 00 00 00       	mov    $0xd,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <uptime>:
SYSCALL(uptime)
 2f0:	b8 0e 00 00 00       	mov    $0xe,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <alarm>:
SYSCALL(alarm)
 2f8:	b8 16 00 00 00       	mov    $0x16,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	83 ec 28             	sub    $0x28,%esp
 306:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 309:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 310:	00 
 311:	8d 55 f4             	lea    -0xc(%ebp),%edx
 314:	89 54 24 04          	mov    %edx,0x4(%esp)
 318:	89 04 24             	mov    %eax,(%esp)
 31b:	e8 58 ff ff ff       	call   278 <write>
}
 320:	c9                   	leave  
 321:	c3                   	ret    
 322:	66 90                	xchg   %ax,%ax

00000324 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 324:	55                   	push   %ebp
 325:	89 e5                	mov    %esp,%ebp
 327:	57                   	push   %edi
 328:	56                   	push   %esi
 329:	53                   	push   %ebx
 32a:	83 ec 1c             	sub    $0x1c,%esp
 32d:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 32f:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 331:	8b 5d 08             	mov    0x8(%ebp),%ebx
 334:	85 db                	test   %ebx,%ebx
 336:	74 04                	je     33c <printint+0x18>
 338:	85 d2                	test   %edx,%edx
 33a:	78 4a                	js     386 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 33c:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 33e:	31 db                	xor    %ebx,%ebx
 340:	eb 04                	jmp    346 <printint+0x22>
 342:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 344:	89 d3                	mov    %edx,%ebx
 346:	31 d2                	xor    %edx,%edx
 348:	f7 f1                	div    %ecx
 34a:	8a 92 47 06 00 00    	mov    0x647(%edx),%dl
 350:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 354:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 357:	85 c0                	test   %eax,%eax
 359:	75 e9                	jne    344 <printint+0x20>
  if(neg)
 35b:	85 ff                	test   %edi,%edi
 35d:	74 08                	je     367 <printint+0x43>
    buf[i++] = '-';
 35f:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 364:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 367:	8d 5a ff             	lea    -0x1(%edx),%ebx
 36a:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 36c:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 371:	89 f0                	mov    %esi,%eax
 373:	e8 88 ff ff ff       	call   300 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 378:	4b                   	dec    %ebx
 379:	83 fb ff             	cmp    $0xffffffff,%ebx
 37c:	75 ee                	jne    36c <printint+0x48>
    putc(fd, buf[i]);
}
 37e:	83 c4 1c             	add    $0x1c,%esp
 381:	5b                   	pop    %ebx
 382:	5e                   	pop    %esi
 383:	5f                   	pop    %edi
 384:	5d                   	pop    %ebp
 385:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 386:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 388:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 38d:	eb af                	jmp    33e <printint+0x1a>
 38f:	90                   	nop

00000390 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 390:	55                   	push   %ebp
 391:	89 e5                	mov    %esp,%ebp
 393:	57                   	push   %edi
 394:	56                   	push   %esi
 395:	53                   	push   %ebx
 396:	83 ec 2c             	sub    $0x2c,%esp
 399:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 39c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 39f:	8a 0b                	mov    (%ebx),%cl
 3a1:	84 c9                	test   %cl,%cl
 3a3:	74 7b                	je     420 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3a5:	8d 45 10             	lea    0x10(%ebp),%eax
 3a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 3ab:	31 f6                	xor    %esi,%esi
 3ad:	eb 17                	jmp    3c6 <printf+0x36>
 3af:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 3b0:	83 f9 25             	cmp    $0x25,%ecx
 3b3:	74 73                	je     428 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 3b5:	0f be d1             	movsbl %cl,%edx
 3b8:	89 f8                	mov    %edi,%eax
 3ba:	e8 41 ff ff ff       	call   300 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 3bf:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3c0:	8a 0b                	mov    (%ebx),%cl
 3c2:	84 c9                	test   %cl,%cl
 3c4:	74 5a                	je     420 <printf+0x90>
    c = fmt[i] & 0xff;
 3c6:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 3c9:	85 f6                	test   %esi,%esi
 3cb:	74 e3                	je     3b0 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 3cd:	83 fe 25             	cmp    $0x25,%esi
 3d0:	75 ed                	jne    3bf <printf+0x2f>
      if(c == 'd'){
 3d2:	83 f9 64             	cmp    $0x64,%ecx
 3d5:	0f 84 c1 00 00 00    	je     49c <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3db:	83 f9 78             	cmp    $0x78,%ecx
 3de:	74 50                	je     430 <printf+0xa0>
 3e0:	83 f9 70             	cmp    $0x70,%ecx
 3e3:	74 4b                	je     430 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3e5:	83 f9 73             	cmp    $0x73,%ecx
 3e8:	74 6a                	je     454 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3ea:	83 f9 63             	cmp    $0x63,%ecx
 3ed:	0f 84 91 00 00 00    	je     484 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 3f3:	ba 25 00 00 00       	mov    $0x25,%edx
 3f8:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3fa:	83 f9 25             	cmp    $0x25,%ecx
 3fd:	74 10                	je     40f <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 402:	e8 f9 fe ff ff       	call   300 <putc>
        putc(fd, c);
 407:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 40a:	0f be d1             	movsbl %cl,%edx
 40d:	89 f8                	mov    %edi,%eax
 40f:	e8 ec fe ff ff       	call   300 <putc>
      }
      state = 0;
 414:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 416:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 417:	8a 0b                	mov    (%ebx),%cl
 419:	84 c9                	test   %cl,%cl
 41b:	75 a9                	jne    3c6 <printf+0x36>
 41d:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 420:	83 c4 2c             	add    $0x2c,%esp
 423:	5b                   	pop    %ebx
 424:	5e                   	pop    %esi
 425:	5f                   	pop    %edi
 426:	5d                   	pop    %ebp
 427:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 428:	be 25 00 00 00       	mov    $0x25,%esi
 42d:	eb 90                	jmp    3bf <printf+0x2f>
 42f:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 430:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 437:	b9 10 00 00 00       	mov    $0x10,%ecx
 43c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 43f:	8b 10                	mov    (%eax),%edx
 441:	89 f8                	mov    %edi,%eax
 443:	e8 dc fe ff ff       	call   324 <printint>
        ap++;
 448:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 44c:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 44e:	e9 6c ff ff ff       	jmp    3bf <printf+0x2f>
 453:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 454:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 457:	8b 30                	mov    (%eax),%esi
        ap++;
 459:	83 c0 04             	add    $0x4,%eax
 45c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 45f:	85 f6                	test   %esi,%esi
 461:	74 5a                	je     4bd <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 463:	8a 16                	mov    (%esi),%dl
 465:	84 d2                	test   %dl,%dl
 467:	74 14                	je     47d <printf+0xed>
 469:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 46c:	0f be d2             	movsbl %dl,%edx
 46f:	89 f8                	mov    %edi,%eax
 471:	e8 8a fe ff ff       	call   300 <putc>
          s++;
 476:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 477:	8a 16                	mov    (%esi),%dl
 479:	84 d2                	test   %dl,%dl
 47b:	75 ef                	jne    46c <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 47d:	31 f6                	xor    %esi,%esi
 47f:	e9 3b ff ff ff       	jmp    3bf <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 484:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 487:	0f be 10             	movsbl (%eax),%edx
 48a:	89 f8                	mov    %edi,%eax
 48c:	e8 6f fe ff ff       	call   300 <putc>
        ap++;
 491:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 495:	31 f6                	xor    %esi,%esi
 497:	e9 23 ff ff ff       	jmp    3bf <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 49c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4a3:	b1 0a                	mov    $0xa,%cl
 4a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4a8:	8b 10                	mov    (%eax),%edx
 4aa:	89 f8                	mov    %edi,%eax
 4ac:	e8 73 fe ff ff       	call   324 <printint>
        ap++;
 4b1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4b5:	66 31 f6             	xor    %si,%si
 4b8:	e9 02 ff ff ff       	jmp    3bf <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 4bd:	be 40 06 00 00       	mov    $0x640,%esi
 4c2:	eb 9f                	jmp    463 <printf+0xd3>

000004c4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4c4:	55                   	push   %ebp
 4c5:	89 e5                	mov    %esp,%ebp
 4c7:	57                   	push   %edi
 4c8:	56                   	push   %esi
 4c9:	53                   	push   %ebx
 4ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4cd:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4d0:	a1 1c 09 00 00       	mov    0x91c,%eax
 4d5:	8d 76 00             	lea    0x0(%esi),%esi
 4d8:	8b 10                	mov    (%eax),%edx
 4da:	39 c8                	cmp    %ecx,%eax
 4dc:	73 04                	jae    4e2 <free+0x1e>
 4de:	39 d1                	cmp    %edx,%ecx
 4e0:	72 12                	jb     4f4 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4e2:	39 d0                	cmp    %edx,%eax
 4e4:	72 08                	jb     4ee <free+0x2a>
 4e6:	39 c8                	cmp    %ecx,%eax
 4e8:	72 0a                	jb     4f4 <free+0x30>
 4ea:	39 d1                	cmp    %edx,%ecx
 4ec:	72 06                	jb     4f4 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 4ee:	89 d0                	mov    %edx,%eax
 4f0:	eb e6                	jmp    4d8 <free+0x14>
 4f2:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 4f4:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4f7:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4fa:	39 d7                	cmp    %edx,%edi
 4fc:	74 19                	je     517 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4fe:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 501:	8b 50 04             	mov    0x4(%eax),%edx
 504:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 507:	39 f1                	cmp    %esi,%ecx
 509:	74 23                	je     52e <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 50b:	89 08                	mov    %ecx,(%eax)
  freep = p;
 50d:	a3 1c 09 00 00       	mov    %eax,0x91c
}
 512:	5b                   	pop    %ebx
 513:	5e                   	pop    %esi
 514:	5f                   	pop    %edi
 515:	5d                   	pop    %ebp
 516:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 517:	03 72 04             	add    0x4(%edx),%esi
 51a:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 51d:	8b 10                	mov    (%eax),%edx
 51f:	8b 12                	mov    (%edx),%edx
 521:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 524:	8b 50 04             	mov    0x4(%eax),%edx
 527:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 52a:	39 f1                	cmp    %esi,%ecx
 52c:	75 dd                	jne    50b <free+0x47>
    p->s.size += bp->s.size;
 52e:	03 53 fc             	add    -0x4(%ebx),%edx
 531:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 534:	8b 53 f8             	mov    -0x8(%ebx),%edx
 537:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 539:	a3 1c 09 00 00       	mov    %eax,0x91c
}
 53e:	5b                   	pop    %ebx
 53f:	5e                   	pop    %esi
 540:	5f                   	pop    %edi
 541:	5d                   	pop    %ebp
 542:	c3                   	ret    
 543:	90                   	nop

00000544 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 544:	55                   	push   %ebp
 545:	89 e5                	mov    %esp,%ebp
 547:	57                   	push   %edi
 548:	56                   	push   %esi
 549:	53                   	push   %ebx
 54a:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 54d:	8b 5d 08             	mov    0x8(%ebp),%ebx
 550:	83 c3 07             	add    $0x7,%ebx
 553:	c1 eb 03             	shr    $0x3,%ebx
 556:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 557:	8b 0d 1c 09 00 00    	mov    0x91c,%ecx
 55d:	85 c9                	test   %ecx,%ecx
 55f:	0f 84 95 00 00 00    	je     5fa <malloc+0xb6>
 565:	8b 01                	mov    (%ecx),%eax
 567:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 56a:	39 da                	cmp    %ebx,%edx
 56c:	73 66                	jae    5d4 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 56e:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 575:	eb 0c                	jmp    583 <malloc+0x3f>
 577:	90                   	nop
    }
    if(p == freep)
 578:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 57a:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 57c:	8b 50 04             	mov    0x4(%eax),%edx
 57f:	39 d3                	cmp    %edx,%ebx
 581:	76 51                	jbe    5d4 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 583:	3b 05 1c 09 00 00    	cmp    0x91c,%eax
 589:	75 ed                	jne    578 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 58b:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 591:	76 35                	jbe    5c8 <malloc+0x84>
 593:	89 f8                	mov    %edi,%eax
 595:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 597:	89 04 24             	mov    %eax,(%esp)
 59a:	e8 41 fd ff ff       	call   2e0 <sbrk>
  if(p == (char*)-1)
 59f:	83 f8 ff             	cmp    $0xffffffff,%eax
 5a2:	74 18                	je     5bc <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5a4:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 5a7:	83 c0 08             	add    $0x8,%eax
 5aa:	89 04 24             	mov    %eax,(%esp)
 5ad:	e8 12 ff ff ff       	call   4c4 <free>
  return freep;
 5b2:	8b 0d 1c 09 00 00    	mov    0x91c,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 5b8:	85 c9                	test   %ecx,%ecx
 5ba:	75 be                	jne    57a <malloc+0x36>
        return 0;
 5bc:	31 c0                	xor    %eax,%eax
  }
}
 5be:	83 c4 1c             	add    $0x1c,%esp
 5c1:	5b                   	pop    %ebx
 5c2:	5e                   	pop    %esi
 5c3:	5f                   	pop    %edi
 5c4:	5d                   	pop    %ebp
 5c5:	c3                   	ret    
 5c6:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 5c8:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 5cd:	be 00 10 00 00       	mov    $0x1000,%esi
 5d2:	eb c3                	jmp    597 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5d4:	39 d3                	cmp    %edx,%ebx
 5d6:	74 1c                	je     5f4 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5d8:	29 da                	sub    %ebx,%edx
 5da:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5dd:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5e0:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5e3:	89 0d 1c 09 00 00    	mov    %ecx,0x91c
      return (void*)(p + 1);
 5e9:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5ec:	83 c4 1c             	add    $0x1c,%esp
 5ef:	5b                   	pop    %ebx
 5f0:	5e                   	pop    %esi
 5f1:	5f                   	pop    %edi
 5f2:	5d                   	pop    %ebp
 5f3:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 5f4:	8b 10                	mov    (%eax),%edx
 5f6:	89 11                	mov    %edx,(%ecx)
 5f8:	eb e9                	jmp    5e3 <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 5fa:	c7 05 1c 09 00 00 20 	movl   $0x920,0x91c
 601:	09 00 00 
 604:	c7 05 20 09 00 00 20 	movl   $0x920,0x920
 60b:	09 00 00 
    base.s.size = 0;
 60e:	c7 05 24 09 00 00 00 	movl   $0x0,0x924
 615:	00 00 00 
 618:	b8 20 09 00 00       	mov    $0x920,%eax
 61d:	e9 4c ff ff ff       	jmp    56e <malloc+0x2a>
