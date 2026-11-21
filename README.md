# 📕 TypeGrapher

> **클래식 레드 수동 타자기와 한국식 정통 20×20 원고지 감성을 결합한 초경량 네이티브 macOS 마크다운 & 출판 스튜디오**  
> *A Distraction-Free, Tactile Markdown & Manuscript Studio for Mac OS X 10.7 Lion through the Latest macOS.*

![Platform](https://img.shields.io/badge/Platform-Mac%20OS%20X%2010.7%2B%20(x86__64)-crimson?style=flat-square&logo=apple)
![Architecture](https://img.shields.io/badge/Engine-Objective--C%20Cocoa%20%2B%20WebKit%20(ES5)-222222?style=flat-square)
![Dependencies](https://img.shields.io/badge/Dependencies-Zero%20(100%25%20Offline%20Native)-success?style=flat-square)
![Version](https://img.shields.io/badge/Version-2.6%20(Build%208)-d92b2b?style=flat-square)

---

## ✨ 프로젝트 소개 (Overview)

**TypeGrapher**는 무거운 웹 브라우저나 수백 MB의 메모리를 점유하는 일렉트론(Electron) 기반 노트 앱에서 벗어나, 오직 **글쓰기의 물리적 감각(Tactile Feedback)**과 **완벽한 원고 조판(Typesetting)**에만 집중하기 위해 설계된 macOS 네이티브 하이브리드 애플리케이션입니다.

2006~2009년형 폴리카보네이트 화이트 맥북(**MacBook A1181, Mac OS X 10.7 Lion / 10.8 Mountain Lion**)부터 최신 macOS까지 **단 하나의 외부 라이브러리나 인터넷 연결 없이 100% 오프라인으로 쾌적하게 구동**됩니다. 모든 노트는 사용자의 로컬 파인더 폴더(`~/Documents/TypeGrapher`)에 순수 마크다운(`.md`) 파일로 투명하게 저장됩니다.

---

## 🎹 5대 시그니처 기능 (Signature Features)

| 시그니처 기능 | 상세 설명 및 작동 원리 | 단축키 / 조작 |
| :--- | :--- | :--- |
| **1. 🔊 절차적 합성 타건음 & 황동 벨 엔진**<br>*(Procedural Audio Synthesizer)* | 외부 음원 파일(`.wav`/`.mp3`)을 일절 사용하지 않고, C언어 수학 함수(`sin`, `exp`)로 메모리 상에서 직접 합성한 **44.1kHz 16-bit PCM 파형 3종(45ms 활자 타격음, 55ms 스페이스바 타격음, 420ms 황동 캐리지 리턴 벨소리)**을 `NSSound` 다중 채널로 지연 시간 0초로 재생합니다. **타건음(`🔊`)과 엔터 벨소리(`🔔`)를 각각 독립적으로 On/Off** 할 수 있습니다. | 좌측 리본 `🔊` / `🔔` 버튼 |
| **2. 🎯 타자기 롤러 중앙 스크롤 & 타이핑 글로우**<br>*(Platen Scroll & Dynamic Glow)* | 실제 타자기처럼 현재 작성 중인 문단을 **화면 세로 45% 지점에 자동 고정**하고 나머지 문단을 어둡게 감광합니다. 글자를 타이핑하는 순간(`.typing-now`) **다크 테마에서는 5중 하얀 네온 광채**가, **라이트 테마에서는 따뜻한 스탠드 불빛과 붉은 잉크 번짐 효과**가 켰다가 1.1초 후 은은하게 잦아듭니다. | 좌측 리본 `🎯` 또는 툴바 `[🎯 집중]` |
| **3. 🎵 지금 흐르는 음악(BGM) 자동 스탬프**<br>*(Now Playing Stamp)* | `NSAppleScript` 브릿지를 통해 최신 맥의 **`Music.app`**과 구형 맥의 **`iTunes.app`**을 자동 분기 감지하여, 현재 재생 중인 곡 정보를 `> 🎵 Now Playing: **아티스트 — 곡 제목 (앨범)**` 형태로 일기에 즉시 각인합니다. | `Cmd + M` / 툴바 `[🎵 BGM]` |
| **4. 🟥 타자기 천공 카드 월간 집필 히트맵**<br>*(Punch-Card Writing Heatmap)* | 보관함 내 모든 `.md` 파일의 작성일과 글자 수를 분석하여 **전체 노트 수, 누적 글자 수, 이번 달 집필 일수, 연속 집필 스트릭(Streak)**을 계산하고, 글자 수에 비례하는 **5단계 크림슨 레드 농도의 달력 히트맵**을 그려냅니다. 날짜 칸을 클릭하면 해당 날짜의 일기로 즉시 이동합니다. | `Cmd + G` / 좌측 리본 `📊` |
| **5. 📜 4단계 종이 스타일 & 무후회 초고 모드**<br>*(4-Stage Paper & No-Backspace)* | **① 기본 모던 고딕** ➔ **② 타자기체(`Courier New`/`AppleMyungjo`)** ➔ **③ 원고지(줄, `36px` 정밀 줄맞춤)** ➔ **④ 20×20 원고지(칸, 400자 정통 원고지)**의 4가지 집필 모드를 실시간 전환하며, 수동 타자기처럼 지우기(`Backspace`/`Delete`) 키를 잠그는 **`[🔒 무후회]` 초고 모드**를 지원합니다. | 툴바 `[📜 스타일]` / `[🔒 무후회]` |

---

## 📐 정통 20×20 원고지(칸) 조판 엔진의 핵심 디테일

`TypeGrapher`의 **원고지(칸)** 모드는 단순한 배경 격자가 아니라 한국어 원고지 작성법을 완벽히 구현한 전용 조판 엔진입니다.

1. **한글 IME 조합 완벽 보존 (`#gridInput` + `#gridPaper` 분리 아키텍처):**
   * 실제 키보드 입력과 한글 자모 조합(`compositionstart` ~ `compositionend`), 실행 취소(`Undo`), 범위 선택은 보이지 않는 마스터 입력창이 전담하고, 화면에는 한 칸에 한 글자씩 실시간 투영하여 한글 자소 분리 현상을 원천 차단했습니다.
2. **한국어 원고지 반각·문장부호 조판 규칙 (`computeGridLayout`):**
   * **반각 2글자 자동 묶음 (`gridHalfKind`):** 연속되는 아라비아 숫자(`0-9`)나 영문 소문자(`a-z`)는 같은 종류끼리 **한 칸에 두 글자씩(`.c.h`)** 나란히 배정되며, 낱자 하나만 있을 때는 한 칸에 한 글자로 조판됩니다.
   * **문장부호 위치 보정 (`.c.pl`):** 마침표(`.`), 쉼표(`,`), 고리점(`。`, `、`)은 원고지 규격에 맞게 칸의 왼쪽 아래로 정렬됩니다.
   * **유니코드 결합 문자·이모지 지원 (`gridIsJoiner`):** ZWJ(`0x200D`) 이모지, 피부색 수정자, 국기(Regional Indicator), 옛한글 조합 자모를 깨뜨리지 않고 한 칸에 묶어 처리합니다.
3. **고속 차분 렌더링 (Differential DOM Patching):**
   * 글이 길어져도 전체 칸을 다시 그리지 않고, 이전 화면과 비교해 바뀌지 않은 앞쪽 줄(`P`)과 뒤쪽 줄(`S`)은 건너뛴 뒤 **수정된 가운데 줄만 부분 갱신**하며, 깜박이는 커서(`.ms-caret`)는 별도 레이어로 겹쳐 그려 초고속 타이핑 반응성을 유지합니다.
4. **400자(20줄) 단위 자동 장(張) 분할 및 가변 밑줄 제목:**
   * 20줄(400칸)이 넘어갈 때마다 자동으로 다음 장이 이어지며, 각 장 좌측 상단에는 **제목 글자 길이에 맞춰 붉은 밑줄이 실시간으로 늘어나는 제목 입력칸(`.ms-title`)**이, 하단에는 **`20×20`**, **쪽 번호(`- 1 -`)**, **`©TypeGrapher`** 상표가 자동으로 새겨집니다.

---

## 🖨️ 출판급 네이티브 벡터 PDF & 인쇄 엔진 (v2.3 ~ v2.6)

웹뷰의 기본 인쇄 기능에 의존할 때 발생하는 **'원고지 우측 칸 잘림'**이나 **'페이지 중간 줄 쪼개짐'** 문제를 해결하기 위해, Objective-C `CoreGraphics` 기반의 자체 PDF 합성 엔진(`TG_PDF_ENGINE`)을 탑재했습니다.

* **원고지 1장 = 종이 1쪽 완벽 보장 (`capturePagesPDF:`):**
  * **원고지(칸) 및 빈 원고지 양식:** 원고지 한 장(머리말 제목·날짜 + 400칸 격자 + 꼬리말 `20×20`·쪽 번호·`©TypeGrapher`) 전체 영역을 `dataWithPDFInsideRect:`로 벡터 캡처한 뒤, `CGPDFContextCreate`로 생성한 용지(**A4 / B5 / Letter**) 정중앙 여백(`12mm`) 안에 비율 왜곡 없이 정확히 맞춰 그려 넣습니다.
  * **일반 노트 및 원고지(줄):** `TreeWalker`로 모든 텍스트 줄의 실제 몸통 좌표(`printCollectCores`)를 스캔하여 **글줄 한가운데가 절대 잘리지 않도록 줄 사이에서만 쪽을 나누며**, 쪽 맨 아래에 제목(`H1`~`H6`)만 혼자 남는 현상(Orphan Heading)을 자동으로 방지합니다.
* **매체 고정 및 8×8 비트맵 배치 검증 (`TGAverageBrightness`):**
  * WebKit이 PDF를 추출할 때 임의로 `@media print` 스타일을 적용해 칸 크기가 틀어지는 현상을 막기 위해 캡처 중 `[webView setMediaStyle:@"screen"]`으로 매체를 고정하며, 문서 끝에 배치된 검증용 표식(`.tg-probe`)을 8×8 비트맵(`CGBitmapContextCreate`)으로 판독하여 단 1px의 레이아웃 밀림도 없는지 자가 검증합니다.
* **조판 스튜디오 모달 (`Cmd + P`) & 원클릭 PDF (`📄 PDF`):**
  * **잉크 선택:** 클래식 **빨간 원고지 잉크**와 흑백 레이저 프린터에 최적화된 **흑백(먹색) 잉크**를 선택할 수 있습니다.
  * **빈 원고지 양식 출력:** 손글씨나 실제 수동 타자기 용지로 쓸 수 있는 깨끗한 **빈 20×20 원고지 양식(1~50장)**을 즉시 PDF나 종이로 뽑을 수 있습니다.

---

## 🛠️ 레거시 Mac(OS X 10.7/10.8) ~ 최신 macOS 크로스 호환 아키텍처

최신 macOS 및 Xcode SDK 환경에서 빌드한 `.app` 번들을 구형 **Mac OS X 10.7 Lion / 10.8 Mountain Lion (A1181)**으로 그대로 복사해도 `dyld` 심볼 오류 없이 즉시 실행되도록 4중 안전장치를 적용했습니다.

| 기술적 난제 (신형 SDK ➔ 구형 OS X 실행 시) | TypeGrapher v2.6의 엔지니어링 해결 방식 |
| :--- | :--- |
| **`PDFKit.framework` 경로 불일치 크래시**<br>*(macOS 10.15 이전에는 `Quartz.framework` 내부의 하위 프레임워크로만 존재)* | 컴파일 타임에 `Quartz`/`PDFKit`을 직접 링크하지 않고, `dlopen()`과 `NSClassFromString(@"PDFDocument")`을 사용해 **런타임에 OS 버전별 3개 후보 경로를 순회하여 동적 로드** (`TGPDFDocumentClass`) |
| **`_OBJC_CLASS_$_NSURLRequest` 심볼 위치 이동**<br>*(OS X 10.8에서는 `Foundation`, 10.9+에서는 `CFNetwork` 소속)* | `NSClassFromString(@"NSURLRequest")` 런타임 조회 및 링커의 **`-Wl,-flat_namespace`** 옵션을 결합하여 2단계 네임스페이스(Two-Level Namespace) 심볼 고정 문제를 원천 해결 |
| **빌드 직후 자동 실행 검증 (`--tg-selftest`)** | 파이썬 빌더가 컴파일 직후 `TypeGrapher --tg-selftest` 플래그로 바이너리를 시험 구동하여 동적 링커(`dyld`) 통과 여부를 확인하고, `otool -L`로 링크된 시스템 라이브러리 경로를 자동 감사(Audit) |
| **구형 WebKit (Safari 5.1/6.0) 완벽 대응** | 프론트엔드 전체를 **100% 순수 ES5(`var`)**와 벤더 프리픽스(`-webkit-box`, `-webkit-flex`, `-webkit-linear-gradient`)로 작성 |

---

🚀 빌드 및 설치 방법 (Build & Installation)

별도의 Xcode 프로젝트 설정이나 패키지 매니저(npm, brew 등) 없이, macOS 기본 터미널에서 파이썬 빌드 스크립트 하나로 컴파일 ➔ 스큐어모피즘 아이콘(.icns) 생성 ➔ 코드 서명 ➔ /Applications/TypeGrapher.app 설치 ➔ 배포용 HFS+ 디스크 이미지(~/Desktop/TypeGrapher.dmg) 패키징까지 전 과정이 자동으로 수행됩니다.

# 1. 저장소 클론
git clone https://github.com/anstngus/TypeGrapher.git
cd TypeGrapher


# 2. 원클릭 빌드 및 설치 실행
python3 build_typegrapher_v26.py
```

* 빌드가 완료되면 `/Applications/TypeGrapher.app`이 즉시 실행되며, 바탕화면에 생성된 **`TypeGrapher.dmg`** 파일을 USB나 네트워크를 통해 구형 맥(A1181 등)으로 옮겨 바로 설치하실 수 있습니다.

---

## ⌨️ 주요 단축키 안내 (Keyboard Shortcuts)

| 단축키 | 동작 설명 |
| :--- | :--- |
| **`Cmd + N`** | 현재 선택된 폴더(또는 루트)의 맨 아래에 새 마크다운 노트 추가 |
| **`Cmd + D`** | 오늘 날짜(`YYYY년 MM월 DD일 (요일)`) 일기장 즉시 열기 및 생성 |
| **`Cmd + Shift + N`** | 현재 폴더 내부(또는 루트)에 새 하위 폴더 추가 |
| **`Cmd + Shift + S`** | 폴더 및 파일 자동 정렬 모달 열기 (가나다 이름순 / 생성일순) |
| **`Cmd + Delete`** | 현재 선택된 노트 파일 또는 하위 폴더 삭제 |
| **`Cmd + P`** | **🖨️ 인쇄 · PDF 조판 설정 스튜디오** 모달 열기 |
| **`Cmd + M`** | 현재 재생 중인 `Music` / `iTunes` **BGM 스탬프** 자동 각인 |
| **`Cmd + G`** | **🟥 월간 집필 천공 카드 히트맵 & 통계** 모달 열기 |
| **`Cmd + T`** | 다크 테마(차콜 & 크림슨 레드) ⇄ 라이트 테마(미색 종이 & 레드 잉크) 전환 |
| **`Cmd + \` / `Cmd + B`** | 좌측 파일 탐색기 사이드바 접기 / 펼치기 (에디터 포커스 시 `Cmd + B`는 굵게) |
| **`Cmd + O`** | 보관함(Vault) 루트 폴더 위치 변경 |

---

## 📚 참고 공식 기술 문서 (References)

* **Apple Developer Documentation:**
  * *Cocoa Drawing Guide* & *AppKit Framework Reference* (`NSBezierPath`, `NSBitmapImageRep`, `NSSound`, `NSWorkspace`, `NSPrintOperation`, `NSPrintInfo`)
  * *Quartz 2D Programming Guide* (`CGPDFContextCreate`, `CGPDFDocumentRef`, `CGBitmapContextCreate`)
  * *WebKit Objective-C Programming Guide* (`WebView`, `WebFrameView`, `WebScriptObject`)
  * *Mac OS X Dynamic Loader (`dyld` / `dlopen`) Manual Pages*
* **W3C Web Standards:**
  * *HTML5 Drag and Drop API*, *UI Events Composition API (Korean IME)*, *CSS Flexible Box Layout*

---

## 📄 라이선스 (License)

Copyright © 2026 Soohyun Moon. All rights reserved.
