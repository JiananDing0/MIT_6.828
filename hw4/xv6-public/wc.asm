
_wc:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
  printf(1, "%d %d %d %s\n", l, w, c, name);
}

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	83 ec 20             	sub    $0x20,%esp
   c:	8b 7d 08             	mov    0x8(%ebp),%edi
  int fd, i;

  if(argc <= 1){
   f:	83 ff 01             	cmp    $0x1,%edi
  12:	7e 6c                	jle    80 <main+0x80>
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
}

int
main(int argc, char *argv[])
  14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  17:	83 c3 04             	add    $0x4,%ebx
  1a:	be 01 00 00 00       	mov    $0x1,%esi
  1f:	90                   	nop
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  20:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  27:	00 
  28:	8b 03                	mov    (%ebx),%eax
  2a:	89 04 24             	mov    %eax,(%esp)
  2d:	e8 5e 03 00 00       	call   390 <open>
  32:	85 c0                	test   %eax,%eax
  34:	78 2b                	js     61 <main+0x61>
      printf(1, "wc: cannot open %s\n", argv[i]);
      exit();
    }
    wc(fd, argv[i]);
  36:	8b 13                	mov    (%ebx),%edx
  38:	89 54 24 04          	mov    %edx,0x4(%esp)
  3c:	89 04 24             	mov    %eax,(%esp)
  3f:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  43:	e8 54 00 00 00       	call   9c <wc>
    close(fd);
  48:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  4c:	89 04 24             	mov    %eax,(%esp)
  4f:	e8 24 03 00 00       	call   378 <close>
  if(argc <= 1){
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
  54:	46                   	inc    %esi
  55:	83 c3 04             	add    $0x4,%ebx
  58:	39 fe                	cmp    %edi,%esi
  5a:	75 c4                	jne    20 <main+0x20>
      exit();
    }
    wc(fd, argv[i]);
    close(fd);
  }
  exit();
  5c:	e8 ef 02 00 00       	call   350 <exit>
    exit();
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
      printf(1, "wc: cannot open %s\n", argv[i]);
  61:	8b 03                	mov    (%ebx),%eax
  63:	89 44 24 08          	mov    %eax,0x8(%esp)
  67:	c7 44 24 04 35 07 00 	movl   $0x735,0x4(%esp)
  6e:	00 
  6f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  76:	e8 05 04 00 00       	call   480 <printf>
      exit();
  7b:	e8 d0 02 00 00       	call   350 <exit>
