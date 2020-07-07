
_echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	83 ec 10             	sub    $0x10,%esp
   c:	8b 75 08             	mov    0x8(%ebp),%esi
   f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  for(i = 1; i < argc; i++)
  12:	83 fe 01             	cmp    $0x1,%esi
  15:	7e 5a                	jle    71 <main+0x71>
  17:	bb 01 00 00 00       	mov    $0x1,%ebx
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  1c:	43                   	inc    %ebx
  1d:	39 f3                	cmp    %esi,%ebx
  1f:	74 2c                	je     4d <main+0x4d>
  21:	8d 76 00             	lea    0x0(%esi),%esi
  24:	c7 44 24 0c 06 06 00 	movl   $0x606,0xc(%esp)
  2b:	00 
  2c:	8b 44 9f fc          	mov    -0x4(%edi,%ebx,4),%eax
  30:	89 44 24 08          	mov    %eax,0x8(%esp)
  34:	c7 44 24 04 08 06 00 	movl   $0x608,0x4(%esp)
  3b:	00 
  3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  43:	e8 2c 03 00 00       	call   374 <printf>
  48:	43                   	inc    %ebx
  49:	39 f3                	cmp    %esi,%ebx
  4b:	75 d7                	jne    24 <main+0x24>
  4d:	c7 44 24 0c 0d 06 00 	movl   $0x60d,0xc(%esp)
  54:	00 
  55:	8b 44 9f fc          	mov    -0x4(%edi,%ebx,4),%eax
  59:	89 44 24 08          	mov    %eax,0x8(%esp)
  5d:	c7 44 24 04 08 06 00 	movl   $0x608,0x4(%esp)
  64:	00 
  65:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  6c:	e8 03 03 00 00       	call   374 <printf>
  exit();
  71:	e8 c6 01 00 00       	call   23c <exit>
  76:	90                   	nop
  77:	90                   	nop

00000078 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  78:	55                   	push   %ebp
  79:	89 e5                	mov    %esp,%ebp
  7b:	53                   	push   %ebx
  7c:	8b 45 08             	mov    0x8(%ebp),%eax
  7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  82:	31 d2                	xor    %edx,%edx
  84:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  87:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8a:	42                   	inc    %edx
  8b:	84 c9                	test   %cl,%cl
  8d:	75 f5                	jne    84 <strcpy+0xc>
    ;
  return os;
}
  8f:	5b                   	pop    %ebx
  90:	5d                   	pop    %ebp
  91:	c3                   	ret    
  92:	66 90                	xchg   %ax,%ax

00000094 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  94:	55                   	push   %ebp
  95:	89 e5                	mov    %esp,%ebp
  97:	56                   	push   %esi
  98:	53                   	push   %ebx
  99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  9f:	8a 01                	mov    (%ecx),%al
  a1:	8a 1a                	mov    (%edx),%bl
  a3:	84 c0                	test   %al,%al
  a5:	74 1d                	je     c4 <strcmp+0x30>
  a7:	38 d8                	cmp    %bl,%al
  a9:	74 0c                	je     b7 <strcmp+0x23>
  ab:	eb 23                	jmp    d0 <strcmp+0x3c>
  ad:	8d 76 00             	lea    0x0(%esi),%esi
  b0:	41                   	inc    %ecx
  b1:	38 d8                	cmp    %bl,%al
  b3:	75 1b                	jne    d0 <strcmp+0x3c>
    p++, q++;
  b5:	89 f2                	mov    %esi,%edx
  b7:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ba:	8a 41 01             	mov    0x1(%ecx),%al
  bd:	8a 5a 01             	mov    0x1(%edx),%bl
  c0:	84 c0                	test   %al,%al
  c2:	75 ec                	jne    b0 <strcmp+0x1c>
  c4:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  c6:	0f b6 db             	movzbl %bl,%ebx
  c9:	29 d8                	sub    %ebx,%eax
}
  cb:	5b                   	pop    %ebx
  cc:	5e                   	pop    %esi
  cd:	5d                   	pop    %ebp
  ce:	c3                   	ret    
  cf:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  d0:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  d3:	0f b6 db             	movzbl %bl,%ebx
  d6:	29 d8                	sub    %ebx,%eax
}
  d8:	5b                   	pop    %ebx
  d9:	5e                   	pop    %esi
  da:	5d                   	pop    %ebp
  db:	c3                   	ret    

