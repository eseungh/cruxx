# CRUXX

CRUXX는 iOS 기반 실내 클라이밍 분석 앱입니다.
사용자는 등반 영상을 녹화하고, 온디바이스(on-device) AI가 동작 및 포즈를 분석하여
각 세션을 시각화된 데이터로 기록할 수 있습니다.

---

## ✨ 주요 기능

* **영상 녹화 및 자동 분석**
  후면 카메라로 촬영된 등반 영상을 기반으로,
  온디바이스 AI가 시계열 기반 포즈 및 동작을 자동 분석합니다.

* **세션 기록 및 탐색**
  분석 결과는 세션 단위로 저장되며, 대시보드와 리스트에서 확인할 수 있습니다.

* **문제 구조 인식 및 클러스터링 (프리미엄 기능)**
  홀드 인식과 무브 분석을 조합하여 문제를 정의하고,
  다른 사용자와의 비교 분석까지 지원합니다.

* **로컬 저장소 기반 작동**
  모든 데이터는 로컬에 저장되며, 프라이버시를 보장합니다.

---

## 🧱 프로젝트 구조

> 자세한 폴더 설명은 [STRUCTURE.md](STRUCTURE.md) 참조

```
Sources/
  ├── cruxxApp/         # SwiftUI 기반 앱 UI
  ├── cruxxCore/        # 도메인 로직 및 분석 서비스
  └── cruxxModel/       # DTO 및 도메인 모델

Tests/
  └── cruxxCoreTests/   # ViewModel 및 Core 로직 테스트
```

* 아키텍처: MVVM + DI + Modular (SwiftPM 기반)
* 주요 모듈: `cruxxApp`, `cruxxCore`, `cruxxModel`
* 테스트 기준: 책임 단위별 분리, 구조 안정성 우선

---

## 🚀 실행 방법

### 1. 의존성 설치 및 빌드

```bash
git clone https://github.com/eseungh/cruxx.git
cd cruxx
swift build
```

### 2. 테스트 실행 (macOS CLI 전용)

```bash
swift test
```

> ✅ 모든 테스트는 macOS CLI 환경에서만 수행됩니다.
> ❌ Codex는 `swift test` 또는 `swift build`를 직접 실행하지 않습니다.

---

## 📌 개발 규칙

* 모든 구조와 코드는 `AGENTS.md`, `STRUCTURE.md`, `PROTOCOLS.md` 기준을 준수합니다.
* 테스트 실행은 로컬(macOS CLI)에서만 수행하며, Codex는 테스트 코드 작성까지만 담당합니다.
* `@MainActor`, `Sendable`, `@Published` 등 동시성 관련 키워드는 Swift 6 기준으로 엄격히 관리합니다.
* 테스트 함수명은 반드시 `test[A-Z]`로 시작하는 **영문 함수명**만 사용합니다. (한글 함수명은 금지)

---

## 🧭 설계 철학

CRUXX는 단순한 기능 구현이 아니라,
**설계자의 구조와 책임을 코드로 증명하는 시스템**입니다.
모든 로직은 명확한 목적과 의도를 중심으로 작동합니다.

---

## 🛠 기술 스택

* Language: Swift 5.10+
* UI Framework: SwiftUI
* Package Manager: SwiftPM
* 동작 분석: AVFoundation + Custom Pose AI
* 테스트: XCTest + SwiftPM 기반 유닛 테스트

---

## 👨‍💻 프로젝트 리드

* 이승호 (@eseungh)

  * 앱 설계 및 구조 총괄
  * AI + 영상 분석 시스템, 오프라인 클러스터링 설계
  * 명확한 설계 원칙을 중시하는 구조 통제자

---

## 📂 참고 문서

* [STRUCTURE.md](STRUCTURE.md) — 폴더/파일 구조 기준
* [PROTOCOLS.md](PROTOCOLS.md) — 각 레이어별 책임 인터페이스
* [AGENTS.md](AGENTS.md) — 전체 협업 및 코드 작성 원칙

### DIContainer 초기화 예시

```swift
Task { @MainActor in
    let manager = SessionManager()
    let container = DIContainer(sessionManager: manager)
    // 이후 View 또는 ViewModel에 container를 주입합니다.
}
```