main(int argc, char *argv[])
{
  int fd, i;

  if(argc <= 1){
    wc(0, "");
  80:	c7 44 24 04 27 07 00 	movl   $0x727,0x4(%esp)
  87:	00 
  88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8f:	e8 08 00 00 00       	call   9c <wc>
    exit();
  94:	e8 b7 02 00 00       	call   350 <exit>
  99:	90                   	nop
  9a:	90                   	nop
  9b:	90                   	nop

0000009c <wc>:

char buf[512];

void
wc(int fd, char *name)
{
  9c:	55                   	push   %ebp
  9d:	89 e5                	mov    %esp,%ebp
  9f:	57                   	push   %edi
  a0:	56                   	push   %esi
  a1:	53                   	push   %ebx
  a2:	83 ec 3c             	sub    $0x3c,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  a5:	31 f6                	xor    %esi,%esi
wc(int fd, char *name)
{
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  a7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  ae:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  b5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
  bc:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  c3:	00 
  c4:	c7 44 24 04 60 0a 00 	movl   $0xa60,0x4(%esp)
  cb:	00 
  cc:	8b 45 08             	mov    0x8(%ebp),%eax
  cf:	89 04 24             	mov    %eax,(%esp)
  d2:	e8 91 02 00 00       	call   368 <read>
  d7:	89 c7                	mov    %eax,%edi
  d9:	83 f8 00             	cmp    $0x0,%eax
  dc:	7e 59                	jle    137 <wc+0x9b>
  de:	31 db                	xor    %ebx,%ebx
  e0:	eb 20                	jmp    102 <wc+0x66>
  e2:	66 90                	xchg   %ax,%ax
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  e4:	0f be c0             	movsbl %al,%eax
  e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  eb:	c7 04 24 12 07 00 00 	movl   $0x712,(%esp)
  f2:	e8 31 01 00 00       	call   228 <strchr>
  f7:	85 c0                	test   %eax,%eax
  f9:	74 19                	je     114 <wc+0x78>
        inword = 0;
  fb:	31 f6                	xor    %esi,%esi
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
  fd:	43                   	inc    %ebx
  fe:	39 fb                	cmp    %edi,%ebx
 100:	74 22                	je     124 <wc+0x88>
      c++;
      if(buf[i] == '\n')
 102:	8a 83 60 0a 00 00    	mov    0xa60(%ebx),%al
 108:	3c 0a                	cmp    $0xa,%al
 10a:	75 d8                	jne    e4 <wc+0x48>
        l++;
 10c:	ff 45 e4             	incl   -0x1c(%ebp)
 10f:	eb d3                	jmp    e4 <wc+0x48>
 111:	8d 76 00             	lea    0x0(%esi),%esi
      if(strchr(" \r\t\n\v", buf[i]))
        inword = 0;
      else if(!inword){
 114:	85 f6                	test   %esi,%esi
 116:	75 18                	jne    130 <wc+0x94>
        w++;
 118:	ff 45 e0             	incl   -0x20(%ebp)
        inword = 1;
 11b:	66 be 01 00          	mov    $0x1,%si
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
 11f:	43                   	inc    %ebx
 120:	39 fb                	cmp    %edi,%ebx
 122:	75 de                	jne    102 <wc+0x66>
#include "user.h"

char buf[512];

void
wc(int fd, char *name)
 124:	8b 45 dc             	mov    -0x24(%ebp),%eax
 127:	01 d8                	add    %ebx,%eax
 129:	89 45 dc             	mov    %eax,-0x24(%ebp)
 12c:	eb 8e                	jmp    bc <wc+0x20>
 12e:	66 90                	xchg   %ax,%ax
      c++;
      if(buf[i] == '\n')
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
        inword = 0;
      else if(!inword){
 130:	be 01 00 00 00       	mov    $0x1,%esi
 135:	eb c6                	jmp    fd <wc+0x61>
        w++;
        inword = 1;
      }
    }
  }
  if(n < 0){
 137:	75 38                	jne    171 <wc+0xd5>
    printf(1, "wc: read error\n");
    exit();
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
 139:	8b 45 0c             	mov    0xc(%ebp),%eax
 13c:	89 44 24 14          	mov    %eax,0x14(%esp)
 140:	8b 45 dc             	mov    -0x24(%ebp),%eax
 143:	89 44 24 10          	mov    %eax,0x10(%esp)
 147:	8b 45 e0             	mov    -0x20(%ebp),%eax
 14a:	89 44 24 0c          	mov    %eax,0xc(%esp)
 14e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 151:	89 44 24 08          	mov    %eax,0x8(%esp)
 155:	c7 44 24 04 28 07 00 	movl   $0x728,0x4(%esp)
 15c:	00 
 15d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 164:	e8 17 03 00 00       	call   480 <printf>
}
 169:	83 c4 3c             	add    $0x3c,%esp
 16c:	5b                   	pop    %ebx
 16d:	5e                   	pop    %esi
 16e:	5f                   	pop    %edi
 16f:	5d                   	pop    %ebp
 170:	c3                   	ret    
        inword = 1;
      }
    }
  }
  if(n < 0){
    printf(1, "wc: read error\n");
 171:	c7 44 24 04 18 07 00 	movl   $0x718,0x4(%esp)
 178:	00 
 179:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 180:	e8 fb 02 00 00       	call   480 <printf>
    exit();
 185:	e8 c6 01 00 00       	call   350 <exit>
 18a:	90                   	nop
 18b:	90                   	nop

0000018c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 18c:	55                   	push   %ebp
 18d:	89 e5                	mov    %esp,%ebp
 18f:	53                   	push   %ebx
 190:	8b 45 08             	mov    0x8(%ebp),%eax
 193:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 196:	31 d2                	xor    %edx,%edx
 198:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
 19b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 19e:	42                   	inc    %edx
 19f:	84 c9                	test   %cl,%cl
 1a1:	75 f5                	jne    198 <strcpy+0xc>
    ;
  return os;
}
 1a3:	5b                   	pop    %ebx
 1a4:	5d                   	pop    %ebp
 1a5:	c3                   	ret    
 1a6:	66 90                	xchg   %ax,%ax