000000dc <strlen>:

uint
strlen(const char *s)
{
  dc:	55                   	push   %ebp
  dd:	89 e5                	mov    %esp,%ebp
  df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  e2:	80 39 00             	cmpb   $0x0,(%ecx)
  e5:	74 10                	je     f7 <strlen+0x1b>
  e7:	31 d2                	xor    %edx,%edx
  e9:	8d 76 00             	lea    0x0(%esi),%esi
  ec:	42                   	inc    %edx
  ed:	89 d0                	mov    %edx,%eax
  ef:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  f3:	75 f7                	jne    ec <strlen+0x10>
    ;
  return n;
}
  f5:	5d                   	pop    %ebp
  f6:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
  f7:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
  f9:	5d                   	pop    %ebp
  fa:	c3                   	ret    
  fb:	90                   	nop

000000fc <memset>:

void*
memset(void *dst, int c, uint n)
{
  fc:	55                   	push   %ebp
  fd:	89 e5                	mov    %esp,%ebp
  ff:	57                   	push   %edi
 100:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 103:	89 d7                	mov    %edx,%edi
 105:	8b 4d 10             	mov    0x10(%ebp),%ecx
 108:	8b 45 0c             	mov    0xc(%ebp),%eax
 10b:	fc                   	cld    
 10c:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 10e:	89 d0                	mov    %edx,%eax
 110:	5f                   	pop    %edi
 111:	5d                   	pop    %ebp
 112:	c3                   	ret    
 113:	90                   	nop

00000114 <strchr>:

char*
strchr(const char *s, char c)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	8b 45 08             	mov    0x8(%ebp),%eax
 11a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 11d:	8a 10                	mov    (%eax),%dl
 11f:	84 d2                	test   %dl,%dl
 121:	75 0d                	jne    130 <strchr+0x1c>
 123:	eb 13                	jmp    138 <strchr+0x24>
 125:	8d 76 00             	lea    0x0(%esi),%esi
 128:	8a 50 01             	mov    0x1(%eax),%dl
 12b:	84 d2                	test   %dl,%dl
 12d:	74 09                	je     138 <strchr+0x24>
 12f:	40                   	inc    %eax
    if(*s == c)
 130:	38 ca                	cmp    %cl,%dl
 132:	75 f4                	jne    128 <strchr+0x14>
      return (char*)s;
  return 0;
}
 134:	5d                   	pop    %ebp
 135:	c3                   	ret    
 136:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 138:	31 c0                	xor    %eax,%eax
}
 13a:	5d                   	pop    %ebp
 13b:	c3                   	ret    

0000013c <gets>:

char*
gets(char *buf, int max)
{
 13c:	55                   	push   %ebp
 13d:	89 e5                	mov    %esp,%ebp
 13f:	57                   	push   %edi
 140:	56                   	push   %esi
 141:	53                   	push   %ebx
 142:	83 ec 2c             	sub    $0x2c,%esp
 145:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 148:	31 f6                	xor    %esi,%esi
 14a:	eb 30                	jmp    17c <gets+0x40>
    cc = read(0, &c, 1);
 14c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 153:	00 
 154:	8d 45 e7             	lea    -0x19(%ebp),%eax
 157:	89 44 24 04          	mov    %eax,0x4(%esp)
 15b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 162:	e8 ed 00 00 00       	call   254 <read>
    if(cc < 1)
 167:	85 c0                	test   %eax,%eax
 169:	7e 19                	jle    184 <gets+0x48>
      break;
    buf[i++] = c;
 16b:	8a 45 e7             	mov    -0x19(%ebp),%al
 16e:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 172:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 174:	3c 0a                	cmp    $0xa,%al
 176:	74 0c                	je     184 <gets+0x48>
 178:	3c 0d                	cmp    $0xd,%al
 17a:	74 08                	je     184 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17c:	8d 5e 01             	lea    0x1(%esi),%ebx
 17f:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 182:	7c c8                	jl     14c <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 184:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 188:	89 f8                	mov    %edi,%eax
 18a:	83 c4 2c             	add    $0x2c,%esp
 18d:	5b                   	pop    %ebx
 18e:	5e                   	pop    %esi
 18f:	5f                   	pop    %edi
 190:	5d                   	pop    %ebp
 191:	c3                   	ret    
 192:	66 90                	xchg   %ax,%ax

00000194 <stat>:

int
stat(const char *n, struct stat *st)
{
 194:	55                   	push   %ebp
 195:	89 e5                	mov    %esp,%ebp
 197:	56                   	push   %esi
 198:	53                   	push   %ebx
 199:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1a3:	00 
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
 1a7:	89 04 24             	mov    %eax,(%esp)
 1aa:	e8 cd 00 00 00       	call   27c <open>
 1af:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 1b1:	85 c0                	test   %eax,%eax
 1b3:	78 23                	js     1d8 <stat+0x44>
    return -1;
  r = fstat(fd, st);
 1b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1bc:	89 1c 24             	mov    %ebx,(%esp)
 1bf:	e8 d0 00 00 00       	call   294 <fstat>
 1c4:	89 c6                	mov    %eax,%esi
  close(fd);
 1c6:	89 1c 24             	mov    %ebx,(%esp)
 1c9:	e8 96 00 00 00       	call   264 <close>
  return r;
}
 1ce:	89 f0                	mov    %esi,%eax
 1d0:	83 c4 10             	add    $0x10,%esp
 1d3:	5b                   	pop    %ebx
 1d4:	5e                   	pop    %esi
 1d5:	5d                   	pop    %ebp
 1d6:	c3                   	ret    
 1d7:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 1d8:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1dd:	eb ef                	jmp    1ce <stat+0x3a>
 1df:	90                   	nop

000001e0 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
 1e3:	53                   	push   %ebx
 1e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1e7:	8a 11                	mov    (%ecx),%dl
 1e9:	8d 42 d0             	lea    -0x30(%edx),%eax
 1ec:	3c 09                	cmp    $0x9,%al
 1ee:	b8 00 00 00 00       	mov    $0x0,%eax
 1f3:	77 18                	ja     20d <atoi+0x2d>
 1f5:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 1f8:	8d 04 80             	lea    (%eax,%eax,4),%eax
 1fb:	0f be d2             	movsbl %dl,%edx
 1fe:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 202:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 203:	8a 11                	mov    (%ecx),%dl
 205:	8d 5a d0             	lea    -0x30(%edx),%ebx
 208:	80 fb 09             	cmp    $0x9,%bl
 20b:	76 eb                	jbe    1f8 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 20d:	5b                   	pop    %ebx
 20e:	5d                   	pop    %ebp
 20f:	c3                   	ret    

00000210 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 210:	55                   	push   %ebp
 211:	89 e5                	mov    %esp,%ebp
 213:	56                   	push   %esi
 214:	53                   	push   %ebx
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	8b 75 0c             	mov    0xc(%ebp),%esi
 21b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 21e:	85 db                	test   %ebx,%ebx
 220:	7e 0d                	jle    22f <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 222:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 224:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 227:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 22a:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 22b:	39 da                	cmp    %ebx,%edx
 22d:	75 f5                	jne    224 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 22f:	5b                   	pop    %ebx
 230:	5e                   	pop    %esi
 231:	5d                   	pop    %ebp
 232:	c3                   	ret    
 233:	90                   	nop

00000234 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 234:	b8 01 00 00 00       	mov    $0x1,%eax
 239:	cd 40                	int    $0x40
 23b:	c3                   	ret    

0000023c <exit>:
SYSCALL(exit)
 23c:	b8 02 00 00 00       	mov    $0x2,%eax
 241:	cd 40                	int    $0x40
 243:	c3                   	ret    

00000244 <wait>:
SYSCALL(wait)
 244:	b8 03 00 00 00       	mov    $0x3,%eax
 249:	cd 40                	int    $0x40
 24b:	c3                   	ret    

0000024c <pipe>:
SYSCALL(pipe)
 24c:	b8 04 00 00 00       	mov    $0x4,%eax
 251:	cd 40                	int    $0x40
 253:	c3                   	ret    

00000254 <read>:
SYSCALL(read)
 254:	b8 05 00 00 00       	mov    $0x5,%eax
 259:	cd 40                	int    $0x40
 25b:	c3                   	ret    

0000025c <write>:
SYSCALL(write)
 25c:	b8 10 00 00 00       	mov    $0x10,%eax
 261:	cd 40                	int    $0x40
 263:	c3                   	ret    

00000264 <close>:
SYSCALL(close)
 264:	b8 15 00 00 00       	mov    $0x15,%eax
 269:	cd 40                	int    $0x40
 26b:	c3                   	ret    

0000026c <kill>:
SYSCALL(kill)
 26c:	b8 06 00 00 00       	mov    $0x6,%eax
 271:	cd 40                	int    $0x40
 273:	c3                   	ret    

00000274 <exec>:
SYSCALL(exec)
 274:	b8 07 00 00 00       	mov    $0x7,%eax
 279:	cd 40                	int    $0x40
 27b:	c3                   	ret    

0000027c <open>:
SYSCALL(open)
 27c:	b8 0f 00 00 00       	mov    $0xf,%eax
 281:	cd 40                	int    $0x40
 283:	c3                   	ret    

00000284 <mknod>:
SYSCALL(mknod)
 284:	b8 11 00 00 00       	mov    $0x11,%eax
 289:	cd 40                	int    $0x40
 28b:	c3                   	ret    

0000028c <unlink>:
SYSCALL(unlink)
 28c:	b8 12 00 00 00       	mov    $0x12,%eax
 291:	cd 40                	int    $0x40
 293:	c3                   	ret    

00000294 <fstat>:
SYSCALL(fstat)
 294:	b8 08 00 00 00       	mov    $0x8,%eax
 299:	cd 40                	int    $0x40
 29b:	c3                   	ret    

0000029c <link>:
SYSCALL(link)
 29c:	b8 13 00 00 00       	mov    $0x13,%eax
 2a1:	cd 40                	int    $0x40
 2a3:	c3                   	ret    

000002a4 <mkdir>:
SYSCALL(mkdir)
 2a4:	b8 14 00 00 00       	mov    $0x14,%eax
 2a9:	cd 40                	int    $0x40
 2ab:	c3                   	ret    

000002ac <chdir>:
SYSCALL(chdir)
 2ac:	b8 09 00 00 00       	mov    $0x9,%eax
 2b1:	cd 40                	int    $0x40
 2b3:	c3                   	ret    

000002b4 <dup>:
SYSCALL(dup)
 2b4:	b8 0a 00 00 00       	mov    $0xa,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <getpid>:
SYSCALL(getpid)
 2bc:	b8 0b 00 00 00       	mov    $0xb,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <sbrk>:
SYSCALL(sbrk)
 2c4:	b8 0c 00 00 00       	mov    $0xc,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <sleep>:
SYSCALL(sleep)
 2cc:	b8 0d 00 00 00       	mov    $0xd,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <uptime>:
SYSCALL(uptime)
 2d4:	b8 0e 00 00 00       	mov    $0xe,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <alarm>:
SYSCALL(alarm)
 2dc:	b8 16 00 00 00       	mov    $0x16,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2e4:	55                   	push   %ebp
 2e5:	89 e5                	mov    %esp,%ebp
 2e7:	83 ec 28             	sub    $0x28,%esp
 2ea:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2f4:	00 
 2f5:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2f8:	89 54 24 04          	mov    %edx,0x4(%esp)
 2fc:	89 04 24             	mov    %eax,(%esp)
 2ff:	e8 58 ff ff ff       	call   25c <write>
}
 304:	c9                   	leave  
 305:	c3                   	ret    
 306:	66 90                	xchg   %ax,%ax

