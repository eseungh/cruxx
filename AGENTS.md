
CRUXX 앱 Notion 기본 지침

(프로젝트 구조, 기능 범위, AI 엔진, 협업 원칙, SwiftPM + Xcode 필수)

⸻

[항상 참조할 기준 문서]

본 프로젝트의 모든 개발/설계/리팩토링/문서 작업은 아래 3개 문서를 항상 참조하여 진행합니다.
1.    [AGENTS.md](http://agents.md/) : 이 문서, 프로젝트 운영 및 협업의 최상위 가이드
2.    [STRUCTURE.md](http://structure.md/) : 폴더/파일 구조, 명명 규칙, 구현 위치
3.    [PROTOCOLS.md](http://protocols.md/) : 모든 서비스/매니저/뷰모델이 준수해야 할 프로토콜/인터페이스 정의
→ Codex/에이전트/개발자 누구든 새로운 작업 전에 반드시 이 3개 문서를 먼저 확인하고,
모든 작업(생성/구현/수정/확장)은 정의된 기준 내에서만 진행해야 합니다.

⸻

1. 프로젝트 목적 및 개발 철학
•    CRUXX 앱은 iOS에서 실내 클라이밍 영상을 촬영하고,
AI로 등반 동작 및 세션을 분석·관리하는 앱입니다.
•    모든 기능/데이터/분석은 사용자 경험, 프라이버시, 확장성을 최우선으로 설계합니다.

⸻

1. 전체 구조 및 아키텍처 (SwiftPM + Xcode 필수)

2-1. 폴더/모듈 구조
•    최상단에 Package.swift: SwiftPM(빌드/테스트/의존성 관리) 메타파일
•    cruxx.xcodeproj(또는 CRUXX.xcodeproj):
•    항상 포함되는 Xcode 프로젝트 파일
•    앱 실행, 시뮬레이터, iOS 배포, 리소스 관리, 앱스토어 제출 등은 반드시 Xcode에서 처리
•    SwiftPM 모듈과 연동하여 혼합 관리
•    Sources/CRUXX/:
•    App/, Core/, Features/, Shared/, Data/, Infrastructure/ 등 실제 소스 코드 폴더
•    Tests/CRUXXTests/:
•    테스트/목업/유닛테스트 파일
•    [AGENTS.md](http://agents.md/), [STRUCTURE.md](http://structure.md/), [PROTOCOLS.md](http://protocols.md/):
•    프로젝트 기준 문서
•    Assets.xcassets, Preview/ 등 리소스/프리뷰 폴더

2-2. 아키텍처 원칙
•    MVVM + DI + 모듈화
•    모든 서비스는 DIContainer로 주입
•    데이터, 로직, UI를 책임 분리하여 유지보수성과 확장성 확보
•    빌드/테스트/실행은 기본적으로 SwiftPM(swift build, swift test, swift run)
→ 최종 앱 실행/시뮬레이터/배포/스토어 제출 등은 반드시 Xcode에서 진행

⸻

1. 기능 범위 (무료/프리미엄 구분)

3-1. 무료(기본) 기능
•    실내 클라이밍 영상 촬영, 녹화 전 프리뷰, 녹화 중 실시간 포즈 오버레이
•    영상 자동 저장, 세션(1회 등반) 단위로 기록 관리
•    AI 기반 동작·포즈 분석(온디바이스 추론)
•    세션 리스트/상세에서 영상과 분석 데이터 확인
•    대시보드(최근 세션, 누적 통계), 설정(알림, 개인정보 등)
•    데이터는 기기 내 로컬에만 저장, 삭제/편집/이동 가능

3-2. 프리미엄(유료) 기능
•    세션별 상세 분석 리포트(PDF), 고급 동작/무브 분석
•    문제(코스) 클러스터링, 무브/코스 패턴 비교, 히트맵
•    AI 맞춤 피드백, 성장 그래프, 추천 무브
•    클라우드 백업/동기화, 다중 기기 지원
•    고급 필터/검색, 프리미엄 테마 등

⸻

1. AI 엔진 및 데이터 처리 원칙
•    기본 AI: Core ML + Apple Vision 기반 온디바이스 추론(프라이버시, 저지연)
•    예: MoveNet/BlazePose, 커스텀 분류/회귀/클러스터링 모델
•    프리미엄/확장 AI:
•    고급 분석, 클러스터링, 추천/피드백 생성(경량 LLM, 필요 시 서버 확장)
•    데이터:
•    기본적으로 로컬 저장
•    프리미엄에서만 클라우드 동기화, 개인정보 보호 최우선
•    AI 파이프라인은 모듈화하여 향후 모델 교체/확장 용이하게 설계

⸻

1. 협업 및 개발 원칙
•    코드, 문서, 주석, 커밋 메시지 모두 한글로 작성
•    브랜치 명명은 영어
•    새로운 기능은 반드시 기존 구조(MVVM, DI, 모듈화, SwiftPM, Xcode) 내에서 구현
•    주요 로직은 Core/Service, 재사용 UI는 Shared/Components에 위치
•    작업 내역, 이슈, 설명, 코드 리뷰 모두 Notion 및 저장소에 기록
•    오픈채팅·Codex·AI 에이전트 협업 시에도 동일 기준 적용

5-2. 작업 예시
•    함수/클래스 주석:

```swift
// 사용자의 등반 세션을 저장하는 함수입니다.
```

- 커밋 메시지:

```
세션 상세 화면에서 영상 재생 오류 수정
```

- 설명(문서/리뷰):

```
PoseAnalyzer에서 분석 정확도를 높이기 위해 threshold 값을 조정하였습니다.
```

⸻

1. 기타 참고
• 서비스별 DIContainer 접근
• 세션, 분석 데이터 등 모든 핵심 데이터는 영속성·일관성 유지에 주의
• 신규 기능/컴포넌트 추가 시에는 이 문서를 우선 참고할 것
• 불확실한 경우에는 팀 내 공유/검토 후 확정

## [디렉토리 작업 범위 제한(Directory Scope Restriction)]

- 모든 개발/수정/생성/삭제 작업은  
  **반드시 미리 지정된 폴더(예: Sources/CRUXX/Features/Recording 등)** 내에서만 수행해야 하며,  
  **그 외의 경로(Core/Service, Data/Repository, Shared 등)는 절대 변경/삭제/생성 금지**
- 팀원/AI/Codex/에이전트/외주 등  
  누구든 작업 범위가 명확히 지정된 경우  
  반드시 “해당 디렉토리 이하만 작업” 원칙을 지켜야 함

> Unless otherwise specified, all code changes must be strictly limited to the directory explicitly specified in each task request (e.g., Sources/CRUXX/Features/Recording).  
> Do NOT edit, create, or delete files outside the designated scope.

- 이 원칙은  
  **코드 구현, 리팩토링, 테스트, 주석, 커밋, 자동화 작업 전부에 동일하게 적용**

⸻

[참고]
•    [AGENTS.md], [STRUCTURE.md], [PROTOCOLS.md]
→ 이 세 파일을 항상 참조하여 작업/코드/문서/AI 협업을 진행하세요.