000001a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a8:	55                   	push   %ebp
 1a9:	89 e5                	mov    %esp,%ebp
 1ab:	56                   	push   %esi
 1ac:	53                   	push   %ebx
 1ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 1b3:	8a 01                	mov    (%ecx),%al
 1b5:	8a 1a                	mov    (%edx),%bl
 1b7:	84 c0                	test   %al,%al
 1b9:	74 1d                	je     1d8 <strcmp+0x30>
 1bb:	38 d8                	cmp    %bl,%al
 1bd:	74 0c                	je     1cb <strcmp+0x23>
 1bf:	eb 23                	jmp    1e4 <strcmp+0x3c>
 1c1:	8d 76 00             	lea    0x0(%esi),%esi
 1c4:	41                   	inc    %ecx
 1c5:	38 d8                	cmp    %bl,%al
 1c7:	75 1b                	jne    1e4 <strcmp+0x3c>
    p++, q++;
 1c9:	89 f2                	mov    %esi,%edx
 1cb:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1ce:	8a 41 01             	mov    0x1(%ecx),%al
 1d1:	8a 5a 01             	mov    0x1(%edx),%bl
 1d4:	84 c0                	test   %al,%al
 1d6:	75 ec                	jne    1c4 <strcmp+0x1c>
 1d8:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1da:	0f b6 db             	movzbl %bl,%ebx
 1dd:	29 d8                	sub    %ebx,%eax
}
 1df:	5b                   	pop    %ebx
 1e0:	5e                   	pop    %esi
 1e1:	5d                   	pop    %ebp
 1e2:	c3                   	ret    
 1e3:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1e4:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1e7:	0f b6 db             	movzbl %bl,%ebx
 1ea:	29 d8                	sub    %ebx,%eax
}
 1ec:	5b                   	pop    %ebx
 1ed:	5e                   	pop    %esi
 1ee:	5d                   	pop    %ebp
 1ef:	c3                   	ret    

000001f0 <strlen>:

uint
strlen(const char *s)
{
 1f0:	55                   	push   %ebp
 1f1:	89 e5                	mov    %esp,%ebp
 1f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 1f6:	80 39 00             	cmpb   $0x0,(%ecx)
 1f9:	74 10                	je     20b <strlen+0x1b>
 1fb:	31 d2                	xor    %edx,%edx
 1fd:	8d 76 00             	lea    0x0(%esi),%esi
 200:	42                   	inc    %edx
 201:	89 d0                	mov    %edx,%eax
 203:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 207:	75 f7                	jne    200 <strlen+0x10>
    ;
  return n;
}
 209:	5d                   	pop    %ebp
 20a:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
 20b:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
 20d:	5d                   	pop    %ebp
 20e:	c3                   	ret    
 20f:	90                   	nop

00000210 <memset>:

void*
memset(void *dst, int c, uint n)
{
 210:	55                   	push   %ebp
 211:	89 e5                	mov    %esp,%ebp
 213:	57                   	push   %edi
 214:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 217:	89 d7                	mov    %edx,%edi
 219:	8b 4d 10             	mov    0x10(%ebp),%ecx
 21c:	8b 45 0c             	mov    0xc(%ebp),%eax
 21f:	fc                   	cld    
 220:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 222:	89 d0                	mov    %edx,%eax
 224:	5f                   	pop    %edi
 225:	5d                   	pop    %ebp
 226:	c3                   	ret    
 227:	90                   	nop

00000228 <strchr>:

char*
strchr(const char *s, char c)
{
 228:	55                   	push   %ebp
 229:	89 e5                	mov    %esp,%ebp
 22b:	8b 45 08             	mov    0x8(%ebp),%eax
 22e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 231:	8a 10                	mov    (%eax),%dl
 233:	84 d2                	test   %dl,%dl
 235:	75 0d                	jne    244 <strchr+0x1c>
 237:	eb 13                	jmp    24c <strchr+0x24>
 239:	8d 76 00             	lea    0x0(%esi),%esi
 23c:	8a 50 01             	mov    0x1(%eax),%dl
 23f:	84 d2                	test   %dl,%dl
 241:	74 09                	je     24c <strchr+0x24>
 243:	40                   	inc    %eax
    if(*s == c)
 244:	38 ca                	cmp    %cl,%dl
 246:	75 f4                	jne    23c <strchr+0x14>
      return (char*)s;
  return 0;
}
 248:	5d                   	pop    %ebp
 249:	c3                   	ret    
 24a:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 24c:	31 c0                	xor    %eax,%eax
}
 24e:	5d                   	pop    %ebp
 24f:	c3                   	ret    

00000250 <gets>:

char*
gets(char *buf, int max)
{
 250:	55                   	push   %ebp
 251:	89 e5                	mov    %esp,%ebp
 253:	57                   	push   %edi
 254:	56                   	push   %esi
 255:	53                   	push   %ebx
 256:	83 ec 2c             	sub    $0x2c,%esp
 259:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 25c:	31 f6                	xor    %esi,%esi
 25e:	eb 30                	jmp    290 <gets+0x40>
    cc = read(0, &c, 1);
 260:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 267:	00 
 268:	8d 45 e7             	lea    -0x19(%ebp),%eax
 26b:	89 44 24 04          	mov    %eax,0x4(%esp)
 26f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 276:	e8 ed 00 00 00       	call   368 <read>
    if(cc < 1)
 27b:	85 c0                	test   %eax,%eax
 27d:	7e 19                	jle    298 <gets+0x48>
      break;
    buf[i++] = c;
 27f:	8a 45 e7             	mov    -0x19(%ebp),%al
 282:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 286:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 288:	3c 0a                	cmp    $0xa,%al
 28a:	74 0c                	je     298 <gets+0x48>
 28c:	3c 0d                	cmp    $0xd,%al
 28e:	74 08                	je     298 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 290:	8d 5e 01             	lea    0x1(%esi),%ebx
 293:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 296:	7c c8                	jl     260 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 298:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 29c:	89 f8                	mov    %edi,%eax
 29e:	83 c4 2c             	add    $0x2c,%esp
 2a1:	5b                   	pop    %ebx
 2a2:	5e                   	pop    %esi
 2a3:	5f                   	pop    %edi
 2a4:	5d                   	pop    %ebp
 2a5:	c3                   	ret    
 2a6:	66 90                	xchg   %ax,%ax

000002a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a8:	55                   	push   %ebp
 2a9:	89 e5                	mov    %esp,%ebp
 2ab:	56                   	push   %esi
 2ac:	53                   	push   %ebx
 2ad:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2b7:	00 
 2b8:	8b 45 08             	mov    0x8(%ebp),%eax
 2bb:	89 04 24             	mov    %eax,(%esp)
 2be:	e8 cd 00 00 00       	call   390 <open>
 2c3:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 2c5:	85 c0                	test   %eax,%eax
 2c7:	78 23                	js     2ec <stat+0x44>
    return -1;
  r = fstat(fd, st);
 2c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cc:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d0:	89 1c 24             	mov    %ebx,(%esp)
 2d3:	e8 d0 00 00 00       	call   3a8 <fstat>
 2d8:	89 c6                	mov    %eax,%esi
  close(fd);
 2da:	89 1c 24             	mov    %ebx,(%esp)
 2dd:	e8 96 00 00 00       	call   378 <close>
  return r;
}
 2e2:	89 f0                	mov    %esi,%eax
 2e4:	83 c4 10             	add    $0x10,%esp
 2e7:	5b                   	pop    %ebx
 2e8:	5e                   	pop    %esi
 2e9:	5d                   	pop    %ebp
 2ea:	c3                   	ret    
 2eb:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 2ec:	be ff ff ff ff       	mov    $0xffffffff,%esi
 2f1:	eb ef                	jmp    2e2 <stat+0x3a>
 2f3:	90                   	nop

000002f4 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 2f4:	55                   	push   %ebp
 2f5:	89 e5                	mov    %esp,%ebp
 2f7:	53                   	push   %ebx
 2f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2fb:	8a 11                	mov    (%ecx),%dl
 2fd:	8d 42 d0             	lea    -0x30(%edx),%eax
 300:	3c 09                	cmp    $0x9,%al
 302:	b8 00 00 00 00       	mov    $0x0,%eax
 307:	77 18                	ja     321 <atoi+0x2d>
 309:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 30c:	8d 04 80             	lea    (%eax,%eax,4),%eax
 30f:	0f be d2             	movsbl %dl,%edx
 312:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 316:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 317:	8a 11                	mov    (%ecx),%dl
 319:	8d 5a d0             	lea    -0x30(%edx),%ebx
 31c:	80 fb 09             	cmp    $0x9,%bl
 31f:	76 eb                	jbe    30c <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 321:	5b                   	pop    %ebx
 322:	5d                   	pop    %ebp
 323:	c3                   	ret    

