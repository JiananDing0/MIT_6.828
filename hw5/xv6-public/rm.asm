
_rm:     file format elf32-i386


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
   c:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i;

  if(argc < 2){
   f:	83 ff 01             	cmp    $0x1,%edi
  12:	7e 43                	jle    57 <main+0x57>
#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
  14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  17:	83 c3 04             	add    $0x4,%ebx
  1a:	be 01 00 00 00       	mov    $0x1,%esi
  1f:	90                   	nop
    printf(2, "Usage: rm files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
    if(unlink(argv[i]) < 0){
  20:	8b 03                	mov    (%ebx),%eax
  22:	89 04 24             	mov    %eax,(%esp)
  25:	e8 5a 02 00 00       	call   284 <unlink>
  2a:	85 c0                	test   %eax,%eax
  2c:	78 0d                	js     3b <main+0x3b>
  if(argc < 2){
    printf(2, "Usage: rm files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  2e:	46                   	inc    %esi
  2f:	83 c3 04             	add    $0x4,%ebx
  32:	39 fe                	cmp    %edi,%esi
  34:	75 ea                	jne    20 <main+0x20>
      printf(2, "rm: %s failed to delete\n", argv[i]);
      break;
    }
  }

  exit();
  36:	e8 f9 01 00 00       	call   234 <exit>
    exit();
  }

  for(i = 1; i < argc; i++){
    if(unlink(argv[i]) < 0){
      printf(2, "rm: %s failed to delete\n", argv[i]);
  3b:	8b 03                	mov    (%ebx),%eax
  3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  41:	c7 44 24 04 12 06 00 	movl   $0x612,0x4(%esp)
  48:	00 
  49:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  50:	e8 17 03 00 00       	call   36c <printf>
      break;
  55:	eb df                	jmp    36 <main+0x36>
main(int argc, char *argv[])
{
  int i;

  if(argc < 2){
    printf(2, "Usage: rm files...\n");
  57:	c7 44 24 04 fe 05 00 	movl   $0x5fe,0x4(%esp)
  5e:	00 
  5f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  66:	e8 01 03 00 00       	call   36c <printf>
    exit();
  6b:	e8 c4 01 00 00       	call   234 <exit>

00000070 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  70:	55                   	push   %ebp
  71:	89 e5                	mov    %esp,%ebp
  73:	53                   	push   %ebx
  74:	8b 45 08             	mov    0x8(%ebp),%eax
  77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  7a:	31 d2                	xor    %edx,%edx
  7c:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  7f:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  82:	42                   	inc    %edx
  83:	84 c9                	test   %cl,%cl
  85:	75 f5                	jne    7c <strcpy+0xc>
    ;
  return os;
}
  87:	5b                   	pop    %ebx
  88:	5d                   	pop    %ebp
  89:	c3                   	ret    
  8a:	66 90                	xchg   %ax,%ax

0000008c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8c:	55                   	push   %ebp
  8d:	89 e5                	mov    %esp,%ebp
  8f:	56                   	push   %esi
  90:	53                   	push   %ebx
  91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  94:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  97:	8a 01                	mov    (%ecx),%al
  99:	8a 1a                	mov    (%edx),%bl
  9b:	84 c0                	test   %al,%al
  9d:	74 1d                	je     bc <strcmp+0x30>
  9f:	38 d8                	cmp    %bl,%al
  a1:	74 0c                	je     af <strcmp+0x23>
  a3:	eb 23                	jmp    c8 <strcmp+0x3c>
  a5:	8d 76 00             	lea    0x0(%esi),%esi
  a8:	41                   	inc    %ecx
  a9:	38 d8                	cmp    %bl,%al
  ab:	75 1b                	jne    c8 <strcmp+0x3c>
    p++, q++;
  ad:	89 f2                	mov    %esi,%edx
  af:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  b2:	8a 41 01             	mov    0x1(%ecx),%al
  b5:	8a 5a 01             	mov    0x1(%edx),%bl
  b8:	84 c0                	test   %al,%al
  ba:	75 ec                	jne    a8 <strcmp+0x1c>
  bc:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  be:	0f b6 db             	movzbl %bl,%ebx
  c1:	29 d8                	sub    %ebx,%eax
}
  c3:	5b                   	pop    %ebx
  c4:	5e                   	pop    %esi
  c5:	5d                   	pop    %ebp
  c6:	c3                   	ret    
  c7:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  c8:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  cb:	0f b6 db             	movzbl %bl,%ebx
  ce:	29 d8                	sub    %ebx,%eax
}
  d0:	5b                   	pop    %ebx
  d1:	5e                   	pop    %esi
  d2:	5d                   	pop    %ebp
  d3:	c3                   	ret    

000000d4 <strlen>:

uint
strlen(const char *s)
{
  d4:	55                   	push   %ebp
  d5:	89 e5                	mov    %esp,%ebp
  d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  da:	80 39 00             	cmpb   $0x0,(%ecx)
  dd:	74 10                	je     ef <strlen+0x1b>
  df:	31 d2                	xor    %edx,%edx
  e1:	8d 76 00             	lea    0x0(%esi),%esi
  e4:	42                   	inc    %edx
  e5:	89 d0                	mov    %edx,%eax
  e7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  eb:	75 f7                	jne    e4 <strlen+0x10>
    ;
  return n;
}
  ed:	5d                   	pop    %ebp
  ee:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
  ef:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
  f1:	5d                   	pop    %ebp
  f2:	c3                   	ret    
  f3:	90                   	nop

000000f4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f4:	55                   	push   %ebp
  f5:	89 e5                	mov    %esp,%ebp
  f7:	57                   	push   %edi
  f8:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  fb:	89 d7                	mov    %edx,%edi
  fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
 100:	8b 45 0c             	mov    0xc(%ebp),%eax
 103:	fc                   	cld    
 104:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 106:	89 d0                	mov    %edx,%eax
 108:	5f                   	pop    %edi
 109:	5d                   	pop    %ebp
 10a:	c3                   	ret    
 10b:	90                   	nop

0000010c <strchr>:

char*
strchr(const char *s, char c)
{
 10c:	55                   	push   %ebp
 10d:	89 e5                	mov    %esp,%ebp
 10f:	8b 45 08             	mov    0x8(%ebp),%eax
 112:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 115:	8a 10                	mov    (%eax),%dl
 117:	84 d2                	test   %dl,%dl
 119:	75 0d                	jne    128 <strchr+0x1c>
 11b:	eb 13                	jmp    130 <strchr+0x24>
 11d:	8d 76 00             	lea    0x0(%esi),%esi
 120:	8a 50 01             	mov    0x1(%eax),%dl
 123:	84 d2                	test   %dl,%dl
 125:	74 09                	je     130 <strchr+0x24>
 127:	40                   	inc    %eax
    if(*s == c)
 128:	38 ca                	cmp    %cl,%dl
 12a:	75 f4                	jne    120 <strchr+0x14>
      return (char*)s;
  return 0;
}
 12c:	5d                   	pop    %ebp
 12d:	c3                   	ret    
 12e:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 130:	31 c0                	xor    %eax,%eax
}
 132:	5d                   	pop    %ebp
 133:	c3                   	ret    

00000134 <gets>:

char*
gets(char *buf, int max)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	57                   	push   %edi
 138:	56                   	push   %esi
 139:	53                   	push   %ebx
 13a:	83 ec 2c             	sub    $0x2c,%esp
 13d:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 140:	31 f6                	xor    %esi,%esi
 142:	eb 30                	jmp    174 <gets+0x40>
    cc = read(0, &c, 1);
 144:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 14b:	00 
 14c:	8d 45 e7             	lea    -0x19(%ebp),%eax
 14f:	89 44 24 04          	mov    %eax,0x4(%esp)
 153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 15a:	e8 ed 00 00 00       	call   24c <read>
    if(cc < 1)
 15f:	85 c0                	test   %eax,%eax
 161:	7e 19                	jle    17c <gets+0x48>
      break;
    buf[i++] = c;
 163:	8a 45 e7             	mov    -0x19(%ebp),%al
 166:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16a:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 16c:	3c 0a                	cmp    $0xa,%al
 16e:	74 0c                	je     17c <gets+0x48>
 170:	3c 0d                	cmp    $0xd,%al
 172:	74 08                	je     17c <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 174:	8d 5e 01             	lea    0x1(%esi),%ebx
 177:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 17a:	7c c8                	jl     144 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 17c:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 180:	89 f8                	mov    %edi,%eax
 182:	83 c4 2c             	add    $0x2c,%esp
 185:	5b                   	pop    %ebx
 186:	5e                   	pop    %esi
 187:	5f                   	pop    %edi
 188:	5d                   	pop    %ebp
 189:	c3                   	ret    
 18a:	66 90                	xchg   %ax,%ax

0000018c <stat>:

int
stat(const char *n, struct stat *st)
{
 18c:	55                   	push   %ebp
 18d:	89 e5                	mov    %esp,%ebp
 18f:	56                   	push   %esi
 190:	53                   	push   %ebx
 191:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 194:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 19b:	00 
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	89 04 24             	mov    %eax,(%esp)
 1a2:	e8 cd 00 00 00       	call   274 <open>
 1a7:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 1a9:	85 c0                	test   %eax,%eax
 1ab:	78 23                	js     1d0 <stat+0x44>
    return -1;
  r = fstat(fd, st);
 1ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b0:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b4:	89 1c 24             	mov    %ebx,(%esp)
 1b7:	e8 d0 00 00 00       	call   28c <fstat>
 1bc:	89 c6                	mov    %eax,%esi
  close(fd);
 1be:	89 1c 24             	mov    %ebx,(%esp)
 1c1:	e8 96 00 00 00       	call   25c <close>
  return r;
}
 1c6:	89 f0                	mov    %esi,%eax
 1c8:	83 c4 10             	add    $0x10,%esp
 1cb:	5b                   	pop    %ebx
 1cc:	5e                   	pop    %esi
 1cd:	5d                   	pop    %ebp
 1ce:	c3                   	ret    
 1cf:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 1d0:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1d5:	eb ef                	jmp    1c6 <stat+0x3a>
 1d7:	90                   	nop

000001d8 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	53                   	push   %ebx
 1dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1df:	8a 11                	mov    (%ecx),%dl
 1e1:	8d 42 d0             	lea    -0x30(%edx),%eax
 1e4:	3c 09                	cmp    $0x9,%al
 1e6:	b8 00 00 00 00       	mov    $0x0,%eax
 1eb:	77 18                	ja     205 <atoi+0x2d>
 1ed:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 1f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
 1f3:	0f be d2             	movsbl %dl,%edx
 1f6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 1fa:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1fb:	8a 11                	mov    (%ecx),%dl
 1fd:	8d 5a d0             	lea    -0x30(%edx),%ebx
 200:	80 fb 09             	cmp    $0x9,%bl
 203:	76 eb                	jbe    1f0 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 205:	5b                   	pop    %ebx
 206:	5d                   	pop    %ebp
 207:	c3                   	ret    

00000208 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 208:	55                   	push   %ebp
 209:	89 e5                	mov    %esp,%ebp
 20b:	56                   	push   %esi
 20c:	53                   	push   %ebx
 20d:	8b 45 08             	mov    0x8(%ebp),%eax
 210:	8b 75 0c             	mov    0xc(%ebp),%esi
 213:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 216:	85 db                	test   %ebx,%ebx
 218:	7e 0d                	jle    227 <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 21a:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 21c:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 21f:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 222:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 223:	39 da                	cmp    %ebx,%edx
 225:	75 f5                	jne    21c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 227:	5b                   	pop    %ebx
 228:	5e                   	pop    %esi
 229:	5d                   	pop    %ebp
 22a:	c3                   	ret    
 22b:	90                   	nop

0000022c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 22c:	b8 01 00 00 00       	mov    $0x1,%eax
 231:	cd 40                	int    $0x40
 233:	c3                   	ret    

00000234 <exit>:
SYSCALL(exit)
 234:	b8 02 00 00 00       	mov    $0x2,%eax
 239:	cd 40                	int    $0x40
 23b:	c3                   	ret    

0000023c <wait>:
SYSCALL(wait)
 23c:	b8 03 00 00 00       	mov    $0x3,%eax
 241:	cd 40                	int    $0x40
 243:	c3                   	ret    

00000244 <pipe>:
SYSCALL(pipe)
 244:	b8 04 00 00 00       	mov    $0x4,%eax
 249:	cd 40                	int    $0x40
 24b:	c3                   	ret    

0000024c <read>:
SYSCALL(read)
 24c:	b8 05 00 00 00       	mov    $0x5,%eax
 251:	cd 40                	int    $0x40
 253:	c3                   	ret    

00000254 <write>:
SYSCALL(write)
 254:	b8 10 00 00 00       	mov    $0x10,%eax
 259:	cd 40                	int    $0x40
 25b:	c3                   	ret    

0000025c <close>:
SYSCALL(close)
 25c:	b8 15 00 00 00       	mov    $0x15,%eax
 261:	cd 40                	int    $0x40
 263:	c3                   	ret    

00000264 <kill>:
SYSCALL(kill)
 264:	b8 06 00 00 00       	mov    $0x6,%eax
 269:	cd 40                	int    $0x40
 26b:	c3                   	ret    

0000026c <exec>:
SYSCALL(exec)
 26c:	b8 07 00 00 00       	mov    $0x7,%eax
 271:	cd 40                	int    $0x40
 273:	c3                   	ret    

00000274 <open>:
SYSCALL(open)
 274:	b8 0f 00 00 00       	mov    $0xf,%eax
 279:	cd 40                	int    $0x40
 27b:	c3                   	ret    

0000027c <mknod>:
SYSCALL(mknod)
 27c:	b8 11 00 00 00       	mov    $0x11,%eax
 281:	cd 40                	int    $0x40
 283:	c3                   	ret    

00000284 <unlink>:
SYSCALL(unlink)
 284:	b8 12 00 00 00       	mov    $0x12,%eax
 289:	cd 40                	int    $0x40
 28b:	c3                   	ret    

0000028c <fstat>:
SYSCALL(fstat)
 28c:	b8 08 00 00 00       	mov    $0x8,%eax
 291:	cd 40                	int    $0x40
 293:	c3                   	ret    

00000294 <link>:
SYSCALL(link)
 294:	b8 13 00 00 00       	mov    $0x13,%eax
 299:	cd 40                	int    $0x40
 29b:	c3                   	ret    

0000029c <mkdir>:
SYSCALL(mkdir)
 29c:	b8 14 00 00 00       	mov    $0x14,%eax
 2a1:	cd 40                	int    $0x40
 2a3:	c3                   	ret    

000002a4 <chdir>:
SYSCALL(chdir)
 2a4:	b8 09 00 00 00       	mov    $0x9,%eax
 2a9:	cd 40                	int    $0x40
 2ab:	c3                   	ret    

000002ac <dup>:
SYSCALL(dup)
 2ac:	b8 0a 00 00 00       	mov    $0xa,%eax
 2b1:	cd 40                	int    $0x40
 2b3:	c3                   	ret    

000002b4 <getpid>:
SYSCALL(getpid)
 2b4:	b8 0b 00 00 00       	mov    $0xb,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <sbrk>:
SYSCALL(sbrk)
 2bc:	b8 0c 00 00 00       	mov    $0xc,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <sleep>:
SYSCALL(sleep)
 2c4:	b8 0d 00 00 00       	mov    $0xd,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <uptime>:
SYSCALL(uptime)
 2cc:	b8 0e 00 00 00       	mov    $0xe,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <alarm>:
SYSCALL(alarm)
 2d4:	b8 16 00 00 00       	mov    $0x16,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2dc:	55                   	push   %ebp
 2dd:	89 e5                	mov    %esp,%ebp
 2df:	83 ec 28             	sub    $0x28,%esp
 2e2:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2e5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2ec:	00 
 2ed:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2f0:	89 54 24 04          	mov    %edx,0x4(%esp)
 2f4:	89 04 24             	mov    %eax,(%esp)
 2f7:	e8 58 ff ff ff       	call   254 <write>
}
 2fc:	c9                   	leave  
 2fd:	c3                   	ret    
 2fe:	66 90                	xchg   %ax,%ax

00000300 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	57                   	push   %edi
 304:	56                   	push   %esi
 305:	53                   	push   %ebx
 306:	83 ec 1c             	sub    $0x1c,%esp
 309:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 30b:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 30d:	8b 5d 08             	mov    0x8(%ebp),%ebx
 310:	85 db                	test   %ebx,%ebx
 312:	74 04                	je     318 <printint+0x18>
 314:	85 d2                	test   %edx,%edx
 316:	78 4a                	js     362 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 318:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 31a:	31 db                	xor    %ebx,%ebx
 31c:	eb 04                	jmp    322 <printint+0x22>
 31e:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 320:	89 d3                	mov    %edx,%ebx
 322:	31 d2                	xor    %edx,%edx
 324:	f7 f1                	div    %ecx
 326:	8a 92 32 06 00 00    	mov    0x632(%edx),%dl
 32c:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 330:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 333:	85 c0                	test   %eax,%eax
 335:	75 e9                	jne    320 <printint+0x20>
  if(neg)
 337:	85 ff                	test   %edi,%edi
 339:	74 08                	je     343 <printint+0x43>
    buf[i++] = '-';
 33b:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 340:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 343:	8d 5a ff             	lea    -0x1(%edx),%ebx
 346:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 348:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 34d:	89 f0                	mov    %esi,%eax
 34f:	e8 88 ff ff ff       	call   2dc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 354:	4b                   	dec    %ebx
 355:	83 fb ff             	cmp    $0xffffffff,%ebx
 358:	75 ee                	jne    348 <printint+0x48>
    putc(fd, buf[i]);
}
 35a:	83 c4 1c             	add    $0x1c,%esp
 35d:	5b                   	pop    %ebx
 35e:	5e                   	pop    %esi
 35f:	5f                   	pop    %edi
 360:	5d                   	pop    %ebp
 361:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 362:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 364:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 369:	eb af                	jmp    31a <printint+0x1a>
 36b:	90                   	nop