00000308 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 308:	55                   	push   %ebp
 309:	89 e5                	mov    %esp,%ebp
 30b:	57                   	push   %edi
 30c:	56                   	push   %esi
 30d:	53                   	push   %ebx
 30e:	83 ec 1c             	sub    $0x1c,%esp
 311:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 313:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 315:	8b 5d 08             	mov    0x8(%ebp),%ebx
 318:	85 db                	test   %ebx,%ebx
 31a:	74 04                	je     320 <printint+0x18>
 31c:	85 d2                	test   %edx,%edx
 31e:	78 4a                	js     36a <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 320:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 322:	31 db                	xor    %ebx,%ebx
 324:	eb 04                	jmp    32a <printint+0x22>
 326:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 328:	89 d3                	mov    %edx,%ebx
 32a:	31 d2                	xor    %edx,%edx
 32c:	f7 f1                	div    %ecx
 32e:	8a 92 16 06 00 00    	mov    0x616(%edx),%dl
 334:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 338:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 33b:	85 c0                	test   %eax,%eax
 33d:	75 e9                	jne    328 <printint+0x20>
  if(neg)
 33f:	85 ff                	test   %edi,%edi
 341:	74 08                	je     34b <printint+0x43>
    buf[i++] = '-';
 343:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 348:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 34b:	8d 5a ff             	lea    -0x1(%edx),%ebx
 34e:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 350:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 355:	89 f0                	mov    %esi,%eax
 357:	e8 88 ff ff ff       	call   2e4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 35c:	4b                   	dec    %ebx
 35d:	83 fb ff             	cmp    $0xffffffff,%ebx
 360:	75 ee                	jne    350 <printint+0x48>
    putc(fd, buf[i]);
}
 362:	83 c4 1c             	add    $0x1c,%esp
 365:	5b                   	pop    %ebx
 366:	5e                   	pop    %esi
 367:	5f                   	pop    %edi
 368:	5d                   	pop    %ebp
 369:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 36a:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 36c:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 371:	eb af                	jmp    322 <printint+0x1a>
 373:	90                   	nop