00000324 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 324:	55                   	push   %ebp
 325:	89 e5                	mov    %esp,%ebp
 327:	56                   	push   %esi
 328:	53                   	push   %ebx
 329:	8b 45 08             	mov    0x8(%ebp),%eax
 32c:	8b 75 0c             	mov    0xc(%ebp),%esi
 32f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 332:	85 db                	test   %ebx,%ebx
 334:	7e 0d                	jle    343 <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 336:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 338:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 33b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 33e:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 33f:	39 da                	cmp    %ebx,%edx
 341:	75 f5                	jne    338 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 343:	5b                   	pop    %ebx
 344:	5e                   	pop    %esi
 345:	5d                   	pop    %ebp
 346:	c3                   	ret    
 347:	90                   	nop

00000348 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 348:	b8 01 00 00 00       	mov    $0x1,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <exit>:
SYSCALL(exit)
 350:	b8 02 00 00 00       	mov    $0x2,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <wait>:
SYSCALL(wait)
 358:	b8 03 00 00 00       	mov    $0x3,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <pipe>:
SYSCALL(pipe)
 360:	b8 04 00 00 00       	mov    $0x4,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <read>:
SYSCALL(read)
 368:	b8 05 00 00 00       	mov    $0x5,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <write>:
SYSCALL(write)
 370:	b8 10 00 00 00       	mov    $0x10,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <close>:
SYSCALL(close)
 378:	b8 15 00 00 00       	mov    $0x15,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <kill>:
SYSCALL(kill)
 380:	b8 06 00 00 00       	mov    $0x6,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <exec>:
SYSCALL(exec)
 388:	b8 07 00 00 00       	mov    $0x7,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <open>:
SYSCALL(open)
 390:	b8 0f 00 00 00       	mov    $0xf,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <mknod>:
SYSCALL(mknod)
 398:	b8 11 00 00 00       	mov    $0x11,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <unlink>:
SYSCALL(unlink)
 3a0:	b8 12 00 00 00       	mov    $0x12,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <fstat>:
SYSCALL(fstat)
 3a8:	b8 08 00 00 00       	mov    $0x8,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <link>:
SYSCALL(link)
 3b0:	b8 13 00 00 00       	mov    $0x13,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <mkdir>:
SYSCALL(mkdir)
 3b8:	b8 14 00 00 00       	mov    $0x14,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <chdir>:
SYSCALL(chdir)
 3c0:	b8 09 00 00 00       	mov    $0x9,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <dup>:
SYSCALL(dup)
 3c8:	b8 0a 00 00 00       	mov    $0xa,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <getpid>:
SYSCALL(getpid)
 3d0:	b8 0b 00 00 00       	mov    $0xb,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <sbrk>:
SYSCALL(sbrk)
 3d8:	b8 0c 00 00 00       	mov    $0xc,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <sleep>:
SYSCALL(sleep)
 3e0:	b8 0d 00 00 00       	mov    $0xd,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <uptime>:
SYSCALL(uptime)
 3e8:	b8 0e 00 00 00       	mov    $0xe,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	83 ec 28             	sub    $0x28,%esp
 3f6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 3f9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 400:	00 
 401:	8d 55 f4             	lea    -0xc(%ebp),%edx
 404:	89 54 24 04          	mov    %edx,0x4(%esp)
 408:	89 04 24             	mov    %eax,(%esp)
 40b:	e8 60 ff ff ff       	call   370 <write>
}
 410:	c9                   	leave  
 411:	c3                   	ret    
 412:	66 90                	xchg   %ax,%ax

