
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	83 ec 10             	sub    $0x10,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  11:	00 
  12:	c7 04 24 92 06 00 00 	movl   $0x692,(%esp)
  19:	e8 ea 02 00 00       	call   308 <open>
  1e:	85 c0                	test   %eax,%eax
  20:	0f 88 a7 00 00 00    	js     cd <main+0xcd>
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  2d:	e8 0e 03 00 00       	call   340 <dup>
  dup(0);  // stderr
  32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  39:	e8 02 03 00 00       	call   340 <dup>
  3e:	66 90                	xchg   %ax,%ax

  for(;;){
    printf(1, "init: starting sh\n");
  40:	c7 44 24 04 9a 06 00 	movl   $0x69a,0x4(%esp)
  47:	00 
  48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  4f:	e8 ac 03 00 00       	call   400 <printf>
    pid = fork();
  54:	e8 67 02 00 00       	call   2c0 <fork>
  59:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
  5b:	83 f8 00             	cmp    $0x0,%eax
  5e:	7c 27                	jl     87 <main+0x87>
      printf(1, "init: fork failed\n");
      exit();
    }
    if(pid == 0){
  60:	74 3e                	je     a0 <main+0xa0>
  62:	66 90                	xchg   %ax,%ax
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  64:	e8 67 02 00 00       	call   2d0 <wait>
  69:	85 c0                	test   %eax,%eax
  6b:	78 d3                	js     40 <main+0x40>
  6d:	39 d8                	cmp    %ebx,%eax
  6f:	74 cf                	je     40 <main+0x40>
      printf(1, "zombie!\n");
  71:	c7 44 24 04 d9 06 00 	movl   $0x6d9,0x4(%esp)
  78:	00 
  79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80:	e8 7b 03 00 00       	call   400 <printf>
  85:	eb dd                	jmp    64 <main+0x64>

  for(;;){
    printf(1, "init: starting sh\n");
    pid = fork();
    if(pid < 0){
      printf(1, "init: fork failed\n");
  87:	c7 44 24 04 ad 06 00 	movl   $0x6ad,0x4(%esp)
  8e:	00 
  8f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  96:	e8 65 03 00 00       	call   400 <printf>
      exit();
  9b:	e8 28 02 00 00       	call   2c8 <exit>
    }
    if(pid == 0){
      exec("sh", argv);
  a0:	c7 44 24 04 9c 09 00 	movl   $0x99c,0x4(%esp)
  a7:	00 
  a8:	c7 04 24 c0 06 00 00 	movl   $0x6c0,(%esp)
  af:	e8 4c 02 00 00       	call   300 <exec>
      printf(1, "init: exec sh failed\n");
  b4:	c7 44 24 04 c3 06 00 	movl   $0x6c3,0x4(%esp)
  bb:	00 
  bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c3:	e8 38 03 00 00       	call   400 <printf>
      exit();
  c8:	e8 fb 01 00 00       	call   2c8 <exit>
main(void)
{
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
    mknod("console", 1, 1);
  cd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  d4:	00 
  d5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  dc:	00 
  dd:	c7 04 24 92 06 00 00 	movl   $0x692,(%esp)
  e4:	e8 27 02 00 00       	call   310 <mknod>
    open("console", O_RDWR);
  e9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  f0:	00 
  f1:	c7 04 24 92 06 00 00 	movl   $0x692,(%esp)
  f8:	e8 0b 02 00 00       	call   308 <open>
  fd:	e9 24 ff ff ff       	jmp    26 <main+0x26>
 102:	90                   	nop
 103:	90                   	nop

00000104 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	53                   	push   %ebx
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 10e:	31 d2                	xor    %edx,%edx
 110:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
 113:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 116:	42                   	inc    %edx
 117:	84 c9                	test   %cl,%cl
 119:	75 f5                	jne    110 <strcpy+0xc>
    ;
  return os;
}
 11b:	5b                   	pop    %ebx
 11c:	5d                   	pop    %ebp
 11d:	c3                   	ret    
 11e:	66 90                	xchg   %ax,%ax

00000120 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	56                   	push   %esi
 124:	53                   	push   %ebx
 125:	8b 4d 08             	mov    0x8(%ebp),%ecx
 128:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 12b:	8a 01                	mov    (%ecx),%al
 12d:	8a 1a                	mov    (%edx),%bl
 12f:	84 c0                	test   %al,%al
 131:	74 1d                	je     150 <strcmp+0x30>
 133:	38 d8                	cmp    %bl,%al
 135:	74 0c                	je     143 <strcmp+0x23>
 137:	eb 23                	jmp    15c <strcmp+0x3c>
 139:	8d 76 00             	lea    0x0(%esi),%esi
 13c:	41                   	inc    %ecx
 13d:	38 d8                	cmp    %bl,%al
 13f:	75 1b                	jne    15c <strcmp+0x3c>
    p++, q++;
 141:	89 f2                	mov    %esi,%edx
 143:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 146:	8a 41 01             	mov    0x1(%ecx),%al
 149:	8a 5a 01             	mov    0x1(%edx),%bl
 14c:	84 c0                	test   %al,%al
 14e:	75 ec                	jne    13c <strcmp+0x1c>
 150:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 152:	0f b6 db             	movzbl %bl,%ebx
 155:	29 d8                	sub    %ebx,%eax
}
 157:	5b                   	pop    %ebx
 158:	5e                   	pop    %esi
 159:	5d                   	pop    %ebp
 15a:	c3                   	ret    
 15b:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 15c:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 15f:	0f b6 db             	movzbl %bl,%ebx
 162:	29 d8                	sub    %ebx,%eax
}
 164:	5b                   	pop    %ebx
 165:	5e                   	pop    %esi
 166:	5d                   	pop    %ebp
 167:	c3                   	ret    

00000168 <strlen>:

uint
strlen(const char *s)
{
 168:	55                   	push   %ebp
 169:	89 e5                	mov    %esp,%ebp
 16b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 16e:	80 39 00             	cmpb   $0x0,(%ecx)
 171:	74 10                	je     183 <strlen+0x1b>
 173:	31 d2                	xor    %edx,%edx
 175:	8d 76 00             	lea    0x0(%esi),%esi
 178:	42                   	inc    %edx
 179:	89 d0                	mov    %edx,%eax
 17b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 17f:	75 f7                	jne    178 <strlen+0x10>
    ;
  return n;
}
 181:	5d                   	pop    %ebp
 182:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
 183:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
 185:	5d                   	pop    %ebp
 186:	c3                   	ret    
 187:	90                   	nop

00000188 <memset>:

void*
memset(void *dst, int c, uint n)
{
 188:	55                   	push   %ebp
 189:	89 e5                	mov    %esp,%ebp
 18b:	57                   	push   %edi
 18c:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 18f:	89 d7                	mov    %edx,%edi
 191:	8b 4d 10             	mov    0x10(%ebp),%ecx
 194:	8b 45 0c             	mov    0xc(%ebp),%eax
 197:	fc                   	cld    
 198:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 19a:	89 d0                	mov    %edx,%eax
 19c:	5f                   	pop    %edi
 19d:	5d                   	pop    %ebp
 19e:	c3                   	ret    
 19f:	90                   	nop

000001a0 <strchr>:

char*
strchr(const char *s, char c)
{
 1a0:	55                   	push   %ebp
 1a1:	89 e5                	mov    %esp,%ebp
 1a3:	8b 45 08             	mov    0x8(%ebp),%eax
 1a6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 1a9:	8a 10                	mov    (%eax),%dl
 1ab:	84 d2                	test   %dl,%dl
 1ad:	75 0d                	jne    1bc <strchr+0x1c>
 1af:	eb 13                	jmp    1c4 <strchr+0x24>
 1b1:	8d 76 00             	lea    0x0(%esi),%esi
 1b4:	8a 50 01             	mov    0x1(%eax),%dl
 1b7:	84 d2                	test   %dl,%dl
 1b9:	74 09                	je     1c4 <strchr+0x24>
 1bb:	40                   	inc    %eax
    if(*s == c)
 1bc:	38 ca                	cmp    %cl,%dl
 1be:	75 f4                	jne    1b4 <strchr+0x14>
      return (char*)s;
  return 0;
}
 1c0:	5d                   	pop    %ebp
 1c1:	c3                   	ret    
 1c2:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 1c4:	31 c0                	xor    %eax,%eax
}
 1c6:	5d                   	pop    %ebp
 1c7:	c3                   	ret    

000001c8 <gets>:

char*
gets(char *buf, int max)
{
 1c8:	55                   	push   %ebp
 1c9:	89 e5                	mov    %esp,%ebp
 1cb:	57                   	push   %edi
 1cc:	56                   	push   %esi
 1cd:	53                   	push   %ebx
 1ce:	83 ec 2c             	sub    $0x2c,%esp
 1d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d4:	31 f6                	xor    %esi,%esi
 1d6:	eb 30                	jmp    208 <gets+0x40>
    cc = read(0, &c, 1);
 1d8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1df:	00 
 1e0:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1ee:	e8 ed 00 00 00       	call   2e0 <read>
    if(cc < 1)
 1f3:	85 c0                	test   %eax,%eax
 1f5:	7e 19                	jle    210 <gets+0x48>
      break;
    buf[i++] = c;
 1f7:	8a 45 e7             	mov    -0x19(%ebp),%al
 1fa:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fe:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 200:	3c 0a                	cmp    $0xa,%al
 202:	74 0c                	je     210 <gets+0x48>
 204:	3c 0d                	cmp    $0xd,%al
 206:	74 08                	je     210 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 208:	8d 5e 01             	lea    0x1(%esi),%ebx
 20b:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 20e:	7c c8                	jl     1d8 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 210:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 214:	89 f8                	mov    %edi,%eax
 216:	83 c4 2c             	add    $0x2c,%esp
 219:	5b                   	pop    %ebx
 21a:	5e                   	pop    %esi
 21b:	5f                   	pop    %edi
 21c:	5d                   	pop    %ebp
 21d:	c3                   	ret    
 21e:	66 90                	xchg   %ax,%ax

00000220 <stat>:

int
stat(const char *n, struct stat *st)
{
 220:	55                   	push   %ebp
 221:	89 e5                	mov    %esp,%ebp
 223:	56                   	push   %esi
 224:	53                   	push   %ebx
 225:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 228:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 22f:	00 
 230:	8b 45 08             	mov    0x8(%ebp),%eax
 233:	89 04 24             	mov    %eax,(%esp)
 236:	e8 cd 00 00 00       	call   308 <open>
 23b:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 23d:	85 c0                	test   %eax,%eax
 23f:	78 23                	js     264 <stat+0x44>
    return -1;
  r = fstat(fd, st);
 241:	8b 45 0c             	mov    0xc(%ebp),%eax
 244:	89 44 24 04          	mov    %eax,0x4(%esp)
 248:	89 1c 24             	mov    %ebx,(%esp)
 24b:	e8 d0 00 00 00       	call   320 <fstat>
 250:	89 c6                	mov    %eax,%esi
  close(fd);
 252:	89 1c 24             	mov    %ebx,(%esp)
 255:	e8 96 00 00 00       	call   2f0 <close>
  return r;
}
 25a:	89 f0                	mov    %esi,%eax
 25c:	83 c4 10             	add    $0x10,%esp
 25f:	5b                   	pop    %ebx
 260:	5e                   	pop    %esi
 261:	5d                   	pop    %ebp
 262:	c3                   	ret    
 263:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 264:	be ff ff ff ff       	mov    $0xffffffff,%esi
 269:	eb ef                	jmp    25a <stat+0x3a>
 26b:	90                   	nop

0000026c <atoi>:
  return r;
}

int
atoi(const char *s)
{
 26c:	55                   	push   %ebp
 26d:	89 e5                	mov    %esp,%ebp
 26f:	53                   	push   %ebx
 270:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 273:	8a 11                	mov    (%ecx),%dl
 275:	8d 42 d0             	lea    -0x30(%edx),%eax
 278:	3c 09                	cmp    $0x9,%al
 27a:	b8 00 00 00 00       	mov    $0x0,%eax
 27f:	77 18                	ja     299 <atoi+0x2d>
 281:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 284:	8d 04 80             	lea    (%eax,%eax,4),%eax
 287:	0f be d2             	movsbl %dl,%edx
 28a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 28e:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28f:	8a 11                	mov    (%ecx),%dl
 291:	8d 5a d0             	lea    -0x30(%edx),%ebx
 294:	80 fb 09             	cmp    $0x9,%bl
 297:	76 eb                	jbe    284 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 299:	5b                   	pop    %ebx
 29a:	5d                   	pop    %ebp
 29b:	c3                   	ret    

0000029c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 29c:	55                   	push   %ebp
 29d:	89 e5                	mov    %esp,%ebp
 29f:	56                   	push   %esi
 2a0:	53                   	push   %ebx
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	8b 75 0c             	mov    0xc(%ebp),%esi
 2a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2aa:	85 db                	test   %ebx,%ebx
 2ac:	7e 0d                	jle    2bb <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 2ae:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 2b0:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 2b3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 2b6:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b7:	39 da                	cmp    %ebx,%edx
 2b9:	75 f5                	jne    2b0 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 2bb:	5b                   	pop    %ebx
 2bc:	5e                   	pop    %esi
 2bd:	5d                   	pop    %ebp
 2be:	c3                   	ret    
 2bf:	90                   	nop

000002c0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c0:	b8 01 00 00 00       	mov    $0x1,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <exit>:
SYSCALL(exit)
 2c8:	b8 02 00 00 00       	mov    $0x2,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <wait>:
SYSCALL(wait)
 2d0:	b8 03 00 00 00       	mov    $0x3,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <pipe>:
SYSCALL(pipe)
 2d8:	b8 04 00 00 00       	mov    $0x4,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <read>:
SYSCALL(read)
 2e0:	b8 05 00 00 00       	mov    $0x5,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <write>:
SYSCALL(write)
 2e8:	b8 10 00 00 00       	mov    $0x10,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <close>:
SYSCALL(close)
 2f0:	b8 15 00 00 00       	mov    $0x15,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <kill>:
SYSCALL(kill)
 2f8:	b8 06 00 00 00       	mov    $0x6,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <exec>:
SYSCALL(exec)
 300:	b8 07 00 00 00       	mov    $0x7,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <open>:
SYSCALL(open)
 308:	b8 0f 00 00 00       	mov    $0xf,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <mknod>:
SYSCALL(mknod)
 310:	b8 11 00 00 00       	mov    $0x11,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <unlink>:
SYSCALL(unlink)
 318:	b8 12 00 00 00       	mov    $0x12,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <fstat>:
SYSCALL(fstat)
 320:	b8 08 00 00 00       	mov    $0x8,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <link>:
SYSCALL(link)
 328:	b8 13 00 00 00       	mov    $0x13,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <mkdir>:
SYSCALL(mkdir)
 330:	b8 14 00 00 00       	mov    $0x14,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <chdir>:
SYSCALL(chdir)
 338:	b8 09 00 00 00       	mov    $0x9,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <dup>:
SYSCALL(dup)
 340:	b8 0a 00 00 00       	mov    $0xa,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <getpid>:
SYSCALL(getpid)
 348:	b8 0b 00 00 00       	mov    $0xb,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <sbrk>:
SYSCALL(sbrk)
 350:	b8 0c 00 00 00       	mov    $0xc,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <sleep>:
SYSCALL(sleep)
 358:	b8 0d 00 00 00       	mov    $0xd,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <uptime>:
SYSCALL(uptime)
 360:	b8 0e 00 00 00       	mov    $0xe,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <date>:
SYSCALL(date)
 368:	b8 16 00 00 00       	mov    $0x16,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 370:	55                   	push   %ebp
 371:	89 e5                	mov    %esp,%ebp
 373:	83 ec 28             	sub    $0x28,%esp
 376:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 379:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 380:	00 
 381:	8d 55 f4             	lea    -0xc(%ebp),%edx
 384:	89 54 24 04          	mov    %edx,0x4(%esp)
 388:	89 04 24             	mov    %eax,(%esp)
 38b:	e8 58 ff ff ff       	call   2e8 <write>
}
 390:	c9                   	leave  
 391:	c3                   	ret    
 392:	66 90                	xchg   %ax,%ax

00000394 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 394:	55                   	push   %ebp
 395:	89 e5                	mov    %esp,%ebp
 397:	57                   	push   %edi
 398:	56                   	push   %esi
 399:	53                   	push   %ebx
 39a:	83 ec 1c             	sub    $0x1c,%esp
 39d:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 39f:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
 3a4:	85 db                	test   %ebx,%ebx
 3a6:	74 04                	je     3ac <printint+0x18>
 3a8:	85 d2                	test   %edx,%edx
 3aa:	78 4a                	js     3f6 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3ac:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3ae:	31 db                	xor    %ebx,%ebx
 3b0:	eb 04                	jmp    3b6 <printint+0x22>
 3b2:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 3b4:	89 d3                	mov    %edx,%ebx
 3b6:	31 d2                	xor    %edx,%edx
 3b8:	f7 f1                	div    %ecx
 3ba:	8a 92 e9 06 00 00    	mov    0x6e9(%edx),%dl
 3c0:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 3c4:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 3c7:	85 c0                	test   %eax,%eax
 3c9:	75 e9                	jne    3b4 <printint+0x20>
  if(neg)
 3cb:	85 ff                	test   %edi,%edi
 3cd:	74 08                	je     3d7 <printint+0x43>
    buf[i++] = '-';
 3cf:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 3d4:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 3d7:	8d 5a ff             	lea    -0x1(%edx),%ebx
 3da:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 3dc:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3e1:	89 f0                	mov    %esi,%eax
 3e3:	e8 88 ff ff ff       	call   370 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3e8:	4b                   	dec    %ebx
 3e9:	83 fb ff             	cmp    $0xffffffff,%ebx
 3ec:	75 ee                	jne    3dc <printint+0x48>
    putc(fd, buf[i]);
}
 3ee:	83 c4 1c             	add    $0x1c,%esp
 3f1:	5b                   	pop    %ebx
 3f2:	5e                   	pop    %esi
 3f3:	5f                   	pop    %edi
 3f4:	5d                   	pop    %ebp
 3f5:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 3f6:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 3f8:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 3fd:	eb af                	jmp    3ae <printint+0x1a>
 3ff:	90                   	nop

