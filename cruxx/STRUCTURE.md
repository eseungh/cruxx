
cruxx 프로젝트 파일/폴더 구조 및 역할 (Xcode 기반)

“본 프로젝트는 Xcode 프로젝트(cruxx.xcodeproj)를 루트로 사용하며, 실제 소스 파일은 하위 cruxx/ 디렉토리에 위치합니다.”

[구조 목적]
• SwiftUI 기반 UI는 App 폴더에 격리
• 비즈니스 로직 및 뷰모델은 Core 폴더에 위치
• 공통 모델 및 데이터 구조는 Model에 분리
• 테스트는 Tests 폴더에서 각 책임 단위별로 수행

⸻

[루트]

cruxx.xcodeproj/
→ Xcode 프로젝트 파일 (앱 실행 및 구조 관리 중심)

cruxx/
→ 실제 소스 코드가 위치한 폴더 (App, Core, Model, Resources 등 포함)

⸻

[cruxx/App] – SwiftUI 기반 UI 계층

cruxxApp.swift
→ 앱 진입점, DIContainer 주입

ContentView.swift
→ 메인 탭 화면

Features/Recording/RecordingView.swift
→ 녹화 화면 UI 및 프리뷰

Features/Session/SessionDetailView.swift
→ 세션 분석 화면

Shared/Components/*.swift
→ 공통 버튼, 포즈 오버레이 등 UI 컴포넌트

Shared/Extensions/*.swift
→ Swift 확장 함수들 (주로 UI 관련)

⸻

[cruxx/Core] – 비즈니스 로직 / 테스트 대상 계층

Recording/RecordingManager.swift
→ AVFoundation 기반 녹화 세션 제어

Recording/RecordingViewModel.swift
→ 녹화 상태/이벤트 관리

Recording/VideoWriter.swift
→ 파일 저장 및 AssetWriter 처리

Session/SessionManager.swift
→ 세션 저장 및 불러오기

Analysis/PoseAnalyzer.swift
→ 포즈 인식 및 프레임 시계열 분석

Analysis/ClusterComparer.swift
→ 등반 문제 클러스터링 비교

Utils/Constants.swift
→ 상수 및 공용 파라미터 정의

⸻

[cruxx/Model] – 공통 데이터 모델 정의

ClimbingSessionModel.swift
→ 등반 세션 구조

SessionDTO.swift
→ 세션 전송용 데이터 구조체

AnalysisDTO.swift
→ 분석 결과 전송 구조체

PoseTimestampData.swift
→ 프레임별 스켈레톤 포즈 데이터

MovementType.swift
→ 동작 분류 enum (예: 이동, 정지, 점프)

⸻

[Tests] – 로직 테스트 계층

RecordingManagerTests.swift
→ 녹화 로직 테스트

SessionManagerTests.swift
→ 세션 로딩/저장 테스트

PoseAnalyzerTests.swift
→ 포즈 분석 테스트

⸻

[기타]

Assets.xcassets/
→ 아이콘, 색상 등 앱 리소스

Resources/
→ background 이미지 등 외부 자산

Preview/MockData.swift
→ SwiftUI Preview용 더미 데이터

README.md
→ 프로젝트 소개 문서

STRUCTURE.md
→ 이 문서 (폴더 구조 설명)

PROTOCOLS.md
→ 서비스/뷰모델/매니저 프로토콜 기준 정의

AGENTS.md
→ 협업 운영 기준 정리

⸻

📌 Codex 또는 에이전트 작업 시 주의사항:

> 모든 실제 소스 경로는 `cruxx/` 폴더 하위(App, Core, Model 등)를 기준으로 작업해야 하며,  
> 루트 디렉토리에서 파일을 생성하거나 수정해서는 안 됩니다.  
> 이 구조는 협업 및 자동화 도구와의 일관성을 위해 고정됩니다.
