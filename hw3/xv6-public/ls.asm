
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
  close(fd);
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
   9:	83 ec 10             	sub    $0x10,%esp
   c:	8b 75 08             	mov    0x8(%ebp),%esi
   f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  if(argc < 2){
  12:	83 fe 01             	cmp    $0x1,%esi
  15:	7e 1a                	jle    31 <main+0x31>
  17:	bb 01 00 00 00       	mov    $0x1,%ebx
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
  1c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  1f:	89 04 24             	mov    %eax,(%esp)
  22:	e8 b1 00 00 00       	call   d8 <ls>

  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
  27:	43                   	inc    %ebx
  28:	39 f3                	cmp    %esi,%ebx
  2a:	75 f0                	jne    1c <main+0x1c>
    ls(argv[i]);
  exit();
  2c:	e8 bf 04 00 00       	call   4f0 <exit>
main(int argc, char *argv[])
{
  int i;

  if(argc < 2){
    ls(".");
  31:	c7 04 24 02 09 00 00 	movl   $0x902,(%esp)
  38:	e8 9b 00 00 00       	call   d8 <ls>
    exit();
  3d:	e8 ae 04 00 00       	call   4f0 <exit>
  42:	90                   	nop
  43:	90                   	nop

00000044 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
  44:	55                   	push   %ebp
  45:	89 e5                	mov    %esp,%ebp
  47:	56                   	push   %esi
  48:	53                   	push   %ebx
  49:	83 ec 10             	sub    $0x10,%esp
  4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  4f:	89 1c 24             	mov    %ebx,(%esp)
  52:	e8 39 03 00 00       	call   390 <strlen>
  57:	01 d8                	add    %ebx,%eax
  59:	73 0a                	jae    65 <fmtname+0x21>
  5b:	eb 0d                	jmp    6a <fmtname+0x26>
  5d:	8d 76 00             	lea    0x0(%esi),%esi
  60:	48                   	dec    %eax
  61:	39 c3                	cmp    %eax,%ebx
  63:	77 05                	ja     6a <fmtname+0x26>
  65:	80 38 2f             	cmpb   $0x2f,(%eax)
  68:	75 f6                	jne    60 <fmtname+0x1c>
    ;
  p++;
  6a:	8d 58 01             	lea    0x1(%eax),%ebx

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  6d:	89 1c 24             	mov    %ebx,(%esp)
  70:	e8 1b 03 00 00       	call   390 <strlen>
  75:	83 f8 0d             	cmp    $0xd,%eax
  78:	77 53                	ja     cd <fmtname+0x89>
    return p;
  memmove(buf, p, strlen(p));
  7a:	89 1c 24             	mov    %ebx,(%esp)
  7d:	e8 0e 03 00 00       	call   390 <strlen>
  82:	89 44 24 08          	mov    %eax,0x8(%esp)
  86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8a:	c7 04 24 28 0c 00 00 	movl   $0xc28,(%esp)
  91:	e8 2e 04 00 00       	call   4c4 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  96:	89 1c 24             	mov    %ebx,(%esp)
  99:	e8 f2 02 00 00       	call   390 <strlen>
  9e:	89 c6                	mov    %eax,%esi
  a0:	89 1c 24             	mov    %ebx,(%esp)
  a3:	e8 e8 02 00 00       	call   390 <strlen>
  a8:	ba 0e 00 00 00       	mov    $0xe,%edx
  ad:	29 f2                	sub    %esi,%edx
  af:	89 54 24 08          	mov    %edx,0x8(%esp)
  b3:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  ba:	00 
  bb:	05 28 0c 00 00       	add    $0xc28,%eax
  c0:	89 04 24             	mov    %eax,(%esp)
  c3:	e8 e8 02 00 00       	call   3b0 <memset>
  return buf;
  c8:	bb 28 0c 00 00       	mov    $0xc28,%ebx
}
  cd:	89 d8                	mov    %ebx,%eax
  cf:	83 c4 10             	add    $0x10,%esp
  d2:	5b                   	pop    %ebx
  d3:	5e                   	pop    %esi
  d4:	5d                   	pop    %ebp
  d5:	c3                   	ret    
  d6:	66 90                	xchg   %ax,%ax

000000d8 <ls>:

void
ls(char *path)
{
  d8:	55                   	push   %ebp
  d9:	89 e5                	mov    %esp,%ebp
  db:	57                   	push   %edi
  dc:	56                   	push   %esi
  dd:	53                   	push   %ebx
  de:	81 ec 7c 02 00 00    	sub    $0x27c,%esp
  e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  ee:	00 
  ef:	89 3c 24             	mov    %edi,(%esp)
  f2:	e8 39 04 00 00       	call   530 <open>
  f7:	89 c3                	mov    %eax,%ebx
  f9:	85 c0                	test   %eax,%eax
  fb:	0f 88 bb 01 00 00    	js     2bc <ls+0x1e4>
    printf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
 101:	8d 75 c4             	lea    -0x3c(%ebp),%esi
 104:	89 74 24 04          	mov    %esi,0x4(%esp)
 108:	89 04 24             	mov    %eax,(%esp)
 10b:	e8 38 04 00 00       	call   548 <fstat>
 110:	85 c0                	test   %eax,%eax
 112:	0f 88 ec 01 00 00    	js     304 <ls+0x22c>
    printf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
 118:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 11b:	66 83 f8 01          	cmp    $0x1,%ax
 11f:	74 5f                	je     180 <ls+0xa8>
 121:	66 83 f8 02          	cmp    $0x2,%ax
 125:	74 15                	je     13c <ls+0x64>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 127:	89 1c 24             	mov    %ebx,(%esp)
 12a:	e8 e9 03 00 00       	call   518 <close>
}
 12f:	81 c4 7c 02 00 00    	add    $0x27c,%esp
 135:	5b                   	pop    %ebx
 136:	5e                   	pop    %esi
 137:	5f                   	pop    %edi
 138:	5d                   	pop    %ebp
 139:	c3                   	ret    
 13a:	66 90                	xchg   %ax,%ax
    return;
  }

  switch(st.type){
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 13c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 13f:	8b 75 cc             	mov    -0x34(%ebp),%esi
 142:	89 3c 24             	mov    %edi,(%esp)
 145:	89 95 a8 fd ff ff    	mov    %edx,-0x258(%ebp)
 14b:	e8 f4 fe ff ff       	call   44 <fmtname>
 150:	8b 95 a8 fd ff ff    	mov    -0x258(%ebp),%edx
 156:	89 54 24 14          	mov    %edx,0x14(%esp)
 15a:	89 74 24 10          	mov    %esi,0x10(%esp)
 15e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
 165:	00 
 166:	89 44 24 08          	mov    %eax,0x8(%esp)
 16a:	c7 44 24 04 e2 08 00 	movl   $0x8e2,0x4(%esp)
 171:	00 
 172:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 179:	e8 aa 04 00 00       	call   628 <printf>
    break;
 17e:	eb a7                	jmp    127 <ls+0x4f>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 180:	89 3c 24             	mov    %edi,(%esp)
 183:	e8 08 02 00 00       	call   390 <strlen>
 188:	83 c0 10             	add    $0x10,%eax
 18b:	3d 00 02 00 00       	cmp    $0x200,%eax
 190:	0f 87 0a 01 00 00    	ja     2a0 <ls+0x1c8>
      printf(1, "ls: path too long\n");
      break;
    }
    strcpy(buf, path);
 196:	89 7c 24 04          	mov    %edi,0x4(%esp)
 19a:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
 1a0:	89 04 24             	mov    %eax,(%esp)
 1a3:	e8 84 01 00 00       	call   32c <strcpy>
    p = buf+strlen(buf);
 1a8:	8d 95 c4 fd ff ff    	lea    -0x23c(%ebp),%edx
 1ae:	89 14 24             	mov    %edx,(%esp)
 1b1:	e8 da 01 00 00       	call   390 <strlen>
 1b6:	8d 8d c4 fd ff ff    	lea    -0x23c(%ebp),%ecx
 1bc:	01 c1                	add    %eax,%ecx
 1be:	89 8d b4 fd ff ff    	mov    %ecx,-0x24c(%ebp)
    *p++ = '/';
 1c4:	c6 01 2f             	movb   $0x2f,(%ecx)
 1c7:	41                   	inc    %ecx
 1c8:	89 8d ac fd ff ff    	mov    %ecx,-0x254(%ebp)
 1ce:	8d 7d d8             	lea    -0x28(%ebp),%edi
 1d1:	8d 76 00             	lea    0x0(%esi),%esi
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1d4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 1db:	00 
 1dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
 1e0:	89 1c 24             	mov    %ebx,(%esp)
 1e3:	e8 20 03 00 00       	call   508 <read>
 1e8:	83 f8 10             	cmp    $0x10,%eax
 1eb:	0f 85 36 ff ff ff    	jne    127 <ls+0x4f>
      if(de.inum == 0)
 1f1:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
 1f6:	74 dc                	je     1d4 <ls+0xfc>
        continue;
      memmove(p, de.name, DIRSIZ);
 1f8:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
 1ff:	00 
 200:	8d 45 da             	lea    -0x26(%ebp),%eax
 203:	89 44 24 04          	mov    %eax,0x4(%esp)
 207:	8b 95 ac fd ff ff    	mov    -0x254(%ebp),%edx
 20d:	89 14 24             	mov    %edx,(%esp)
 210:	e8 af 02 00 00       	call   4c4 <memmove>
      p[DIRSIZ] = 0;
 215:	8b 8d b4 fd ff ff    	mov    -0x24c(%ebp),%ecx
 21b:	c6 41 0f 00          	movb   $0x0,0xf(%ecx)
      if(stat(buf, &st) < 0){
 21f:	89 74 24 04          	mov    %esi,0x4(%esp)
 223:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
 229:	89 04 24             	mov    %eax,(%esp)
 22c:	e8 17 02 00 00       	call   448 <stat>
 231:	85 c0                	test   %eax,%eax
 233:	0f 88 a7 00 00 00    	js     2e0 <ls+0x208>
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 239:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
 23c:	8b 55 cc             	mov    -0x34(%ebp),%edx
 23f:	89 95 b0 fd ff ff    	mov    %edx,-0x250(%ebp)
 245:	0f bf 55 c4          	movswl -0x3c(%ebp),%edx
 249:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
 24f:	89 04 24             	mov    %eax,(%esp)
 252:	89 95 a8 fd ff ff    	mov    %edx,-0x258(%ebp)
 258:	89 8d a4 fd ff ff    	mov    %ecx,-0x25c(%ebp)
 25e:	e8 e1 fd ff ff       	call   44 <fmtname>
 263:	8b 8d a4 fd ff ff    	mov    -0x25c(%ebp),%ecx
 269:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 26d:	8b 8d b0 fd ff ff    	mov    -0x250(%ebp),%ecx
 273:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 277:	8b 95 a8 fd ff ff    	mov    -0x258(%ebp),%edx
 27d:	89 54 24 0c          	mov    %edx,0xc(%esp)
 281:	89 44 24 08          	mov    %eax,0x8(%esp)
 285:	c7 44 24 04 e2 08 00 	movl   $0x8e2,0x4(%esp)
 28c:	00 
 28d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 294:	e8 8f 03 00 00       	call   628 <printf>
 299:	e9 36 ff ff ff       	jmp    1d4 <ls+0xfc>
 29e:	66 90                	xchg   %ax,%ax
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
    break;

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
      printf(1, "ls: path too long\n");
 2a0:	c7 44 24 04 ef 08 00 	movl   $0x8ef,0x4(%esp)
 2a7:	00 
 2a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2af:	e8 74 03 00 00       	call   628 <printf>
      break;
 2b4:	e9 6e fe ff ff       	jmp    127 <ls+0x4f>
 2b9:	8d 76 00             	lea    0x0(%esi),%esi
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
    printf(2, "ls: cannot open %s\n", path);
 2bc:	89 7c 24 08          	mov    %edi,0x8(%esp)
 2c0:	c7 44 24 04 ba 08 00 	movl   $0x8ba,0x4(%esp)
 2c7:	00 
 2c8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 2cf:	e8 54 03 00 00       	call   628 <printf>
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
}
 2d4:	81 c4 7c 02 00 00    	add    $0x27c,%esp
 2da:	5b                   	pop    %ebx
 2db:	5e                   	pop    %esi
 2dc:	5f                   	pop    %edi
 2dd:	5d                   	pop    %ebp
 2de:	c3                   	ret    
 2df:	90                   	nop
      if(de.inum == 0)
        continue;
      memmove(p, de.name, DIRSIZ);
      p[DIRSIZ] = 0;
      if(stat(buf, &st) < 0){
        printf(1, "ls: cannot stat %s\n", buf);
 2e0:	8d 95 c4 fd ff ff    	lea    -0x23c(%ebp),%edx
 2e6:	89 54 24 08          	mov    %edx,0x8(%esp)
 2ea:	c7 44 24 04 ce 08 00 	movl   $0x8ce,0x4(%esp)
 2f1:	00 
 2f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2f9:	e8 2a 03 00 00       	call   628 <printf>
        continue;
 2fe:	e9 d1 fe ff ff       	jmp    1d4 <ls+0xfc>
 303:	90                   	nop
    printf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
    printf(2, "ls: cannot stat %s\n", path);
 304:	89 7c 24 08          	mov    %edi,0x8(%esp)
 308:	c7 44 24 04 ce 08 00 	movl   $0x8ce,0x4(%esp)
 30f:	00 
 310:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 317:	e8 0c 03 00 00       	call   628 <printf>
    close(fd);
 31c:	89 1c 24             	mov    %ebx,(%esp)
 31f:	e8 f4 01 00 00       	call   518 <close>
    return;
 324:	e9 06 fe ff ff       	jmp    12f <ls+0x57>
 329:	90                   	nop
 32a:	90                   	nop
 32b:	90                   	nop

0000032c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 32c:	55                   	push   %ebp
 32d:	89 e5                	mov    %esp,%ebp
 32f:	53                   	push   %ebx
 330:	8b 45 08             	mov    0x8(%ebp),%eax
 333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 336:	31 d2                	xor    %edx,%edx
 338:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
 33b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 33e:	42                   	inc    %edx
 33f:	84 c9                	test   %cl,%cl
 341:	75 f5                	jne    338 <strcpy+0xc>
    ;
  return os;
}
 343:	5b                   	pop    %ebx
 344:	5d                   	pop    %ebp
 345:	c3                   	ret    
 346:	66 90                	xchg   %ax,%ax

00000348 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 348:	55                   	push   %ebp
 349:	89 e5                	mov    %esp,%ebp
 34b:	56                   	push   %esi
 34c:	53                   	push   %ebx
 34d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 350:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 353:	8a 01                	mov    (%ecx),%al
 355:	8a 1a                	mov    (%edx),%bl
 357:	84 c0                	test   %al,%al
 359:	74 1d                	je     378 <strcmp+0x30>
 35b:	38 d8                	cmp    %bl,%al
 35d:	74 0c                	je     36b <strcmp+0x23>
 35f:	eb 23                	jmp    384 <strcmp+0x3c>
 361:	8d 76 00             	lea    0x0(%esi),%esi
 364:	41                   	inc    %ecx
 365:	38 d8                	cmp    %bl,%al
 367:	75 1b                	jne    384 <strcmp+0x3c>
    p++, q++;
 369:	89 f2                	mov    %esi,%edx
 36b:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 36e:	8a 41 01             	mov    0x1(%ecx),%al
 371:	8a 5a 01             	mov    0x1(%edx),%bl
 374:	84 c0                	test   %al,%al
 376:	75 ec                	jne    364 <strcmp+0x1c>
 378:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 37a:	0f b6 db             	movzbl %bl,%ebx
 37d:	29 d8                	sub    %ebx,%eax
}
 37f:	5b                   	pop    %ebx
 380:	5e                   	pop    %esi
 381:	5d                   	pop    %ebp
 382:	c3                   	ret    
 383:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 384:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 387:	0f b6 db             	movzbl %bl,%ebx
 38a:	29 d8                	sub    %ebx,%eax
}
 38c:	5b                   	pop    %ebx
 38d:	5e                   	pop    %esi
 38e:	5d                   	pop    %ebp
 38f:	c3                   	ret    