00000400 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 400:	55                   	push   %ebp
 401:	89 e5                	mov    %esp,%ebp
 403:	57                   	push   %edi
 404:	56                   	push   %esi
 405:	53                   	push   %ebx
 406:	83 ec 2c             	sub    $0x2c,%esp
 409:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 40c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 40f:	8a 0b                	mov    (%ebx),%cl
 411:	84 c9                	test   %cl,%cl
 413:	74 7b                	je     490 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 415:	8d 45 10             	lea    0x10(%ebp),%eax
 418:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 41b:	31 f6                	xor    %esi,%esi
 41d:	eb 17                	jmp    436 <printf+0x36>
 41f:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 420:	83 f9 25             	cmp    $0x25,%ecx
 423:	74 73                	je     498 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 425:	0f be d1             	movsbl %cl,%edx
 428:	89 f8                	mov    %edi,%eax
 42a:	e8 41 ff ff ff       	call   370 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 42f:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 430:	8a 0b                	mov    (%ebx),%cl
 432:	84 c9                	test   %cl,%cl
 434:	74 5a                	je     490 <printf+0x90>
    c = fmt[i] & 0xff;
 436:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 439:	85 f6                	test   %esi,%esi
 43b:	74 e3                	je     420 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 43d:	83 fe 25             	cmp    $0x25,%esi
 440:	75 ed                	jne    42f <printf+0x2f>
      if(c == 'd'){
 442:	83 f9 64             	cmp    $0x64,%ecx
 445:	0f 84 c1 00 00 00    	je     50c <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 44b:	83 f9 78             	cmp    $0x78,%ecx
 44e:	74 50                	je     4a0 <printf+0xa0>
 450:	83 f9 70             	cmp    $0x70,%ecx
 453:	74 4b                	je     4a0 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 455:	83 f9 73             	cmp    $0x73,%ecx
 458:	74 6a                	je     4c4 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 45a:	83 f9 63             	cmp    $0x63,%ecx
 45d:	0f 84 91 00 00 00    	je     4f4 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 463:	ba 25 00 00 00       	mov    $0x25,%edx
 468:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 46a:	83 f9 25             	cmp    $0x25,%ecx
 46d:	74 10                	je     47f <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 46f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 472:	e8 f9 fe ff ff       	call   370 <putc>
        putc(fd, c);
 477:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 47a:	0f be d1             	movsbl %cl,%edx
 47d:	89 f8                	mov    %edi,%eax
 47f:	e8 ec fe ff ff       	call   370 <putc>
      }
      state = 0;
 484:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 486:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 487:	8a 0b                	mov    (%ebx),%cl
 489:	84 c9                	test   %cl,%cl
 48b:	75 a9                	jne    436 <printf+0x36>
 48d:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 490:	83 c4 2c             	add    $0x2c,%esp
 493:	5b                   	pop    %ebx
 494:	5e                   	pop    %esi
 495:	5f                   	pop    %edi
 496:	5d                   	pop    %ebp
 497:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 498:	be 25 00 00 00       	mov    $0x25,%esi
 49d:	eb 90                	jmp    42f <printf+0x2f>
 49f:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 4a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4a7:	b9 10 00 00 00       	mov    $0x10,%ecx
 4ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4af:	8b 10                	mov    (%eax),%edx
 4b1:	89 f8                	mov    %edi,%eax
 4b3:	e8 dc fe ff ff       	call   394 <printint>
        ap++;
 4b8:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4bc:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 4be:	e9 6c ff ff ff       	jmp    42f <printf+0x2f>
 4c3:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 4c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4c7:	8b 30                	mov    (%eax),%esi
        ap++;
 4c9:	83 c0 04             	add    $0x4,%eax
 4cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4cf:	85 f6                	test   %esi,%esi
 4d1:	74 5a                	je     52d <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 4d3:	8a 16                	mov    (%esi),%dl
 4d5:	84 d2                	test   %dl,%dl
 4d7:	74 14                	je     4ed <printf+0xed>
 4d9:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 4dc:	0f be d2             	movsbl %dl,%edx
 4df:	89 f8                	mov    %edi,%eax
 4e1:	e8 8a fe ff ff       	call   370 <putc>
          s++;
 4e6:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 4e7:	8a 16                	mov    (%esi),%dl
 4e9:	84 d2                	test   %dl,%dl
 4eb:	75 ef                	jne    4dc <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4ed:	31 f6                	xor    %esi,%esi
 4ef:	e9 3b ff ff ff       	jmp    42f <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 4f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4f7:	0f be 10             	movsbl (%eax),%edx
 4fa:	89 f8                	mov    %edi,%eax
 4fc:	e8 6f fe ff ff       	call   370 <putc>
        ap++;
 501:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 505:	31 f6                	xor    %esi,%esi
 507:	e9 23 ff ff ff       	jmp    42f <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 50c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 513:	b1 0a                	mov    $0xa,%cl
 515:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 518:	8b 10                	mov    (%eax),%edx
 51a:	89 f8                	mov    %edi,%eax
 51c:	e8 73 fe ff ff       	call   394 <printint>
        ap++;
 521:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 525:	66 31 f6             	xor    %si,%si
 528:	e9 02 ff ff ff       	jmp    42f <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 52d:	be e2 06 00 00       	mov    $0x6e2,%esi
 532:	eb 9f                	jmp    4d3 <printf+0xd3>