0000036c <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 36c:	55                   	push   %ebp
 36d:	89 e5                	mov    %esp,%ebp
 36f:	57                   	push   %edi
 370:	56                   	push   %esi
 371:	53                   	push   %ebx
 372:	83 ec 2c             	sub    $0x2c,%esp
 375:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 378:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 37b:	8a 0b                	mov    (%ebx),%cl
 37d:	84 c9                	test   %cl,%cl
 37f:	74 7b                	je     3fc <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 381:	8d 45 10             	lea    0x10(%ebp),%eax
 384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 387:	31 f6                	xor    %esi,%esi
 389:	eb 17                	jmp    3a2 <printf+0x36>
 38b:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 38c:	83 f9 25             	cmp    $0x25,%ecx
 38f:	74 73                	je     404 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 391:	0f be d1             	movsbl %cl,%edx
 394:	89 f8                	mov    %edi,%eax
 396:	e8 41 ff ff ff       	call   2dc <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 39b:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 39c:	8a 0b                	mov    (%ebx),%cl
 39e:	84 c9                	test   %cl,%cl
 3a0:	74 5a                	je     3fc <printf+0x90>
    c = fmt[i] & 0xff;
 3a2:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 3a5:	85 f6                	test   %esi,%esi
 3a7:	74 e3                	je     38c <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 3a9:	83 fe 25             	cmp    $0x25,%esi
 3ac:	75 ed                	jne    39b <printf+0x2f>
      if(c == 'd'){
 3ae:	83 f9 64             	cmp    $0x64,%ecx
 3b1:	0f 84 c1 00 00 00    	je     478 <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3b7:	83 f9 78             	cmp    $0x78,%ecx
 3ba:	74 50                	je     40c <printf+0xa0>
 3bc:	83 f9 70             	cmp    $0x70,%ecx
 3bf:	74 4b                	je     40c <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3c1:	83 f9 73             	cmp    $0x73,%ecx
 3c4:	74 6a                	je     430 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3c6:	83 f9 63             	cmp    $0x63,%ecx
 3c9:	0f 84 91 00 00 00    	je     460 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 3cf:	ba 25 00 00 00       	mov    $0x25,%edx
 3d4:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3d6:	83 f9 25             	cmp    $0x25,%ecx
 3d9:	74 10                	je     3eb <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 3de:	e8 f9 fe ff ff       	call   2dc <putc>
        putc(fd, c);
 3e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 3e6:	0f be d1             	movsbl %cl,%edx
 3e9:	89 f8                	mov    %edi,%eax
 3eb:	e8 ec fe ff ff       	call   2dc <putc>
      }
      state = 0;
 3f0:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 3f2:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3f3:	8a 0b                	mov    (%ebx),%cl
 3f5:	84 c9                	test   %cl,%cl
 3f7:	75 a9                	jne    3a2 <printf+0x36>
 3f9:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 3fc:	83 c4 2c             	add    $0x2c,%esp
 3ff:	5b                   	pop    %ebx
 400:	5e                   	pop    %esi
 401:	5f                   	pop    %edi
 402:	5d                   	pop    %ebp
 403:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 404:	be 25 00 00 00       	mov    $0x25,%esi
 409:	eb 90                	jmp    39b <printf+0x2f>
 40b:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 40c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 413:	b9 10 00 00 00       	mov    $0x10,%ecx
 418:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 41b:	8b 10                	mov    (%eax),%edx
 41d:	89 f8                	mov    %edi,%eax
 41f:	e8 dc fe ff ff       	call   300 <printint>
        ap++;
 424:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 428:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 42a:	e9 6c ff ff ff       	jmp    39b <printf+0x2f>
 42f:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 430:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 433:	8b 30                	mov    (%eax),%esi
        ap++;
 435:	83 c0 04             	add    $0x4,%eax
 438:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 43b:	85 f6                	test   %esi,%esi
 43d:	74 5a                	je     499 <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 43f:	8a 16                	mov    (%esi),%dl
 441:	84 d2                	test   %dl,%dl
 443:	74 14                	je     459 <printf+0xed>
 445:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 448:	0f be d2             	movsbl %dl,%edx
 44b:	89 f8                	mov    %edi,%eax
 44d:	e8 8a fe ff ff       	call   2dc <putc>
          s++;
 452:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 453:	8a 16                	mov    (%esi),%dl
 455:	84 d2                	test   %dl,%dl
 457:	75 ef                	jne    448 <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 459:	31 f6                	xor    %esi,%esi
 45b:	e9 3b ff ff ff       	jmp    39b <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 460:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 463:	0f be 10             	movsbl (%eax),%edx
 466:	89 f8                	mov    %edi,%eax
 468:	e8 6f fe ff ff       	call   2dc <putc>
        ap++;
 46d:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 471:	31 f6                	xor    %esi,%esi
 473:	e9 23 ff ff ff       	jmp    39b <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 478:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 47f:	b1 0a                	mov    $0xa,%cl
 481:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 484:	8b 10                	mov    (%eax),%edx
 486:	89 f8                	mov    %edi,%eax
 488:	e8 73 fe ff ff       	call   300 <printint>
        ap++;
 48d:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 491:	66 31 f6             	xor    %si,%si
 494:	e9 02 ff ff ff       	jmp    39b <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 499:	be 2b 06 00 00       	mov    $0x62b,%esi
 49e:	eb 9f                	jmp    43f <printf+0xd3>