00000390 <strlen>:

uint
strlen(const char *s)
{
 390:	55                   	push   %ebp
 391:	89 e5                	mov    %esp,%ebp
 393:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 396:	80 39 00             	cmpb   $0x0,(%ecx)
 399:	74 10                	je     3ab <strlen+0x1b>
 39b:	31 d2                	xor    %edx,%edx
 39d:	8d 76 00             	lea    0x0(%esi),%esi
 3a0:	42                   	inc    %edx
 3a1:	89 d0                	mov    %edx,%eax
 3a3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 3a7:	75 f7                	jne    3a0 <strlen+0x10>
    ;
  return n;
}
 3a9:	5d                   	pop    %ebp
 3aa:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
 3ab:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
 3ad:	5d                   	pop    %ebp
 3ae:	c3                   	ret    
 3af:	90                   	nop

000003b0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3b0:	55                   	push   %ebp
 3b1:	89 e5                	mov    %esp,%ebp
 3b3:	57                   	push   %edi
 3b4:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 3b7:	89 d7                	mov    %edx,%edi
 3b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3bf:	fc                   	cld    
 3c0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 3c2:	89 d0                	mov    %edx,%eax
 3c4:	5f                   	pop    %edi
 3c5:	5d                   	pop    %ebp
 3c6:	c3                   	ret    
 3c7:	90                   	nop