00000374 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 374:	55                   	push   %ebp
 375:	89 e5                	mov    %esp,%ebp
 377:	57                   	push   %edi
 378:	56                   	push   %esi
 379:	53                   	push   %ebx
 37a:	83 ec 2c             	sub    $0x2c,%esp
 37d:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 380:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 383:	8a 0b                	mov    (%ebx),%cl
 385:	84 c9                	test   %cl,%cl
 387:	74 7b                	je     404 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 389:	8d 45 10             	lea    0x10(%ebp),%eax
 38c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 38f:	31 f6                	xor    %esi,%esi
 391:	eb 17                	jmp    3aa <printf+0x36>
 393:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 394:	83 f9 25             	cmp    $0x25,%ecx
 397:	74 73                	je     40c <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 399:	0f be d1             	movsbl %cl,%edx
 39c:	89 f8                	mov    %edi,%eax
 39e:	e8 41 ff ff ff       	call   2e4 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 3a3:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3a4:	8a 0b                	mov    (%ebx),%cl
 3a6:	84 c9                	test   %cl,%cl
 3a8:	74 5a                	je     404 <printf+0x90>
    c = fmt[i] & 0xff;
 3aa:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 3ad:	85 f6                	test   %esi,%esi
 3af:	74 e3                	je     394 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 3b1:	83 fe 25             	cmp    $0x25,%esi
 3b4:	75 ed                	jne    3a3 <printf+0x2f>
      if(c == 'd'){
 3b6:	83 f9 64             	cmp    $0x64,%ecx
 3b9:	0f 84 c1 00 00 00    	je     480 <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3bf:	83 f9 78             	cmp    $0x78,%ecx
 3c2:	74 50                	je     414 <printf+0xa0>
 3c4:	83 f9 70             	cmp    $0x70,%ecx
 3c7:	74 4b                	je     414 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3c9:	83 f9 73             	cmp    $0x73,%ecx
 3cc:	74 6a                	je     438 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3ce:	83 f9 63             	cmp    $0x63,%ecx
 3d1:	0f 84 91 00 00 00    	je     468 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 3d7:	ba 25 00 00 00       	mov    $0x25,%edx
 3dc:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3de:	83 f9 25             	cmp    $0x25,%ecx
 3e1:	74 10                	je     3f3 <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3e3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 3e6:	e8 f9 fe ff ff       	call   2e4 <putc>
        putc(fd, c);
 3eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 3ee:	0f be d1             	movsbl %cl,%edx
 3f1:	89 f8                	mov    %edi,%eax
 3f3:	e8 ec fe ff ff       	call   2e4 <putc>
      }
      state = 0;
 3f8:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 3fa:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3fb:	8a 0b                	mov    (%ebx),%cl
 3fd:	84 c9                	test   %cl,%cl
 3ff:	75 a9                	jne    3aa <printf+0x36>
 401:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 404:	83 c4 2c             	add    $0x2c,%esp
 407:	5b                   	pop    %ebx
 408:	5e                   	pop    %esi
 409:	5f                   	pop    %edi
 40a:	5d                   	pop    %ebp
 40b:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 40c:	be 25 00 00 00       	mov    $0x25,%esi
 411:	eb 90                	jmp    3a3 <printf+0x2f>
 413:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 414:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 41b:	b9 10 00 00 00       	mov    $0x10,%ecx
 420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 423:	8b 10                	mov    (%eax),%edx
 425:	89 f8                	mov    %edi,%eax
 427:	e8 dc fe ff ff       	call   308 <printint>
        ap++;
 42c:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 430:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 432:	e9 6c ff ff ff       	jmp    3a3 <printf+0x2f>
 437:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 438:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 43b:	8b 30                	mov    (%eax),%esi
        ap++;
 43d:	83 c0 04             	add    $0x4,%eax
 440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 443:	85 f6                	test   %esi,%esi
 445:	74 5a                	je     4a1 <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 447:	8a 16                	mov    (%esi),%dl
 449:	84 d2                	test   %dl,%dl
 44b:	74 14                	je     461 <printf+0xed>
 44d:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 450:	0f be d2             	movsbl %dl,%edx
 453:	89 f8                	mov    %edi,%eax
 455:	e8 8a fe ff ff       	call   2e4 <putc>
          s++;
 45a:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 45b:	8a 16                	mov    (%esi),%dl
 45d:	84 d2                	test   %dl,%dl
 45f:	75 ef                	jne    450 <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 461:	31 f6                	xor    %esi,%esi
 463:	e9 3b ff ff ff       	jmp    3a3 <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 468:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 46b:	0f be 10             	movsbl (%eax),%edx
 46e:	89 f8                	mov    %edi,%eax
 470:	e8 6f fe ff ff       	call   2e4 <putc>
        ap++;
 475:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 479:	31 f6                	xor    %esi,%esi
 47b:	e9 23 ff ff ff       	jmp    3a3 <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 480:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 487:	b1 0a                	mov    $0xa,%cl
 489:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 48c:	8b 10                	mov    (%eax),%edx
 48e:	89 f8                	mov    %edi,%eax
 490:	e8 73 fe ff ff       	call   308 <printint>
        ap++;
 495:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 499:	66 31 f6             	xor    %si,%si
 49c:	e9 02 ff ff ff       	jmp    3a3 <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 4a1:	be 0f 06 00 00       	mov    $0x60f,%esi
 4a6:	eb 9f                	jmp    447 <printf+0xd3>

