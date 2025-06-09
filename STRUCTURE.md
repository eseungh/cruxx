CRUXX 프로젝트 파일/폴더 구조 및 역할 (SwiftPM + Xcode 기준)

“본 프로젝트는 SwiftPM(Package.swift) + Xcode 프로젝트(cruxx.xcodeproj) 구조를 항상 병행합니다.”

[⛔️ 구조 변경 이력 반영됨 – SwiftUI 기반 UI와 테스트 대상 로직 분리됨]

경로	역할(한글 설명)
Package.swift	SwiftPM 메타파일(빌드, 의존성, 테스트 자동화)
cruxx.xcodeproj/	Xcode 프로젝트 파일(앱 실행/배포/스토어 제출 필수)
Sources/ClerApp/ClerApp.swift	앱 엔트리포인트, DIContainer 연결 (SwiftUI 기반)
Sources/ClerApp/AppRouter.swift	메인 네비게이션(TabView), 화면 라우팅
Sources/ClerApp/DIContainer.swift	전역 의존성 관리, 서비스/뷰모델 주입
Sources/ClerApp/Features/Recording/RecordingView.swift	영상 녹화/카메라 프리뷰/포즈 오버레이 UI
Sources/ClerApp/Features/Session/SessionDetailView.swift	세션 상세 분석/시각화 UI
Sources/ClerCore/Recording/RecordingManager.swift	녹화 세션 제어 및 AVFoundation 캡처 로직
Sources/ClerCore/Recording/VideoWriter.swift	영상 파일 저장/녹화 관리
Sources/ClerCore/Recording/RecordingViewModel.swift	녹화 화면 상태 및 이벤트 처리
Sources/ClerCore/Session/SessionManager.swift	세션 저장/불러오기, 세션 리스트 관리
Sources/ClerCore/Analysis/PoseAnalyzer.swift	AI 동작/포즈 분석, 스켈레톤 데이터 해석 로직
Sources/ClerCore/Analysis/ClusterComparer.swift	코스/문제 클러스터링 비교 엔진
Sources/ClerModel/ClimbingSession.swift	등반 세션(1회 기록) 모델 정의
Sources/ClerModel/PoseTimestampData.swift	프레임별 포즈(스켈레톤) 데이터 구조
Sources/ClerModel/SessionDTO.swift	세션 데이터 전송 객체
Sources/ClerModel/AnalysisDTO.swift	분석 데이터 전송 객체
Sources/ClerModel/MovementType.swift	동작 분류/타입 정의(이동, 정지, 점프 등)
Tests/ClerCoreTests/RecordingManagerTests.swift	녹화 로직 관련 유닛 테스트
Tests/ClerCoreTests/SessionManagerTests.swift	세션 저장/로드 테스트
Tests/ClerCoreTests/PoseAnalyzerTests.swift	포즈 분석 로직 테스트
Assets.xcassets/	앱 아이콘, 색상, 이미지 등 리소스 폴더
Preview/MockData.swift	프리뷰용 목업/더미 데이터
README.md	프로젝트 소개, 빌드/실행 방법 등 문서
AGENTS.md	프로젝트 운영/협업 최상위 가이드
STRUCTURE.md	폴더/파일 구조 및 위치 기준 (이 문서)
PROTOCOLS.md	서비스/매니저/뷰모델 프로토콜 기준
