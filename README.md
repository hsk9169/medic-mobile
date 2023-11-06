# 일지 모바일 앱

## 디자인 와이어프레임
- https://www.canva.com/design/DAFqH-BvZgY/mxZ9gW5vN38fTd73T25-GQ/edit
- https://www.figma.com/file/OEpCZkdfGpkTtsU6IR0tKH/UI%EB%94%94%EC%9E%90%EC%9D%B8(%EA%B3%B5%EC%9C%A0%EC%9A%A9)?type=design&node-id=80-6136&mode=design&t=6dBfvGiwS1fOKzij-0

## 이미지 색감 조절
### 기능
- 밝기 (Brightness)
- 선명도 or 채도 (Saturation)
- 색조 (Hue or Contrast)
### 필터
- 밝기 (b)
```
   R G B A W
R [1 0 0 0 0]
G [0 1 0 0 0]
B [0 0 1 0 0]
A [0 0 0 1 0]
W [b b b 0 1]
```
- 색조 (c)
```
   R G B A W
R [c 0 0 0 0]
G [0 c 0 0 0]
B [0 0 c 0 0]
A [0 0 0 1 0]
W [t t t 0 1]

t = (1.0 - c) / 2.0
```
- 선명도 (s)
```
   R G B A W
R [sr+s  sr   sr  0 0]
G [sg   sg+s  sg  0 0]
B [sb    sb  sb+s 0 0]
A [0     0    0   1 0]
W [0     0    0   0 1]

sr = (1 - s) * lumR
sg = (1 - s) * lumG
sb = (1 - s) * lumB
lumR = 0.3086  or  0.2125
lumG = 0.6094  or  0.7154
lumB = 0.0820  or  0.0721
```

## 참조
### Color Filter Matrix
- https://docs.rainmeter.net/tips/colormatrix-guide/
### Image Processing (Princeton)
- [image filter matrix.pdf](https://github.com/medic-basic/mobile_app/files/12617123/image.filter.matrix.pdf)
### DCCF github repo
- https://arxiv.org/abs/2207.04788
