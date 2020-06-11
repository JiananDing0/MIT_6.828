
_forktest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
  printf(1, "fork test OK\n");
}

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
  forktest();
   6:	e8 31 00 00 00       	call   3c <forktest>
  exit();
   b:	e8 b0 02 00 00       	call   2c0 <exit>

00000010 <printf>:

#define N  1000

void
printf(int fd, const char *s, ...)
{
  10:	55                   	push   %ebp
  11:	89 e5                	mov    %esp,%ebp
  13:	53                   	push   %ebx
  14:	83 ec 14             	sub    $0x14,%esp
  17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  write(fd, s, strlen(s));
  1a:	89 1c 24             	mov    %ebx,(%esp)
  1d:	e8 3e 01 00 00       	call   160 <strlen>
  22:	89 44 24 08          	mov    %eax,0x8(%esp)
  26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  2a:	8b 45 08             	mov    0x8(%ebp),%eax
  2d:	89 04 24             	mov    %eax,(%esp)
  30:	e8 ab 02 00 00       	call   2e0 <write>
}
  35:	83 c4 14             	add    $0x14,%esp
  38:	5b                   	pop    %ebx
  39:	5d                   	pop    %ebp
  3a:	c3                   	ret    
  3b:	90                   	nop

0000003c <forktest>:

void
forktest(void)
{
  3c:	55                   	push   %ebp
  3d:	89 e5                	mov    %esp,%ebp
  3f:	53                   	push   %ebx
  40:	83 ec 14             	sub    $0x14,%esp
  int n, pid;

  printf(1, "fork test\n");
  43:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
  4a:	00 
  4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  52:	e8 b9 ff ff ff       	call   10 <printf>

  for(n=0; n<N; n++){
  57:	31 db                	xor    %ebx,%ebx
  59:	eb 0c                	jmp    67 <forktest+0x2b>
  5b:	90                   	nop
    pid = fork();
    if(pid < 0)
      break;
    if(pid == 0)
  5c:	74 7f                	je     dd <forktest+0xa1>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<N; n++){
  5e:	43                   	inc    %ebx
  5f:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  65:	74 41                	je     a8 <forktest+0x6c>
    pid = fork();
  67:	e8 4c 02 00 00       	call   2b8 <fork>
    if(pid < 0)
  6c:	83 f8 00             	cmp    $0x0,%eax
  6f:	7d eb                	jge    5c <forktest+0x20>
  if(n == N){
    printf(1, "fork claimed to work N times!\n", N);
    exit();
  }

  for(; n > 0; n--){
  71:	85 db                	test   %ebx,%ebx
  73:	74 0f                	je     84 <forktest+0x48>
  75:	8d 76 00             	lea    0x0(%esi),%esi
    if(wait() < 0){
  78:	e8 4b 02 00 00       	call   2c8 <wait>
  7d:	85 c0                	test   %eax,%eax
  7f:	78 48                	js     c9 <forktest+0x8d>
  if(n == N){
    printf(1, "fork claimed to work N times!\n", N);
    exit();
  }

  for(; n > 0; n--){
  81:	4b                   	dec    %ebx
  82:	75 f4                	jne    78 <forktest+0x3c>
      printf(1, "wait stopped early\n");
      exit();
    }
  }

  if(wait() != -1){
  84:	e8 3f 02 00 00       	call   2c8 <wait>
  89:	40                   	inc    %eax
  8a:	75 56                	jne    e2 <forktest+0xa6>
    printf(1, "wait got too many\n");
    exit();
  }

  printf(1, "fork test OK\n");
  8c:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
  93:	00 
  94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9b:	e8 70 ff ff ff       	call   10 <printf>
}
  a0:	83 c4 14             	add    $0x14,%esp
  a3:	5b                   	pop    %ebx
  a4:	5d                   	pop    %ebp
  a5:	c3                   	ret    
  a6:	66 90                	xchg   %ax,%ax
    if(pid == 0)
      exit();
  }

  if(n == N){
    printf(1, "fork claimed to work N times!\n", N);
  a8:	c7 44 24 08 e8 03 00 	movl   $0x3e8,0x8(%esp)
  af:	00 
  b0:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
  b7:	00 
  b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  bf:	e8 4c ff ff ff       	call   10 <printf>
    exit();
  c4:	e8 f7 01 00 00       	call   2c0 <exit>
  }

  for(; n > 0; n--){
    if(wait() < 0){
      printf(1, "wait stopped early\n");
  c9:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
  d0:	00 
  d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d8:	e8 33 ff ff ff       	call   10 <printf>
      exit();
  dd:	e8 de 01 00 00       	call   2c0 <exit>
    }
  }

  if(wait() != -1){
    printf(1, "wait got too many\n");
  e2:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
  e9:	00 
  ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f1:	e8 1a ff ff ff       	call   10 <printf>
    exit();
  f6:	e8 c5 01 00 00       	call   2c0 <exit>
  fb:	90                   	nop

000000fc <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  fc:	55                   	push   %ebp
  fd:	89 e5                	mov    %esp,%ebp
  ff:	53                   	push   %ebx
 100:	8b 45 08             	mov    0x8(%ebp),%eax
 103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 106:	31 d2                	xor    %edx,%edx
 108:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
 10b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 10e:	42                   	inc    %edx
 10f:	84 c9                	test   %cl,%cl
 111:	75 f5                	jne    108 <strcpy+0xc>
    ;
  return os;
}
 113:	5b                   	pop    %ebx
 114:	5d                   	pop    %ebp
 115:	c3                   	ret    
 116:	66 90                	xchg   %ax,%ax

00000118 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 118:	55                   	push   %ebp
 119:	89 e5                	mov    %esp,%ebp
 11b:	56                   	push   %esi
 11c:	53                   	push   %ebx
 11d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 120:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 123:	8a 01                	mov    (%ecx),%al
 125:	8a 1a                	mov    (%edx),%bl
 127:	84 c0                	test   %al,%al
 129:	74 1d                	je     148 <strcmp+0x30>
 12b:	38 d8                	cmp    %bl,%al
 12d:	74 0c                	je     13b <strcmp+0x23>
 12f:	eb 23                	jmp    154 <strcmp+0x3c>
 131:	8d 76 00             	lea    0x0(%esi),%esi
 134:	41                   	inc    %ecx
 135:	38 d8                	cmp    %bl,%al
 137:	75 1b                	jne    154 <strcmp+0x3c>
    p++, q++;
 139:	89 f2                	mov    %esi,%edx
 13b:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 13e:	8a 41 01             	mov    0x1(%ecx),%al
 141:	8a 5a 01             	mov    0x1(%edx),%bl
 144:	84 c0                	test   %al,%al
 146:	75 ec                	jne    134 <strcmp+0x1c>
 148:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 14a:	0f b6 db             	movzbl %bl,%ebx
 14d:	29 d8                	sub    %ebx,%eax
}
 14f:	5b                   	pop    %ebx
 150:	5e                   	pop    %esi
 151:	5d                   	pop    %ebp
 152:	c3                   	ret    
 153:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 154:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 157:	0f b6 db             	movzbl %bl,%ebx
 15a:	29 d8                	sub    %ebx,%eax
}
 15c:	5b                   	pop    %ebx
 15d:	5e                   	pop    %esi
 15e:	5d                   	pop    %ebp
 15f:	c3                   	ret    