00000414 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 414:	55                   	push   %ebp
 415:	89 e5                	mov    %esp,%ebp
 417:	57                   	push   %edi
 418:	56                   	push   %esi
 419:	53                   	push   %ebx
 41a:	83 ec 1c             	sub    $0x1c,%esp
 41d:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 41f:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 421:	8b 5d 08             	mov    0x8(%ebp),%ebx
 424:	85 db                	test   %ebx,%ebx
 426:	74 04                	je     42c <printint+0x18>
 428:	85 d2                	test   %edx,%edx
 42a:	78 4a                	js     476 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 42c:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 42e:	31 db                	xor    %ebx,%ebx
 430:	eb 04                	jmp    436 <printint+0x22>
 432:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 434:	89 d3                	mov    %edx,%ebx
 436:	31 d2                	xor    %edx,%edx
 438:	f7 f1                	div    %ecx
 43a:	8a 92 50 07 00 00    	mov    0x750(%edx),%dl
 440:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 444:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 447:	85 c0                	test   %eax,%eax
 449:	75 e9                	jne    434 <printint+0x20>
  if(neg)
 44b:	85 ff                	test   %edi,%edi
 44d:	74 08                	je     457 <printint+0x43>
    buf[i++] = '-';
 44f:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 454:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 457:	8d 5a ff             	lea    -0x1(%edx),%ebx
 45a:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 45c:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 461:	89 f0                	mov    %esi,%eax
 463:	e8 88 ff ff ff       	call   3f0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 468:	4b                   	dec    %ebx
 469:	83 fb ff             	cmp    $0xffffffff,%ebx
 46c:	75 ee                	jne    45c <printint+0x48>
    putc(fd, buf[i]);
}
 46e:	83 c4 1c             	add    $0x1c,%esp
 471:	5b                   	pop    %ebx
 472:	5e                   	pop    %esi
 473:	5f                   	pop    %edi
 474:	5d                   	pop    %ebp
 475:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 476:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 478:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 47d:	eb af                	jmp    42e <printint+0x1a>
 47f:	90                   	nop

00000480 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 480:	55                   	push   %ebp
 481:	89 e5                	mov    %esp,%ebp
 483:	57                   	push   %edi
 484:	56                   	push   %esi
 485:	53                   	push   %ebx
 486:	83 ec 2c             	sub    $0x2c,%esp
 489:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 48c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 48f:	8a 0b                	mov    (%ebx),%cl
 491:	84 c9                	test   %cl,%cl
 493:	74 7b                	je     510 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 495:	8d 45 10             	lea    0x10(%ebp),%eax
 498:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 49b:	31 f6                	xor    %esi,%esi
 49d:	eb 17                	jmp    4b6 <printf+0x36>
 49f:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 4a0:	83 f9 25             	cmp    $0x25,%ecx
 4a3:	74 73                	je     518 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 4a5:	0f be d1             	movsbl %cl,%edx
 4a8:	89 f8                	mov    %edi,%eax
 4aa:	e8 41 ff ff ff       	call   3f0 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 4af:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4b0:	8a 0b                	mov    (%ebx),%cl
 4b2:	84 c9                	test   %cl,%cl
 4b4:	74 5a                	je     510 <printf+0x90>
    c = fmt[i] & 0xff;
 4b6:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 4b9:	85 f6                	test   %esi,%esi
 4bb:	74 e3                	je     4a0 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4bd:	83 fe 25             	cmp    $0x25,%esi
 4c0:	75 ed                	jne    4af <printf+0x2f>
      if(c == 'd'){
 4c2:	83 f9 64             	cmp    $0x64,%ecx
 4c5:	0f 84 c1 00 00 00    	je     58c <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 4cb:	83 f9 78             	cmp    $0x78,%ecx
 4ce:	74 50                	je     520 <printf+0xa0>
 4d0:	83 f9 70             	cmp    $0x70,%ecx
 4d3:	74 4b                	je     520 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 4d5:	83 f9 73             	cmp    $0x73,%ecx
 4d8:	74 6a                	je     544 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4da:	83 f9 63             	cmp    $0x63,%ecx
 4dd:	0f 84 91 00 00 00    	je     574 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 4e3:	ba 25 00 00 00       	mov    $0x25,%edx
 4e8:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 4ea:	83 f9 25             	cmp    $0x25,%ecx
 4ed:	74 10                	je     4ff <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4ef:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 4f2:	e8 f9 fe ff ff       	call   3f0 <putc>
        putc(fd, c);
 4f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 4fa:	0f be d1             	movsbl %cl,%edx
 4fd:	89 f8                	mov    %edi,%eax
 4ff:	e8 ec fe ff ff       	call   3f0 <putc>
      }
      state = 0;
 504:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 506:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 507:	8a 0b                	mov    (%ebx),%cl
 509:	84 c9                	test   %cl,%cl
 50b:	75 a9                	jne    4b6 <printf+0x36>
 50d:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 510:	83 c4 2c             	add    $0x2c,%esp
 513:	5b                   	pop    %ebx
 514:	5e                   	pop    %esi
 515:	5f                   	pop    %edi
 516:	5d                   	pop    %ebp
 517:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 518:	be 25 00 00 00       	mov    $0x25,%esi
 51d:	eb 90                	jmp    4af <printf+0x2f>
 51f:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 520:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 527:	b9 10 00 00 00       	mov    $0x10,%ecx
 52c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 52f:	8b 10                	mov    (%eax),%edx
 531:	89 f8                	mov    %edi,%eax
 533:	e8 dc fe ff ff       	call   414 <printint>
        ap++;
 538:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 53c:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 53e:	e9 6c ff ff ff       	jmp    4af <printf+0x2f>
 543:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 544:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 547:	8b 30                	mov    (%eax),%esi
        ap++;
 549:	83 c0 04             	add    $0x4,%eax
 54c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 54f:	85 f6                	test   %esi,%esi
 551:	74 5a                	je     5ad <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 553:	8a 16                	mov    (%esi),%dl
 555:	84 d2                	test   %dl,%dl
 557:	74 14                	je     56d <printf+0xed>
 559:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 55c:	0f be d2             	movsbl %dl,%edx
 55f:	89 f8                	mov    %edi,%eax
 561:	e8 8a fe ff ff       	call   3f0 <putc>
          s++;
 566:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 567:	8a 16                	mov    (%esi),%dl
 569:	84 d2                	test   %dl,%dl
 56b:	75 ef                	jne    55c <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 56d:	31 f6                	xor    %esi,%esi
 56f:	e9 3b ff ff ff       	jmp    4af <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 574:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 577:	0f be 10             	movsbl (%eax),%edx
 57a:	89 f8                	mov    %edi,%eax
 57c:	e8 6f fe ff ff       	call   3f0 <putc>
        ap++;
 581:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 585:	31 f6                	xor    %esi,%esi
 587:	e9 23 ff ff ff       	jmp    4af <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 58c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 593:	b1 0a                	mov    $0xa,%cl
 595:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 598:	8b 10                	mov    (%eax),%edx
 59a:	89 f8                	mov    %edi,%eax
 59c:	e8 73 fe ff ff       	call   414 <printint>
        ap++;
 5a1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5a5:	66 31 f6             	xor    %si,%si
 5a8:	e9 02 ff ff ff       	jmp    4af <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 5ad:	be 49 07 00 00       	mov    $0x749,%esi
 5b2:	eb 9f                	jmp    553 <printf+0xd3>