000003c8 <strchr>:

char*
strchr(const char *s, char c)
{
 3c8:	55                   	push   %ebp
 3c9:	89 e5                	mov    %esp,%ebp
 3cb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ce:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 3d1:	8a 10                	mov    (%eax),%dl
 3d3:	84 d2                	test   %dl,%dl
 3d5:	75 0d                	jne    3e4 <strchr+0x1c>
 3d7:	eb 13                	jmp    3ec <strchr+0x24>
 3d9:	8d 76 00             	lea    0x0(%esi),%esi
 3dc:	8a 50 01             	mov    0x1(%eax),%dl
 3df:	84 d2                	test   %dl,%dl
 3e1:	74 09                	je     3ec <strchr+0x24>
 3e3:	40                   	inc    %eax
    if(*s == c)
 3e4:	38 ca                	cmp    %cl,%dl
 3e6:	75 f4                	jne    3dc <strchr+0x14>
      return (char*)s;
  return 0;
}
 3e8:	5d                   	pop    %ebp
 3e9:	c3                   	ret    
 3ea:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 3ec:	31 c0                	xor    %eax,%eax
}
 3ee:	5d                   	pop    %ebp
 3ef:	c3                   	ret    

000003f0 <gets>:

char*
gets(char *buf, int max)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	57                   	push   %edi
 3f4:	56                   	push   %esi
 3f5:	53                   	push   %ebx
 3f6:	83 ec 2c             	sub    $0x2c,%esp
 3f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3fc:	31 f6                	xor    %esi,%esi
 3fe:	eb 30                	jmp    430 <gets+0x40>
    cc = read(0, &c, 1);
 400:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 407:	00 
 408:	8d 45 e7             	lea    -0x19(%ebp),%eax
 40b:	89 44 24 04          	mov    %eax,0x4(%esp)
 40f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 416:	e8 ed 00 00 00       	call   508 <read>
    if(cc < 1)
 41b:	85 c0                	test   %eax,%eax
 41d:	7e 19                	jle    438 <gets+0x48>
      break;
    buf[i++] = c;
 41f:	8a 45 e7             	mov    -0x19(%ebp),%al
 422:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 426:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 428:	3c 0a                	cmp    $0xa,%al
 42a:	74 0c                	je     438 <gets+0x48>
 42c:	3c 0d                	cmp    $0xd,%al
 42e:	74 08                	je     438 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 430:	8d 5e 01             	lea    0x1(%esi),%ebx
 433:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 436:	7c c8                	jl     400 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 438:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 43c:	89 f8                	mov    %edi,%eax
 43e:	83 c4 2c             	add    $0x2c,%esp
 441:	5b                   	pop    %ebx
 442:	5e                   	pop    %esi
 443:	5f                   	pop    %edi
 444:	5d                   	pop    %ebp
 445:	c3                   	ret    
 446:	66 90                	xchg   %ax,%ax