00000160 <strlen>:

uint
strlen(const char *s)
{
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 166:	80 39 00             	cmpb   $0x0,(%ecx)
 169:	74 10                	je     17b <strlen+0x1b>
 16b:	31 d2                	xor    %edx,%edx
 16d:	8d 76 00             	lea    0x0(%esi),%esi
 170:	42                   	inc    %edx
 171:	89 d0                	mov    %edx,%eax
 173:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 177:	75 f7                	jne    170 <strlen+0x10>
    ;
  return n;
}
 179:	5d                   	pop    %ebp
 17a:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
 17b:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
 17d:	5d                   	pop    %ebp
 17e:	c3                   	ret    
 17f:	90                   	nop

00000180 <memset>:

void*
memset(void *dst, int c, uint n)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	57                   	push   %edi
 184:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 187:	89 d7                	mov    %edx,%edi
 189:	8b 4d 10             	mov    0x10(%ebp),%ecx
 18c:	8b 45 0c             	mov    0xc(%ebp),%eax
 18f:	fc                   	cld    
 190:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 192:	89 d0                	mov    %edx,%eax
 194:	5f                   	pop    %edi
 195:	5d                   	pop    %ebp
 196:	c3                   	ret    
 197:	90                   	nop

00000198 <strchr>:

char*
strchr(const char *s, char c)
{
 198:	55                   	push   %ebp
 199:	89 e5                	mov    %esp,%ebp
 19b:	8b 45 08             	mov    0x8(%ebp),%eax
 19e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 1a1:	8a 10                	mov    (%eax),%dl
 1a3:	84 d2                	test   %dl,%dl
 1a5:	75 0d                	jne    1b4 <strchr+0x1c>
 1a7:	eb 13                	jmp    1bc <strchr+0x24>
 1a9:	8d 76 00             	lea    0x0(%esi),%esi
 1ac:	8a 50 01             	mov    0x1(%eax),%dl
 1af:	84 d2                	test   %dl,%dl
 1b1:	74 09                	je     1bc <strchr+0x24>
 1b3:	40                   	inc    %eax
    if(*s == c)
 1b4:	38 ca                	cmp    %cl,%dl
 1b6:	75 f4                	jne    1ac <strchr+0x14>
      return (char*)s;
  return 0;
}
 1b8:	5d                   	pop    %ebp
 1b9:	c3                   	ret    
 1ba:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 1bc:	31 c0                	xor    %eax,%eax
}
 1be:	5d                   	pop    %ebp
 1bf:	c3                   	ret    