000004a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4a0:	55                   	push   %ebp
 4a1:	89 e5                	mov    %esp,%ebp
 4a3:	57                   	push   %edi
 4a4:	56                   	push   %esi
 4a5:	53                   	push   %ebx
 4a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4a9:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4ac:	a1 e8 08 00 00       	mov    0x8e8,%eax
 4b1:	8d 76 00             	lea    0x0(%esi),%esi
 4b4:	8b 10                	mov    (%eax),%edx
 4b6:	39 c8                	cmp    %ecx,%eax
 4b8:	73 04                	jae    4be <free+0x1e>
 4ba:	39 d1                	cmp    %edx,%ecx
 4bc:	72 12                	jb     4d0 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4be:	39 d0                	cmp    %edx,%eax
 4c0:	72 08                	jb     4ca <free+0x2a>
 4c2:	39 c8                	cmp    %ecx,%eax
 4c4:	72 0a                	jb     4d0 <free+0x30>
 4c6:	39 d1                	cmp    %edx,%ecx
 4c8:	72 06                	jb     4d0 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 4ca:	89 d0                	mov    %edx,%eax
 4cc:	eb e6                	jmp    4b4 <free+0x14>
 4ce:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 4d0:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4d3:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4d6:	39 d7                	cmp    %edx,%edi
 4d8:	74 19                	je     4f3 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4da:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4dd:	8b 50 04             	mov    0x4(%eax),%edx
 4e0:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4e3:	39 f1                	cmp    %esi,%ecx
 4e5:	74 23                	je     50a <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4e7:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4e9:	a3 e8 08 00 00       	mov    %eax,0x8e8
}
 4ee:	5b                   	pop    %ebx
 4ef:	5e                   	pop    %esi
 4f0:	5f                   	pop    %edi
 4f1:	5d                   	pop    %ebp
 4f2:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 4f3:	03 72 04             	add    0x4(%edx),%esi
 4f6:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4f9:	8b 10                	mov    (%eax),%edx
 4fb:	8b 12                	mov    (%edx),%edx
 4fd:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 500:	8b 50 04             	mov    0x4(%eax),%edx
 503:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 506:	39 f1                	cmp    %esi,%ecx
 508:	75 dd                	jne    4e7 <free+0x47>
    p->s.size += bp->s.size;
 50a:	03 53 fc             	add    -0x4(%ebx),%edx
 50d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 510:	8b 53 f8             	mov    -0x8(%ebx),%edx
 513:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 515:	a3 e8 08 00 00       	mov    %eax,0x8e8
}
 51a:	5b                   	pop    %ebx
 51b:	5e                   	pop    %esi
 51c:	5f                   	pop    %edi
 51d:	5d                   	pop    %ebp
 51e:	c3                   	ret    
 51f:	90                   	nop