00000448 <stat>:

int
stat(const char *n, struct stat *st)
{
 448:	55                   	push   %ebp
 449:	89 e5                	mov    %esp,%ebp
 44b:	56                   	push   %esi
 44c:	53                   	push   %ebx
 44d:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 450:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 457:	00 
 458:	8b 45 08             	mov    0x8(%ebp),%eax
 45b:	89 04 24             	mov    %eax,(%esp)
 45e:	e8 cd 00 00 00       	call   530 <open>
 463:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 465:	85 c0                	test   %eax,%eax
 467:	78 23                	js     48c <stat+0x44>
    return -1;
  r = fstat(fd, st);
 469:	8b 45 0c             	mov    0xc(%ebp),%eax
 46c:	89 44 24 04          	mov    %eax,0x4(%esp)
 470:	89 1c 24             	mov    %ebx,(%esp)
 473:	e8 d0 00 00 00       	call   548 <fstat>
 478:	89 c6                	mov    %eax,%esi
  close(fd);
 47a:	89 1c 24             	mov    %ebx,(%esp)
 47d:	e8 96 00 00 00       	call   518 <close>
  return r;
}
 482:	89 f0                	mov    %esi,%eax
 484:	83 c4 10             	add    $0x10,%esp
 487:	5b                   	pop    %ebx
 488:	5e                   	pop    %esi
 489:	5d                   	pop    %ebp
 48a:	c3                   	ret    
 48b:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 48c:	be ff ff ff ff       	mov    $0xffffffff,%esi
 491:	eb ef                	jmp    482 <stat+0x3a>
 493:	90                   	nop