000001c0 <gets>:

char*
gets(char *buf, int max)
{
 1c0:	55                   	push   %ebp
 1c1:	89 e5                	mov    %esp,%ebp
 1c3:	57                   	push   %edi
 1c4:	56                   	push   %esi
 1c5:	53                   	push   %ebx
 1c6:	83 ec 2c             	sub    $0x2c,%esp
 1c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1cc:	31 f6                	xor    %esi,%esi
 1ce:	eb 30                	jmp    200 <gets+0x40>
    cc = read(0, &c, 1);
 1d0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1d7:	00 
 1d8:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1db:	89 44 24 04          	mov    %eax,0x4(%esp)
 1df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1e6:	e8 ed 00 00 00       	call   2d8 <read>
    if(cc < 1)
 1eb:	85 c0                	test   %eax,%eax
 1ed:	7e 19                	jle    208 <gets+0x48>
      break;
    buf[i++] = c;
 1ef:	8a 45 e7             	mov    -0x19(%ebp),%al
 1f2:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f6:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1f8:	3c 0a                	cmp    $0xa,%al
 1fa:	74 0c                	je     208 <gets+0x48>
 1fc:	3c 0d                	cmp    $0xd,%al
 1fe:	74 08                	je     208 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 200:	8d 5e 01             	lea    0x1(%esi),%ebx
 203:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 206:	7c c8                	jl     1d0 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 208:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 20c:	89 f8                	mov    %edi,%eax
 20e:	83 c4 2c             	add    $0x2c,%esp
 211:	5b                   	pop    %ebx
 212:	5e                   	pop    %esi
 213:	5f                   	pop    %edi
 214:	5d                   	pop    %ebp
 215:	c3                   	ret    
 216:	66 90                	xchg   %ax,%ax

00000218 <stat>:

int
stat(const char *n, struct stat *st)
{
 218:	55                   	push   %ebp
 219:	89 e5                	mov    %esp,%ebp
 21b:	56                   	push   %esi
 21c:	53                   	push   %ebx
 21d:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 220:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 227:	00 
 228:	8b 45 08             	mov    0x8(%ebp),%eax
 22b:	89 04 24             	mov    %eax,(%esp)
 22e:	e8 cd 00 00 00       	call   300 <open>
 233:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 235:	85 c0                	test   %eax,%eax
 237:	78 23                	js     25c <stat+0x44>
    return -1;
  r = fstat(fd, st);
 239:	8b 45 0c             	mov    0xc(%ebp),%eax
 23c:	89 44 24 04          	mov    %eax,0x4(%esp)
 240:	89 1c 24             	mov    %ebx,(%esp)
 243:	e8 d0 00 00 00       	call   318 <fstat>
 248:	89 c6                	mov    %eax,%esi
  close(fd);
 24a:	89 1c 24             	mov    %ebx,(%esp)
 24d:	e8 96 00 00 00       	call   2e8 <close>
  return r;
}
 252:	89 f0                	mov    %esi,%eax
 254:	83 c4 10             	add    $0x10,%esp
 257:	5b                   	pop    %ebx
 258:	5e                   	pop    %esi
 259:	5d                   	pop    %ebp
 25a:	c3                   	ret    
 25b:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 25c:	be ff ff ff ff       	mov    $0xffffffff,%esi
 261:	eb ef                	jmp    252 <stat+0x3a>
 263:	90                   	nop

00000264 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 264:	55                   	push   %ebp
 265:	89 e5                	mov    %esp,%ebp
 267:	53                   	push   %ebx
 268:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 26b:	8a 11                	mov    (%ecx),%dl
 26d:	8d 42 d0             	lea    -0x30(%edx),%eax
 270:	3c 09                	cmp    $0x9,%al
 272:	b8 00 00 00 00       	mov    $0x0,%eax
 277:	77 18                	ja     291 <atoi+0x2d>
 279:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 27c:	8d 04 80             	lea    (%eax,%eax,4),%eax
 27f:	0f be d2             	movsbl %dl,%edx
 282:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 286:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 287:	8a 11                	mov    (%ecx),%dl
 289:	8d 5a d0             	lea    -0x30(%edx),%ebx
 28c:	80 fb 09             	cmp    $0x9,%bl
 28f:	76 eb                	jbe    27c <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 291:	5b                   	pop    %ebx
 292:	5d                   	pop    %ebp
 293:	c3                   	ret    

00000294 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 294:	55                   	push   %ebp
 295:	89 e5                	mov    %esp,%ebp
 297:	56                   	push   %esi
 298:	53                   	push   %ebx
 299:	8b 45 08             	mov    0x8(%ebp),%eax
 29c:	8b 75 0c             	mov    0xc(%ebp),%esi
 29f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2a2:	85 db                	test   %ebx,%ebx
 2a4:	7e 0d                	jle    2b3 <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 2a6:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 2a8:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 2ab:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 2ae:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2af:	39 da                	cmp    %ebx,%edx
 2b1:	75 f5                	jne    2a8 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 2b3:	5b                   	pop    %ebx
 2b4:	5e                   	pop    %esi
 2b5:	5d                   	pop    %ebp
 2b6:	c3                   	ret    
 2b7:	90                   	nop

000002b8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2b8:	b8 01 00 00 00       	mov    $0x1,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <exit>:
SYSCALL(exit)
 2c0:	b8 02 00 00 00       	mov    $0x2,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <wait>:
SYSCALL(wait)
 2c8:	b8 03 00 00 00       	mov    $0x3,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <pipe>:
SYSCALL(pipe)
 2d0:	b8 04 00 00 00       	mov    $0x4,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <read>:
SYSCALL(read)
 2d8:	b8 05 00 00 00       	mov    $0x5,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <write>:
SYSCALL(write)
 2e0:	b8 10 00 00 00       	mov    $0x10,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <close>:
SYSCALL(close)
 2e8:	b8 15 00 00 00       	mov    $0x15,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <kill>:
SYSCALL(kill)
 2f0:	b8 06 00 00 00       	mov    $0x6,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <exec>:
SYSCALL(exec)
 2f8:	b8 07 00 00 00       	mov    $0x7,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <open>:
SYSCALL(open)
 300:	b8 0f 00 00 00       	mov    $0xf,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <mknod>:
SYSCALL(mknod)
 308:	b8 11 00 00 00       	mov    $0x11,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <unlink>:
SYSCALL(unlink)
 310:	b8 12 00 00 00       	mov    $0x12,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <fstat>:
SYSCALL(fstat)
 318:	b8 08 00 00 00       	mov    $0x8,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <link>:
SYSCALL(link)
 320:	b8 13 00 00 00       	mov    $0x13,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <mkdir>:
SYSCALL(mkdir)
 328:	b8 14 00 00 00       	mov    $0x14,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <chdir>:
SYSCALL(chdir)
 330:	b8 09 00 00 00       	mov    $0x9,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <dup>:
SYSCALL(dup)
 338:	b8 0a 00 00 00       	mov    $0xa,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <getpid>:
SYSCALL(getpid)
 340:	b8 0b 00 00 00       	mov    $0xb,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <sbrk>:
SYSCALL(sbrk)
 348:	b8 0c 00 00 00       	mov    $0xc,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <sleep>:
SYSCALL(sleep)
 350:	b8 0d 00 00 00       	mov    $0xd,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <uptime>:
SYSCALL(uptime)
 358:	b8 0e 00 00 00       	mov    $0xe,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <date>:
SYSCALL(date)
 360:	b8 16 00 00 00       	mov    $0x16,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    