000004a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4a8:	55                   	push   %ebp
 4a9:	89 e5                	mov    %esp,%ebp
 4ab:	57                   	push   %edi
 4ac:	56                   	push   %esi
 4ad:	53                   	push   %ebx
 4ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4b1:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4b4:	a1 cc 08 00 00       	mov    0x8cc,%eax
 4b9:	8d 76 00             	lea    0x0(%esi),%esi
 4bc:	8b 10                	mov    (%eax),%edx
 4be:	39 c8                	cmp    %ecx,%eax
 4c0:	73 04                	jae    4c6 <free+0x1e>
 4c2:	39 d1                	cmp    %edx,%ecx
 4c4:	72 12                	jb     4d8 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4c6:	39 d0                	cmp    %edx,%eax
 4c8:	72 08                	jb     4d2 <free+0x2a>
 4ca:	39 c8                	cmp    %ecx,%eax
 4cc:	72 0a                	jb     4d8 <free+0x30>
 4ce:	39 d1                	cmp    %edx,%ecx
 4d0:	72 06                	jb     4d8 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 4d2:	89 d0                	mov    %edx,%eax
 4d4:	eb e6                	jmp    4bc <free+0x14>
 4d6:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 4d8:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4db:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4de:	39 d7                	cmp    %edx,%edi
 4e0:	74 19                	je     4fb <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4e2:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4e5:	8b 50 04             	mov    0x4(%eax),%edx
 4e8:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4eb:	39 f1                	cmp    %esi,%ecx
 4ed:	74 23                	je     512 <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4ef:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4f1:	a3 cc 08 00 00       	mov    %eax,0x8cc
}
 4f6:	5b                   	pop    %ebx
 4f7:	5e                   	pop    %esi
 4f8:	5f                   	pop    %edi
 4f9:	5d                   	pop    %ebp
 4fa:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 4fb:	03 72 04             	add    0x4(%edx),%esi
 4fe:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 501:	8b 10                	mov    (%eax),%edx
 503:	8b 12                	mov    (%edx),%edx
 505:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 508:	8b 50 04             	mov    0x4(%eax),%edx
 50b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 50e:	39 f1                	cmp    %esi,%ecx
 510:	75 dd                	jne    4ef <free+0x47>
    p->s.size += bp->s.size;
 512:	03 53 fc             	add    -0x4(%ebx),%edx
 515:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 518:	8b 53 f8             	mov    -0x8(%ebx),%edx
 51b:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 51d:	a3 cc 08 00 00       	mov    %eax,0x8cc
}
 522:	5b                   	pop    %ebx
 523:	5e                   	pop    %esi
 524:	5f                   	pop    %edi
 525:	5d                   	pop    %ebp
 526:	c3                   	ret    
 527:	90                   	nop