00000494 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 494:	55                   	push   %ebp
 495:	89 e5                	mov    %esp,%ebp
 497:	53                   	push   %ebx
 498:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 49b:	8a 11                	mov    (%ecx),%dl
 49d:	8d 42 d0             	lea    -0x30(%edx),%eax
 4a0:	3c 09                	cmp    $0x9,%al
 4a2:	b8 00 00 00 00       	mov    $0x0,%eax
 4a7:	77 18                	ja     4c1 <atoi+0x2d>
 4a9:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 4ac:	8d 04 80             	lea    (%eax,%eax,4),%eax
 4af:	0f be d2             	movsbl %dl,%edx
 4b2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 4b6:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4b7:	8a 11                	mov    (%ecx),%dl
 4b9:	8d 5a d0             	lea    -0x30(%edx),%ebx
 4bc:	80 fb 09             	cmp    $0x9,%bl
 4bf:	76 eb                	jbe    4ac <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 4c1:	5b                   	pop    %ebx
 4c2:	5d                   	pop    %ebp
 4c3:	c3                   	ret    

000004c4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4c4:	55                   	push   %ebp
 4c5:	89 e5                	mov    %esp,%ebp
 4c7:	56                   	push   %esi
 4c8:	53                   	push   %ebx
 4c9:	8b 45 08             	mov    0x8(%ebp),%eax
 4cc:	8b 75 0c             	mov    0xc(%ebp),%esi
 4cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4d2:	85 db                	test   %ebx,%ebx
 4d4:	7e 0d                	jle    4e3 <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 4d6:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 4d8:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 4db:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 4de:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4df:	39 da                	cmp    %ebx,%edx
 4e1:	75 f5                	jne    4d8 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 4e3:	5b                   	pop    %ebx
 4e4:	5e                   	pop    %esi
 4e5:	5d                   	pop    %ebp
 4e6:	c3                   	ret    
 4e7:	90                   	nop

000004e8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4e8:	b8 01 00 00 00       	mov    $0x1,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <exit>:
SYSCALL(exit)
 4f0:	b8 02 00 00 00       	mov    $0x2,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <wait>:
SYSCALL(wait)
 4f8:	b8 03 00 00 00       	mov    $0x3,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <pipe>:
SYSCALL(pipe)
 500:	b8 04 00 00 00       	mov    $0x4,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <read>:
SYSCALL(read)
 508:	b8 05 00 00 00       	mov    $0x5,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <write>:
SYSCALL(write)
 510:	b8 10 00 00 00       	mov    $0x10,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <close>:
SYSCALL(close)
 518:	b8 15 00 00 00       	mov    $0x15,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <kill>:
SYSCALL(kill)
 520:	b8 06 00 00 00       	mov    $0x6,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <exec>:
SYSCALL(exec)
 528:	b8 07 00 00 00       	mov    $0x7,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <open>:
SYSCALL(open)
 530:	b8 0f 00 00 00       	mov    $0xf,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <mknod>:
SYSCALL(mknod)
 538:	b8 11 00 00 00       	mov    $0x11,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <unlink>:
SYSCALL(unlink)
 540:	b8 12 00 00 00       	mov    $0x12,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <fstat>:
SYSCALL(fstat)
 548:	b8 08 00 00 00       	mov    $0x8,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <link>:
SYSCALL(link)
 550:	b8 13 00 00 00       	mov    $0x13,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <mkdir>:
SYSCALL(mkdir)
 558:	b8 14 00 00 00       	mov    $0x14,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <chdir>:
SYSCALL(chdir)
 560:	b8 09 00 00 00       	mov    $0x9,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <dup>:
SYSCALL(dup)
 568:	b8 0a 00 00 00       	mov    $0xa,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <getpid>:
SYSCALL(getpid)
 570:	b8 0b 00 00 00       	mov    $0xb,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <sbrk>:
SYSCALL(sbrk)
 578:	b8 0c 00 00 00       	mov    $0xc,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <sleep>:
SYSCALL(sleep)
 580:	b8 0d 00 00 00       	mov    $0xd,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <uptime>:
SYSCALL(uptime)
 588:	b8 0e 00 00 00       	mov    $0xe,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <date>:
SYSCALL(date)
 590:	b8 16 00 00 00       	mov    $0x16,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 598:	55                   	push   %ebp
 599:	89 e5                	mov    %esp,%ebp
 59b:	83 ec 28             	sub    $0x28,%esp
 59e:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 5a1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5a8:	00 
 5a9:	8d 55 f4             	lea    -0xc(%ebp),%edx
 5ac:	89 54 24 04          	mov    %edx,0x4(%esp)
 5b0:	89 04 24             	mov    %eax,(%esp)
 5b3:	e8 58 ff ff ff       	call   510 <write>
}
 5b8:	c9                   	leave  
 5b9:	c3                   	ret    
 5ba:	66 90                	xchg   %ax,%ax

000005bc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5bc:	55                   	push   %ebp
 5bd:	89 e5                	mov    %esp,%ebp
 5bf:	57                   	push   %edi
 5c0:	56                   	push   %esi
 5c1:	53                   	push   %ebx
 5c2:	83 ec 1c             	sub    $0x1c,%esp
 5c5:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 5c7:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
 5cc:	85 db                	test   %ebx,%ebx
 5ce:	74 04                	je     5d4 <printint+0x18>
 5d0:	85 d2                	test   %edx,%edx
 5d2:	78 4a                	js     61e <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5d4:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5d6:	31 db                	xor    %ebx,%ebx
 5d8:	eb 04                	jmp    5de <printint+0x22>
 5da:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 5dc:	89 d3                	mov    %edx,%ebx
 5de:	31 d2                	xor    %edx,%edx
 5e0:	f7 f1                	div    %ecx
 5e2:	8a 92 0b 09 00 00    	mov    0x90b(%edx),%dl
 5e8:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 5ec:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 5ef:	85 c0                	test   %eax,%eax
 5f1:	75 e9                	jne    5dc <printint+0x20>
  if(neg)
 5f3:	85 ff                	test   %edi,%edi
 5f5:	74 08                	je     5ff <printint+0x43>
    buf[i++] = '-';
 5f7:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 5fc:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 5ff:	8d 5a ff             	lea    -0x1(%edx),%ebx
 602:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 604:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 609:	89 f0                	mov    %esi,%eax
 60b:	e8 88 ff ff ff       	call   598 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 610:	4b                   	dec    %ebx
 611:	83 fb ff             	cmp    $0xffffffff,%ebx
 614:	75 ee                	jne    604 <printint+0x48>
    putc(fd, buf[i]);
}
 616:	83 c4 1c             	add    $0x1c,%esp
 619:	5b                   	pop    %ebx
 61a:	5e                   	pop    %esi
 61b:	5f                   	pop    %edi
 61c:	5d                   	pop    %ebp
 61d:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 61e:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 620:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 625:	eb af                	jmp    5d6 <printint+0x1a>
 627:	90                   	nop