000005b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5b4:	55                   	push   %ebp
 5b5:	89 e5                	mov    %esp,%ebp
 5b7:	57                   	push   %edi
 5b8:	56                   	push   %esi
 5b9:	53                   	push   %ebx
 5ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5bd:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5c0:	a1 40 0a 00 00       	mov    0xa40,%eax
 5c5:	8d 76 00             	lea    0x0(%esi),%esi
 5c8:	8b 10                	mov    (%eax),%edx
 5ca:	39 c8                	cmp    %ecx,%eax
 5cc:	73 04                	jae    5d2 <free+0x1e>
 5ce:	39 d1                	cmp    %edx,%ecx
 5d0:	72 12                	jb     5e4 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5d2:	39 d0                	cmp    %edx,%eax
 5d4:	72 08                	jb     5de <free+0x2a>
 5d6:	39 c8                	cmp    %ecx,%eax
 5d8:	72 0a                	jb     5e4 <free+0x30>
 5da:	39 d1                	cmp    %edx,%ecx
 5dc:	72 06                	jb     5e4 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 5de:	89 d0                	mov    %edx,%eax
 5e0:	eb e6                	jmp    5c8 <free+0x14>
 5e2:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 5e4:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5e7:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5ea:	39 d7                	cmp    %edx,%edi
 5ec:	74 19                	je     607 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5ee:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5f1:	8b 50 04             	mov    0x4(%eax),%edx
 5f4:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5f7:	39 f1                	cmp    %esi,%ecx
 5f9:	74 23                	je     61e <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5fb:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5fd:	a3 40 0a 00 00       	mov    %eax,0xa40
}
 602:	5b                   	pop    %ebx
 603:	5e                   	pop    %esi
 604:	5f                   	pop    %edi
 605:	5d                   	pop    %ebp
 606:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 607:	03 72 04             	add    0x4(%edx),%esi
 60a:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 60d:	8b 10                	mov    (%eax),%edx
 60f:	8b 12                	mov    (%edx),%edx
 611:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 614:	8b 50 04             	mov    0x4(%eax),%edx
 617:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 61a:	39 f1                	cmp    %esi,%ecx
 61c:	75 dd                	jne    5fb <free+0x47>
    p->s.size += bp->s.size;
 61e:	03 53 fc             	add    -0x4(%ebx),%edx
 621:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 624:	8b 53 f8             	mov    -0x8(%ebx),%edx
 627:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 629:	a3 40 0a 00 00       	mov    %eax,0xa40
}
 62e:	5b                   	pop    %ebx
 62f:	5e                   	pop    %esi
 630:	5f                   	pop    %edi
 631:	5d                   	pop    %ebp
 632:	c3                   	ret    
 633:	90                   	nop