00000520 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 520:	55                   	push   %ebp
 521:	89 e5                	mov    %esp,%ebp
 523:	57                   	push   %edi
 524:	56                   	push   %esi
 525:	53                   	push   %ebx
 526:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 529:	8b 5d 08             	mov    0x8(%ebp),%ebx
 52c:	83 c3 07             	add    $0x7,%ebx
 52f:	c1 eb 03             	shr    $0x3,%ebx
 532:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 533:	8b 0d e8 08 00 00    	mov    0x8e8,%ecx
 539:	85 c9                	test   %ecx,%ecx
 53b:	0f 84 95 00 00 00    	je     5d6 <malloc+0xb6>
 541:	8b 01                	mov    (%ecx),%eax
 543:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 546:	39 da                	cmp    %ebx,%edx
 548:	73 66                	jae    5b0 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 54a:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 551:	eb 0c                	jmp    55f <malloc+0x3f>
 553:	90                   	nop
    }
    if(p == freep)
 554:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 556:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 558:	8b 50 04             	mov    0x4(%eax),%edx
 55b:	39 d3                	cmp    %edx,%ebx
 55d:	76 51                	jbe    5b0 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 55f:	3b 05 e8 08 00 00    	cmp    0x8e8,%eax
 565:	75 ed                	jne    554 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 567:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 56d:	76 35                	jbe    5a4 <malloc+0x84>
 56f:	89 f8                	mov    %edi,%eax
 571:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 573:	89 04 24             	mov    %eax,(%esp)
 576:	e8 41 fd ff ff       	call   2bc <sbrk>
  if(p == (char*)-1)
 57b:	83 f8 ff             	cmp    $0xffffffff,%eax
 57e:	74 18                	je     598 <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 580:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 583:	83 c0 08             	add    $0x8,%eax
 586:	89 04 24             	mov    %eax,(%esp)
 589:	e8 12 ff ff ff       	call   4a0 <free>
  return freep;
 58e:	8b 0d e8 08 00 00    	mov    0x8e8,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 594:	85 c9                	test   %ecx,%ecx
 596:	75 be                	jne    556 <malloc+0x36>
        return 0;
 598:	31 c0                	xor    %eax,%eax
  }
}
 59a:	83 c4 1c             	add    $0x1c,%esp
 59d:	5b                   	pop    %ebx
 59e:	5e                   	pop    %esi
 59f:	5f                   	pop    %edi
 5a0:	5d                   	pop    %ebp
 5a1:	c3                   	ret    
 5a2:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 5a4:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 5a9:	be 00 10 00 00       	mov    $0x1000,%esi
 5ae:	eb c3                	jmp    573 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5b0:	39 d3                	cmp    %edx,%ebx
 5b2:	74 1c                	je     5d0 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5b4:	29 da                	sub    %ebx,%edx
 5b6:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5b9:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5bc:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5bf:	89 0d e8 08 00 00    	mov    %ecx,0x8e8
      return (void*)(p + 1);
 5c5:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5c8:	83 c4 1c             	add    $0x1c,%esp
 5cb:	5b                   	pop    %ebx
 5cc:	5e                   	pop    %esi
 5cd:	5f                   	pop    %edi
 5ce:	5d                   	pop    %ebp
 5cf:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 5d0:	8b 10                	mov    (%eax),%edx
 5d2:	89 11                	mov    %edx,(%ecx)
 5d4:	eb e9                	jmp    5bf <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 5d6:	c7 05 e8 08 00 00 ec 	movl   $0x8ec,0x8e8
 5dd:	08 00 00 
 5e0:	c7 05 ec 08 00 00 ec 	movl   $0x8ec,0x8ec
 5e7:	08 00 00 
    base.s.size = 0;
 5ea:	c7 05 f0 08 00 00 00 	movl   $0x0,0x8f0
 5f1:	00 00 00 
 5f4:	b8 ec 08 00 00       	mov    $0x8ec,%eax
 5f9:	e9 4c ff ff ff       	jmp    54a <malloc+0x2a>