00000628 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 628:	55                   	push   %ebp
 629:	89 e5                	mov    %esp,%ebp
 62b:	57                   	push   %edi
 62c:	56                   	push   %esi
 62d:	53                   	push   %ebx
 62e:	83 ec 2c             	sub    $0x2c,%esp
 631:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 634:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 637:	8a 0b                	mov    (%ebx),%cl
 639:	84 c9                	test   %cl,%cl
 63b:	74 7b                	je     6b8 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 63d:	8d 45 10             	lea    0x10(%ebp),%eax
 640:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 643:	31 f6                	xor    %esi,%esi
 645:	eb 17                	jmp    65e <printf+0x36>
 647:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 648:	83 f9 25             	cmp    $0x25,%ecx
 64b:	74 73                	je     6c0 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 64d:	0f be d1             	movsbl %cl,%edx
 650:	89 f8                	mov    %edi,%eax
 652:	e8 41 ff ff ff       	call   598 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 657:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 658:	8a 0b                	mov    (%ebx),%cl
 65a:	84 c9                	test   %cl,%cl
 65c:	74 5a                	je     6b8 <printf+0x90>
    c = fmt[i] & 0xff;
 65e:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 661:	85 f6                	test   %esi,%esi
 663:	74 e3                	je     648 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 665:	83 fe 25             	cmp    $0x25,%esi
 668:	75 ed                	jne    657 <printf+0x2f>
      if(c == 'd'){
 66a:	83 f9 64             	cmp    $0x64,%ecx
 66d:	0f 84 c1 00 00 00    	je     734 <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 673:	83 f9 78             	cmp    $0x78,%ecx
 676:	74 50                	je     6c8 <printf+0xa0>
 678:	83 f9 70             	cmp    $0x70,%ecx
 67b:	74 4b                	je     6c8 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 67d:	83 f9 73             	cmp    $0x73,%ecx
 680:	74 6a                	je     6ec <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 682:	83 f9 63             	cmp    $0x63,%ecx
 685:	0f 84 91 00 00 00    	je     71c <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 68b:	ba 25 00 00 00       	mov    $0x25,%edx
 690:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 692:	83 f9 25             	cmp    $0x25,%ecx
 695:	74 10                	je     6a7 <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 697:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 69a:	e8 f9 fe ff ff       	call   598 <putc>
        putc(fd, c);
 69f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 6a2:	0f be d1             	movsbl %cl,%edx
 6a5:	89 f8                	mov    %edi,%eax
 6a7:	e8 ec fe ff ff       	call   598 <putc>
      }
      state = 0;
 6ac:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 6ae:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6af:	8a 0b                	mov    (%ebx),%cl
 6b1:	84 c9                	test   %cl,%cl
 6b3:	75 a9                	jne    65e <printf+0x36>
 6b5:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6b8:	83 c4 2c             	add    $0x2c,%esp
 6bb:	5b                   	pop    %ebx
 6bc:	5e                   	pop    %esi
 6bd:	5f                   	pop    %edi
 6be:	5d                   	pop    %ebp
 6bf:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 6c0:	be 25 00 00 00       	mov    $0x25,%esi
 6c5:	eb 90                	jmp    657 <printf+0x2f>
 6c7:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 6c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 6cf:	b9 10 00 00 00       	mov    $0x10,%ecx
 6d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6d7:	8b 10                	mov    (%eax),%edx
 6d9:	89 f8                	mov    %edi,%eax
 6db:	e8 dc fe ff ff       	call   5bc <printint>
        ap++;
 6e0:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6e4:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 6e6:	e9 6c ff ff ff       	jmp    657 <printf+0x2f>
 6eb:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 6ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ef:	8b 30                	mov    (%eax),%esi
        ap++;
 6f1:	83 c0 04             	add    $0x4,%eax
 6f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 6f7:	85 f6                	test   %esi,%esi
 6f9:	74 5a                	je     755 <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 6fb:	8a 16                	mov    (%esi),%dl
 6fd:	84 d2                	test   %dl,%dl
 6ff:	74 14                	je     715 <printf+0xed>
 701:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 704:	0f be d2             	movsbl %dl,%edx
 707:	89 f8                	mov    %edi,%eax
 709:	e8 8a fe ff ff       	call   598 <putc>
          s++;
 70e:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 70f:	8a 16                	mov    (%esi),%dl
 711:	84 d2                	test   %dl,%dl
 713:	75 ef                	jne    704 <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 715:	31 f6                	xor    %esi,%esi
 717:	e9 3b ff ff ff       	jmp    657 <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 71c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 71f:	0f be 10             	movsbl (%eax),%edx
 722:	89 f8                	mov    %edi,%eax
 724:	e8 6f fe ff ff       	call   598 <putc>
        ap++;
 729:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 72d:	31 f6                	xor    %esi,%esi
 72f:	e9 23 ff ff ff       	jmp    657 <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 734:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 73b:	b1 0a                	mov    $0xa,%cl
 73d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 740:	8b 10                	mov    (%eax),%edx
 742:	89 f8                	mov    %edi,%eax
 744:	e8 73 fe ff ff       	call   5bc <printint>
        ap++;
 749:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 74d:	66 31 f6             	xor    %si,%si
 750:	e9 02 ff ff ff       	jmp    657 <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 755:	be 04 09 00 00       	mov    $0x904,%esi
 75a:	eb 9f                	jmp    6fb <printf+0xd3>

0000075c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 75c:	55                   	push   %ebp
 75d:	89 e5                	mov    %esp,%ebp
 75f:	57                   	push   %edi
 760:	56                   	push   %esi
 761:	53                   	push   %ebx
 762:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 765:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 768:	a1 38 0c 00 00       	mov    0xc38,%eax
 76d:	8d 76 00             	lea    0x0(%esi),%esi
 770:	8b 10                	mov    (%eax),%edx
 772:	39 c8                	cmp    %ecx,%eax
 774:	73 04                	jae    77a <free+0x1e>
 776:	39 d1                	cmp    %edx,%ecx
 778:	72 12                	jb     78c <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77a:	39 d0                	cmp    %edx,%eax
 77c:	72 08                	jb     786 <free+0x2a>
 77e:	39 c8                	cmp    %ecx,%eax
 780:	72 0a                	jb     78c <free+0x30>
 782:	39 d1                	cmp    %edx,%ecx
 784:	72 06                	jb     78c <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 786:	89 d0                	mov    %edx,%eax
 788:	eb e6                	jmp    770 <free+0x14>
 78a:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 78c:	8b 73 fc             	mov    -0x4(%ebx),%esi
 78f:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 792:	39 d7                	cmp    %edx,%edi
 794:	74 19                	je     7af <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 796:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 799:	8b 50 04             	mov    0x4(%eax),%edx
 79c:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 79f:	39 f1                	cmp    %esi,%ecx
 7a1:	74 23                	je     7c6 <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 7a3:	89 08                	mov    %ecx,(%eax)
  freep = p;
 7a5:	a3 38 0c 00 00       	mov    %eax,0xc38
}
 7aa:	5b                   	pop    %ebx
 7ab:	5e                   	pop    %esi
 7ac:	5f                   	pop    %edi
 7ad:	5d                   	pop    %ebp
 7ae:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7af:	03 72 04             	add    0x4(%edx),%esi
 7b2:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b5:	8b 10                	mov    (%eax),%edx
 7b7:	8b 12                	mov    (%edx),%edx
 7b9:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7bc:	8b 50 04             	mov    0x4(%eax),%edx
 7bf:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 7c2:	39 f1                	cmp    %esi,%ecx
 7c4:	75 dd                	jne    7a3 <free+0x47>
    p->s.size += bp->s.size;
 7c6:	03 53 fc             	add    -0x4(%ebx),%edx
 7c9:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7cc:	8b 53 f8             	mov    -0x8(%ebx),%edx
 7cf:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 7d1:	a3 38 0c 00 00       	mov    %eax,0xc38
}
 7d6:	5b                   	pop    %ebx
 7d7:	5e                   	pop    %esi
 7d8:	5f                   	pop    %edi
 7d9:	5d                   	pop    %ebp
 7da:	c3                   	ret    
 7db:	90                   	nop