00000634 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 634:	55                   	push   %ebp
 635:	89 e5                	mov    %esp,%ebp
 637:	57                   	push   %edi
 638:	56                   	push   %esi
 639:	53                   	push   %ebx
 63a:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 63d:	8b 5d 08             	mov    0x8(%ebp),%ebx
 640:	83 c3 07             	add    $0x7,%ebx
 643:	c1 eb 03             	shr    $0x3,%ebx
 646:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 647:	8b 0d 40 0a 00 00    	mov    0xa40,%ecx
 64d:	85 c9                	test   %ecx,%ecx
 64f:	0f 84 95 00 00 00    	je     6ea <malloc+0xb6>
 655:	8b 01                	mov    (%ecx),%eax
 657:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 65a:	39 da                	cmp    %ebx,%edx
 65c:	73 66                	jae    6c4 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 65e:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 665:	eb 0c                	jmp    673 <malloc+0x3f>
 667:	90                   	nop
    }
    if(p == freep)
 668:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 66a:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 66c:	8b 50 04             	mov    0x4(%eax),%edx
 66f:	39 d3                	cmp    %edx,%ebx
 671:	76 51                	jbe    6c4 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 673:	3b 05 40 0a 00 00    	cmp    0xa40,%eax
 679:	75 ed                	jne    668 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 67b:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 681:	76 35                	jbe    6b8 <malloc+0x84>
 683:	89 f8                	mov    %edi,%eax
 685:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 687:	89 04 24             	mov    %eax,(%esp)
 68a:	e8 49 fd ff ff       	call   3d8 <sbrk>
  if(p == (char*)-1)
 68f:	83 f8 ff             	cmp    $0xffffffff,%eax
 692:	74 18                	je     6ac <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 694:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 697:	83 c0 08             	add    $0x8,%eax
 69a:	89 04 24             	mov    %eax,(%esp)
 69d:	e8 12 ff ff ff       	call   5b4 <free>
  return freep;
 6a2:	8b 0d 40 0a 00 00    	mov    0xa40,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 6a8:	85 c9                	test   %ecx,%ecx
 6aa:	75 be                	jne    66a <malloc+0x36>
        return 0;
 6ac:	31 c0                	xor    %eax,%eax
  }
}
 6ae:	83 c4 1c             	add    $0x1c,%esp
 6b1:	5b                   	pop    %ebx
 6b2:	5e                   	pop    %esi
 6b3:	5f                   	pop    %edi
 6b4:	5d                   	pop    %ebp
 6b5:	c3                   	ret    
 6b6:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 6b8:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 6bd:	be 00 10 00 00       	mov    $0x1000,%esi
 6c2:	eb c3                	jmp    687 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 6c4:	39 d3                	cmp    %edx,%ebx
 6c6:	74 1c                	je     6e4 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 6c8:	29 da                	sub    %ebx,%edx
 6ca:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 6cd:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 6d0:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 6d3:	89 0d 40 0a 00 00    	mov    %ecx,0xa40
      return (void*)(p + 1);
 6d9:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6dc:	83 c4 1c             	add    $0x1c,%esp
 6df:	5b                   	pop    %ebx
 6e0:	5e                   	pop    %esi
 6e1:	5f                   	pop    %edi
 6e2:	5d                   	pop    %ebp
 6e3:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 6e4:	8b 10                	mov    (%eax),%edx
 6e6:	89 11                	mov    %edx,(%ecx)
 6e8:	eb e9                	jmp    6d3 <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 6ea:	c7 05 40 0a 00 00 44 	movl   $0xa44,0xa40
 6f1:	0a 00 00 
 6f4:	c7 05 44 0a 00 00 44 	movl   $0xa44,0xa44
 6fb:	0a 00 00 
    base.s.size = 0;
 6fe:	c7 05 48 0a 00 00 00 	movl   $0x0,0xa48
 705:	00 00 00 
 708:	b8 44 0a 00 00       	mov    $0xa44,%eax
 70d:	e9 4c ff ff ff       	jmp    65e <malloc+0x2a>
