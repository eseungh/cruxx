cruxx 프로젝트 파일/폴더 구조 및 역할 (SwiftPM + Xcode 기준)

“본 프로젝트는 SwiftPM(Package.swift) + Xcode 프로젝트(cruxx.xcodeproj) 구조를 병행합니다.”

[구조 목적]
	•	SwiftUI 기반 UI는 cruxxApp 모듈에 격리
	•	테스트 및 로직은 cruxxCore 모듈 내에서 SwiftUI 없이 수행
	•	데이터 모델은 cruxxModel로 분리, 경량화 및 공유 목적

⸻

[루트]

Package.swift
→ SwiftPM 메타 파일 (모듈, 테스트, 의존성 정의)

cruxx.xcodeproj/
→ Xcode 프로젝트 파일 (앱 실행 및 배포용)

⸻

[Sources/cruxxApp] – SwiftUI 기반 UI 계층

ClerApp.swift
→ 앱 진입점, DIContainer 주입

AppRouter.swift
→ 탭 기반 메인 네비게이션

Features/Recording/RecordingView.swift
→ 녹화 화면 UI 및 프리뷰

Features/Session/SessionDetailView.swift
→ 세션 분석 화면

Shared/Components/*.swift
→ 공통 버튼, 포즈 오버레이 등 UI 컴포넌트

Shared/Extensions/*.swift
→ Swift 확장 함수들 (주로 UI 관련)

⸻

[Sources/cruxxCore] – 비즈니스 로직 / 테스트 대상 계층

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

[Sources/cruxxModel] – 공통 데이터 모델 정의

ClimbingSession.swift
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

[Tests/cruxxCoreTests] – 로직 테스트 계층

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

위 구조는 SwiftUI 제거, 테스트 가능성 확보, 계층 경계 명확화를 목표로 설계됨.
Codex 및 협업 툴 사용 시 혼동 없도록 구조적 기준으로 고정.