000007dc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7dc:	55                   	push   %ebp
 7dd:	89 e5                	mov    %esp,%ebp
 7df:	57                   	push   %edi
 7e0:	56                   	push   %esi
 7e1:	53                   	push   %ebx
 7e2:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
 7e8:	83 c3 07             	add    $0x7,%ebx
 7eb:	c1 eb 03             	shr    $0x3,%ebx
 7ee:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 7ef:	8b 0d 38 0c 00 00    	mov    0xc38,%ecx
 7f5:	85 c9                	test   %ecx,%ecx
 7f7:	0f 84 95 00 00 00    	je     892 <malloc+0xb6>
 7fd:	8b 01                	mov    (%ecx),%eax
 7ff:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 802:	39 da                	cmp    %ebx,%edx
 804:	73 66                	jae    86c <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 806:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 80d:	eb 0c                	jmp    81b <malloc+0x3f>
 80f:	90                   	nop
    }
    if(p == freep)
 810:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 812:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 814:	8b 50 04             	mov    0x4(%eax),%edx
 817:	39 d3                	cmp    %edx,%ebx
 819:	76 51                	jbe    86c <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 81b:	3b 05 38 0c 00 00    	cmp    0xc38,%eax
 821:	75 ed                	jne    810 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 823:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 829:	76 35                	jbe    860 <malloc+0x84>
 82b:	89 f8                	mov    %edi,%eax
 82d:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 82f:	89 04 24             	mov    %eax,(%esp)
 832:	e8 41 fd ff ff       	call   578 <sbrk>
  if(p == (char*)-1)
 837:	83 f8 ff             	cmp    $0xffffffff,%eax
 83a:	74 18                	je     854 <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 83c:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 83f:	83 c0 08             	add    $0x8,%eax
 842:	89 04 24             	mov    %eax,(%esp)
 845:	e8 12 ff ff ff       	call   75c <free>
  return freep;
 84a:	8b 0d 38 0c 00 00    	mov    0xc38,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 850:	85 c9                	test   %ecx,%ecx
 852:	75 be                	jne    812 <malloc+0x36>
        return 0;
 854:	31 c0                	xor    %eax,%eax
  }
}
 856:	83 c4 1c             	add    $0x1c,%esp
 859:	5b                   	pop    %ebx
 85a:	5e                   	pop    %esi
 85b:	5f                   	pop    %edi
 85c:	5d                   	pop    %ebp
 85d:	c3                   	ret    
 85e:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 860:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 865:	be 00 10 00 00       	mov    $0x1000,%esi
 86a:	eb c3                	jmp    82f <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 86c:	39 d3                	cmp    %edx,%ebx
 86e:	74 1c                	je     88c <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 870:	29 da                	sub    %ebx,%edx
 872:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 875:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 878:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 87b:	89 0d 38 0c 00 00    	mov    %ecx,0xc38
      return (void*)(p + 1);
 881:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 884:	83 c4 1c             	add    $0x1c,%esp
 887:	5b                   	pop    %ebx
 888:	5e                   	pop    %esi
 889:	5f                   	pop    %edi
 88a:	5d                   	pop    %ebp
 88b:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 88c:	8b 10                	mov    (%eax),%edx
 88e:	89 11                	mov    %edx,(%ecx)
 890:	eb e9                	jmp    87b <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 892:	c7 05 38 0c 00 00 3c 	movl   $0xc3c,0xc38
 899:	0c 00 00 
 89c:	c7 05 3c 0c 00 00 3c 	movl   $0xc3c,0xc3c
 8a3:	0c 00 00 
    base.s.size = 0;
 8a6:	c7 05 40 0c 00 00 00 	movl   $0x0,0xc40
 8ad:	00 00 00 
 8b0:	b8 3c 0c 00 00       	mov    $0xc3c,%eax
 8b5:	e9 4c ff ff ff       	jmp    806 <malloc+0x2a>