00000534 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 534:	55                   	push   %ebp
 535:	89 e5                	mov    %esp,%ebp
 537:	57                   	push   %edi
 538:	56                   	push   %esi
 539:	53                   	push   %ebx
 53a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 53d:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 540:	a1 a4 09 00 00       	mov    0x9a4,%eax
 545:	8d 76 00             	lea    0x0(%esi),%esi
 548:	8b 10                	mov    (%eax),%edx
 54a:	39 c8                	cmp    %ecx,%eax
 54c:	73 04                	jae    552 <free+0x1e>
 54e:	39 d1                	cmp    %edx,%ecx
 550:	72 12                	jb     564 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 552:	39 d0                	cmp    %edx,%eax
 554:	72 08                	jb     55e <free+0x2a>
 556:	39 c8                	cmp    %ecx,%eax
 558:	72 0a                	jb     564 <free+0x30>
 55a:	39 d1                	cmp    %edx,%ecx
 55c:	72 06                	jb     564 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 55e:	89 d0                	mov    %edx,%eax
 560:	eb e6                	jmp    548 <free+0x14>
 562:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 564:	8b 73 fc             	mov    -0x4(%ebx),%esi
 567:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 56a:	39 d7                	cmp    %edx,%edi
 56c:	74 19                	je     587 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 56e:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 571:	8b 50 04             	mov    0x4(%eax),%edx
 574:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 577:	39 f1                	cmp    %esi,%ecx
 579:	74 23                	je     59e <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 57b:	89 08                	mov    %ecx,(%eax)
  freep = p;
 57d:	a3 a4 09 00 00       	mov    %eax,0x9a4
}
 582:	5b                   	pop    %ebx
 583:	5e                   	pop    %esi
 584:	5f                   	pop    %edi
 585:	5d                   	pop    %ebp
 586:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 587:	03 72 04             	add    0x4(%edx),%esi
 58a:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 58d:	8b 10                	mov    (%eax),%edx
 58f:	8b 12                	mov    (%edx),%edx
 591:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 594:	8b 50 04             	mov    0x4(%eax),%edx
 597:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 59a:	39 f1                	cmp    %esi,%ecx
 59c:	75 dd                	jne    57b <free+0x47>
    p->s.size += bp->s.size;
 59e:	03 53 fc             	add    -0x4(%ebx),%edx
 5a1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5a4:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5a7:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 5a9:	a3 a4 09 00 00       	mov    %eax,0x9a4
}
 5ae:	5b                   	pop    %ebx
 5af:	5e                   	pop    %esi
 5b0:	5f                   	pop    %edi
 5b1:	5d                   	pop    %ebp
 5b2:	c3                   	ret    
 5b3:	90                   	nop