00000528 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 528:	55                   	push   %ebp
 529:	89 e5                	mov    %esp,%ebp
 52b:	57                   	push   %edi
 52c:	56                   	push   %esi
 52d:	53                   	push   %ebx
 52e:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 531:	8b 5d 08             	mov    0x8(%ebp),%ebx
 534:	83 c3 07             	add    $0x7,%ebx
 537:	c1 eb 03             	shr    $0x3,%ebx
 53a:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 53b:	8b 0d cc 08 00 00    	mov    0x8cc,%ecx
 541:	85 c9                	test   %ecx,%ecx
 543:	0f 84 95 00 00 00    	je     5de <malloc+0xb6>
 549:	8b 01                	mov    (%ecx),%eax
 54b:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 54e:	39 da                	cmp    %ebx,%edx
 550:	73 66                	jae    5b8 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 552:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 559:	eb 0c                	jmp    567 <malloc+0x3f>
 55b:	90                   	nop
    }
    if(p == freep)
 55c:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 55e:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 560:	8b 50 04             	mov    0x4(%eax),%edx
 563:	39 d3                	cmp    %edx,%ebx
 565:	76 51                	jbe    5b8 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 567:	3b 05 cc 08 00 00    	cmp    0x8cc,%eax
 56d:	75 ed                	jne    55c <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 56f:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 575:	76 35                	jbe    5ac <malloc+0x84>
 577:	89 f8                	mov    %edi,%eax
 579:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 57b:	89 04 24             	mov    %eax,(%esp)
 57e:	e8 41 fd ff ff       	call   2c4 <sbrk>
  if(p == (char*)-1)
 583:	83 f8 ff             	cmp    $0xffffffff,%eax
 586:	74 18                	je     5a0 <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 588:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 58b:	83 c0 08             	add    $0x8,%eax
 58e:	89 04 24             	mov    %eax,(%esp)
 591:	e8 12 ff ff ff       	call   4a8 <free>
  return freep;
 596:	8b 0d cc 08 00 00    	mov    0x8cc,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 59c:	85 c9                	test   %ecx,%ecx
 59e:	75 be                	jne    55e <malloc+0x36>
        return 0;
 5a0:	31 c0                	xor    %eax,%eax
  }
}
 5a2:	83 c4 1c             	add    $0x1c,%esp
 5a5:	5b                   	pop    %ebx
 5a6:	5e                   	pop    %esi
 5a7:	5f                   	pop    %edi
 5a8:	5d                   	pop    %ebp
 5a9:	c3                   	ret    
 5aa:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 5ac:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 5b1:	be 00 10 00 00       	mov    $0x1000,%esi
 5b6:	eb c3                	jmp    57b <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5b8:	39 d3                	cmp    %edx,%ebx
 5ba:	74 1c                	je     5d8 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5bc:	29 da                	sub    %ebx,%edx
 5be:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5c1:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5c4:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5c7:	89 0d cc 08 00 00    	mov    %ecx,0x8cc
      return (void*)(p + 1);
 5cd:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5d0:	83 c4 1c             	add    $0x1c,%esp
 5d3:	5b                   	pop    %ebx
 5d4:	5e                   	pop    %esi
 5d5:	5f                   	pop    %edi
 5d6:	5d                   	pop    %ebp
 5d7:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 5d8:	8b 10                	mov    (%eax),%edx
 5da:	89 11                	mov    %edx,(%ecx)
 5dc:	eb e9                	jmp    5c7 <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 5de:	c7 05 cc 08 00 00 d0 	movl   $0x8d0,0x8cc
 5e5:	08 00 00 
 5e8:	c7 05 d0 08 00 00 d0 	movl   $0x8d0,0x8d0
 5ef:	08 00 00 
    base.s.size = 0;
 5f2:	c7 05 d4 08 00 00 00 	movl   $0x0,0x8d4
 5f9:	00 00 00 
 5fc:	b8 d0 08 00 00       	mov    $0x8d0,%eax
 601:	e9 4c ff ff ff       	jmp    552 <malloc+0x2a>