000005b4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 5b4:	55                   	push   %ebp
 5b5:	89 e5                	mov    %esp,%ebp
 5b7:	57                   	push   %edi
 5b8:	56                   	push   %esi
 5b9:	53                   	push   %ebx
 5ba:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
 5c0:	83 c3 07             	add    $0x7,%ebx
 5c3:	c1 eb 03             	shr    $0x3,%ebx
 5c6:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 5c7:	8b 0d a4 09 00 00    	mov    0x9a4,%ecx
 5cd:	85 c9                	test   %ecx,%ecx
 5cf:	0f 84 95 00 00 00    	je     66a <malloc+0xb6>
 5d5:	8b 01                	mov    (%ecx),%eax
 5d7:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 5da:	39 da                	cmp    %ebx,%edx
 5dc:	73 66                	jae    644 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 5de:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 5e5:	eb 0c                	jmp    5f3 <malloc+0x3f>
 5e7:	90                   	nop
    }
    if(p == freep)
 5e8:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5ea:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 5ec:	8b 50 04             	mov    0x4(%eax),%edx
 5ef:	39 d3                	cmp    %edx,%ebx
 5f1:	76 51                	jbe    644 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 5f3:	3b 05 a4 09 00 00    	cmp    0x9a4,%eax
 5f9:	75 ed                	jne    5e8 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 5fb:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 601:	76 35                	jbe    638 <malloc+0x84>
 603:	89 f8                	mov    %edi,%eax
 605:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 607:	89 04 24             	mov    %eax,(%esp)
 60a:	e8 41 fd ff ff       	call   350 <sbrk>
  if(p == (char*)-1)
 60f:	83 f8 ff             	cmp    $0xffffffff,%eax
 612:	74 18                	je     62c <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 614:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 617:	83 c0 08             	add    $0x8,%eax
 61a:	89 04 24             	mov    %eax,(%esp)
 61d:	e8 12 ff ff ff       	call   534 <free>
  return freep;
 622:	8b 0d a4 09 00 00    	mov    0x9a4,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 628:	85 c9                	test   %ecx,%ecx
 62a:	75 be                	jne    5ea <malloc+0x36>
        return 0;
 62c:	31 c0                	xor    %eax,%eax
  }
}
 62e:	83 c4 1c             	add    $0x1c,%esp
 631:	5b                   	pop    %ebx
 632:	5e                   	pop    %esi
 633:	5f                   	pop    %edi
 634:	5d                   	pop    %ebp
 635:	c3                   	ret    
 636:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 638:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 63d:	be 00 10 00 00       	mov    $0x1000,%esi
 642:	eb c3                	jmp    607 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 644:	39 d3                	cmp    %edx,%ebx
 646:	74 1c                	je     664 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 648:	29 da                	sub    %ebx,%edx
 64a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 64d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 650:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 653:	89 0d a4 09 00 00    	mov    %ecx,0x9a4
      return (void*)(p + 1);
 659:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 65c:	83 c4 1c             	add    $0x1c,%esp
 65f:	5b                   	pop    %ebx
 660:	5e                   	pop    %esi
 661:	5f                   	pop    %edi
 662:	5d                   	pop    %ebp
 663:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 664:	8b 10                	mov    (%eax),%edx
 666:	89 11                	mov    %edx,(%ecx)
 668:	eb e9                	jmp    653 <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 66a:	c7 05 a4 09 00 00 a8 	movl   $0x9a8,0x9a4
 671:	09 00 00 
 674:	c7 05 a8 09 00 00 a8 	movl   $0x9a8,0x9a8
 67b:	09 00 00 
    base.s.size = 0;
 67e:	c7 05 ac 09 00 00 00 	movl   $0x0,0x9ac
 685:	00 00 00 
 688:	b8 a8 09 00 00       	mov    $0x9a8,%eax
 68d:	e9 4c ff ff ff       	jmp    5de <malloc+0x2a>
