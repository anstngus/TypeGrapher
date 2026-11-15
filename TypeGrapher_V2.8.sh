setopt NO_BANG_HIST
cat << 'PYEOF' > /tmp/build_typegrapher_v28.py
import os, shutil, subprocess, plistlib

desktop = os.path.expanduser("~/Desktop")
downloads = os.path.expanduser("~/Downloads")
documents = os.path.expanduser("~/Documents")
stage_dir = os.path.join(desktop, "TypeGrapher_Stage")
app_path = os.path.join(stage_dir, "TypeGrapher.app")
dmg_path = os.path.join(desktop, "TypeGrapher.dmg")
installed_app = "/Applications/TypeGrapher.app"

# 1. 실행 중인 앱 종료 및 이전 임시 파일 정리
subprocess.run(["pkill", "-9", "-f", "TypeGrapher"], check=False)
for old_p in [
    stage_dir,
    dmg_path,
    os.path.join(desktop, "TypeGrapher_MacOSX_10.7.dmg"),
    os.path.join(desktop, "ObsidianRetro_Hybrid_10.7.dmg"),
    os.path.join(desktop, "ObsidianLegacy_MacOSX_10.7.dmg")
]:
    if os.path.exists(old_p):
        if os.path.isdir(old_p) and not os.path.islink(old_p):
            shutil.rmtree(old_p)
        else:
            os.remove(old_p)

contents_dir = os.path.join(app_path, "Contents")
macos_dir = os.path.join(contents_dir, "MacOS")
res_dir = os.path.join(contents_dir, "Resources")
os.makedirs(macos_dir, exist_ok=True)
os.makedirs(res_dir, exist_ok=True)

# 2. 5대 시그니처 기능 + 기존 v15 모든 기능이 완벽 통합된 HTML/CSS/JS 엔진
html_content = r'''<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>TypeGrapher</title>
<style>
  * {
    -webkit-box-sizing: border-box;
    -moz-box-sizing: border-box;
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }

  html, body {
    width: 100%;
    height: 100%;
    overflow: hidden;
    font-family: "Apple SD Gothic Neo", "Malgun Gothic", -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif;
    font-size: 14px;
    line-height: 1.6;
    -webkit-font-smoothing: antialiased;
  }

  body.resizing-sidebar,
  body.resizing-sidebar * {
    cursor: col-resize !important;
    -webkit-user-select: none !important;
    user-select: none !important;
  }

  /* ==========================================================================
     Dark Theme (Charcoal Keycap & Vintage Crimson Red)
     ========================================================================== */
  body.theme-dark { background-color: #1c1c1c; color: #e2e0dc; }
  body.theme-dark .ribbon { background-color: #141414; border-right: 1px solid #2e2a2a; }
  body.theme-dark .sidebar { background-color: #201e1e; border-right: 1px solid #2e2a2a; }
  body.theme-dark .sidebar-header { border-bottom: 1px solid #2e2a2a; }
  body.theme-dark .search-input,
  body.theme-dark .modal-input { background-color: #141414; border: 1px solid #383232; color: #e2e0dc; }
  body.theme-dark .search-input:focus,
  body.theme-dark .modal-input:focus { border-color: #d92b2b; }
  body.theme-dark .folder-header { color: #e6e1d6; background-color: #1a1818; border-bottom: 1px solid #282323; }
  body.theme-dark .folder-header:hover { background-color: #292222; color: #ffffff; }
  body.theme-dark .folder-header.selected-folder { background-color: #331a1a; color: #ff8585; border-left: 4px solid #e03131; }
  body.theme-dark .note-item { color: #a8a49e; border-bottom: 1px solid rgba(255,255,255,0.03); }
  body.theme-dark .note-item:hover { background-color: #2c2626; color: #ffffff; }
  body.theme-dark .note-item.active {
    background-color: #3b1a1a;
    color: #ffffff;
    border-left: 4px solid #e03131;
    font-weight: 600;
  }
  body.theme-dark .topbar { background-color: #201e1e; border-bottom: 1px solid #2e2a2a; }
  body.theme-dark .toolbar { background-color: #181616; border-bottom: 1px solid #2e2a2a; }
  body.theme-dark .live-editor-scroll { background-color: #1c1c1c; color: #e2e0dc; }
  body.theme-dark .statusbar { background-color: #141414; border-top: 1px solid #2e2a2a; color: #8c8686; }
  body.theme-dark .btn { background-color: #2a2626; color: #d4d0c8; border: 1px solid #3d3535; }
  body.theme-dark .btn:hover { background-color: #383030; color: #ffffff; }
  body.theme-dark .btn.active,
  body.theme-dark .btn-primary {
    background-color: #d92b2b;
    color: #ffffff;
    border-color: #d92b2b;
  }
  body.theme-dark .btn-primary:hover { background-color: #b81d1d; border-color: #b81d1d; }
  body.theme-dark .title-input { color: #ffffff; }
  body.theme-dark .title-input:focus { background-color: #2c2626; border-color: #d92b2b; }
  body.theme-dark .modal-box { background-color: #252222; border: 1px solid #423535; color: #e2e0dc; }
  body.theme-dark .active-folder-bar { background-color: #181515; border-bottom: 1px solid #2e2a2a; color: #b8b0a8; }

  /* ==========================================================================
     Light Theme (Warm Typewriter Paper & Classic Red Ribbon Ink)
     ========================================================================== */
  body.theme-light { background-color: #faf8f5; color: #262422; }
  body.theme-light .ribbon { background-color: #ebe6df; border-right: 1px solid #d6d0c6; }
  body.theme-light .sidebar { background-color: #f3efe9; border-right: 1px solid #ded8ce; }
  body.theme-light .sidebar-header { border-bottom: 1px solid #ded8ce; }
  body.theme-light .search-input,
  body.theme-light .modal-input { background-color: #ffffff; border: 1px solid #ccc5b9; color: #262422; }
  body.theme-light .search-input:focus,
  body.theme-light .modal-input:focus { border-color: #c81e1e; }
  body.theme-light .folder-header { color: #3d3935; background-color: #ebe5dc; border-bottom: 1px solid #ded8ce; }
  body.theme-light .folder-header:hover { background-color: #e2dad0; color: #111111; }
  body.theme-light .folder-header.selected-folder { background-color: #f9dcdc; color: #991b1b; border-left: 4px solid #c81e1e; }
  body.theme-light .note-item { color: #5c5751; border-bottom: 1px solid rgba(0,0,0,0.04); }
  body.theme-light .note-item:hover { background-color: #e8e2d9; color: #111111; }
  body.theme-light .note-item.active {
    background-color: #fde8e8;
    color: #881313;
    border-left: 4px solid #c81e1e;
    font-weight: 700;
  }
  body.theme-light .topbar { background-color: #f3efe9; border-bottom: 1px solid #ded8ce; }
  body.theme-light .toolbar { background-color: #f7f4ef; border-bottom: 1px solid #ded8ce; }
  body.theme-light .live-editor-scroll { background-color: #faf8f5; color: #262422; }
  body.theme-light .statusbar { background-color: #ebe6df; border-top: 1px solid #d6d0c6; color: #666059; }
  body.theme-light .btn { background-color: #ffffff; color: #3d3935; border: 1px solid #ccc5b9; }
  body.theme-light .btn:hover { background-color: #f2ece4; color: #111111; }
  body.theme-light .btn.active,
  body.theme-light .btn-primary {
    background-color: #c81e1e;
    color: #ffffff;
    border-color: #c81e1e;
  }
  body.theme-light .btn-primary:hover { background-color: #a51515; border-color: #a51515; }
  body.theme-light .title-input { color: #111111; }
  body.theme-light .title-input:focus { background-color: #ebe5dc; border-color: #c81e1e; }
  body.theme-light .modal-box { background-color: #faf8f5; border: 1px solid #ccc5b9; color: #262422; }
  body.theme-light .active-folder-bar { background-color: #ece6de; border-bottom: 1px solid #ded8ce; color: #5c5751; }

  /* ==========================================================================
     v2.8 사이드바 항목 메뉴 (우클릭 · Control+클릭 · 길게 누르기)
     ========================================================================== */
  .ctx-menu {
    display: none; position: fixed; left: 0; top: 0; z-index: 9500;
    min-width: 196px; max-width: 320px; padding: 5px 0;
    border-radius: 7px; font-size: 13px; line-height: 1.35; cursor: default;
    -webkit-box-shadow: 0 8px 28px rgba(0, 0, 0, 0.35); box-shadow: 0 8px 28px rgba(0, 0, 0, 0.35);
    -webkit-user-select: none; user-select: none;
  }
  .ctx-menu.show { display: block; }
  .ctx-head {
    padding: 4px 14px 7px 14px; margin-bottom: 4px; font-size: 11px; font-weight: 700;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
  }
  .ctx-item { padding: 6px 14px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .ctx-item.disabled { opacity: 0.38; }
  .ctx-sep { height: 1px; margin: 4px 0; }
  body.theme-dark .ctx-menu { background-color: #252222; border: 1px solid #423535; color: #e2e0dc; }
  body.theme-dark .ctx-head { color: #9c948c; border-bottom: 1px solid #3a3030; }
  body.theme-dark .ctx-sep { background-color: #3a3030; }
  body.theme-dark .ctx-item.danger { color: #ff8585; }
  body.theme-dark .ctx-item:hover, body.theme-dark .ctx-item.hot { background-color: #d92b2b; color: #ffffff; }
  body.theme-dark .ctx-item.disabled:hover, body.theme-dark .ctx-item.disabled.hot { background-color: transparent; color: #e2e0dc; }
  body.theme-light .ctx-menu { background-color: #faf8f5; border: 1px solid #ccc5b9; color: #262422; }
  body.theme-light .ctx-head { color: #7a736a; border-bottom: 1px solid #ded8ce; }
  body.theme-light .ctx-sep { background-color: #ded8ce; }
  body.theme-light .ctx-item.danger { color: #b91c1c; }
  body.theme-light .ctx-item:hover, body.theme-light .ctx-item.hot { background-color: #c81e1e; color: #ffffff; }
  body.theme-light .ctx-item.disabled:hover, body.theme-light .ctx-item.disabled.hot { background-color: transparent; color: #262422; }
  /* 메뉴가 가리키는 사이드바 항목 */
  .note-list li.ctx-target { outline: 2px solid #e03131; outline-offset: -2px; }

  /* Drag and Drop Visual Feedback Styles */
  .dragging-item { opacity: 0.45 !important; }
  .drag-over-target {
    background-color: rgba(217, 43, 43, 0.28) !important;
    outline: 2px dashed #e03131 !important;
    outline-offset: -2px;
  }

  /* 2-Column Layout Architecture */
  .app-shell { position: relative; width: 100%; height: 100%; }
  .main-body {
    position: absolute;
    top: 0; left: 0; right: 0; bottom: 26px;
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-orient: horizontal; -webkit-flex-direction: row; flex-direction: row;
    overflow: hidden;
  }

  .ribbon {
    width: 42px; min-width: 42px; height: 100%;
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-orient: vertical; -webkit-flex-direction: column; flex-direction: column;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
    padding: 10px 0;
    -webkit-user-select: none; user-select: none;
  }

  .ribbon-btn {
    width: 30px; height: 30px; margin-bottom: 8px;
    border-radius: 5px; border: none; background: transparent;
    color: #888888; font-size: 15px; cursor: pointer;
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
    -webkit-box-pack: center; -webkit-justify-content: center; justify-content: center;
  }
  .ribbon-btn:hover {
    background-color: rgba(217, 43, 43, 0.18);
    color: #e03131;
  }
  .ribbon-btn.active-ribbon {
    background-color: #d92b2b;
    color: #ffffff;
  }
  .ribbon-spacer { -webkit-box-flex: 1; -webkit-flex: 1; flex: 1; }

  /* 1st Division: Resizable Left File Explorer Sidebar */
  .sidebar {
    width: 280px; min-width: 180px; max-width: 520px;
    height: 100%; position: relative;
  }
  .sidebar.collapsed { display: none !important; }

  .sidebar-resizer {
    width: 5px; min-width: 5px; height: 100%;
    cursor: col-resize; background: transparent;
    z-index: 50; margin-left: -3px; margin-right: -2px;
    -webkit-transition: background-color 0.12s ease;
    transition: background-color 0.12s ease;
  }
  .sidebar-resizer:hover,
  .sidebar-resizer.active { background-color: rgba(217, 43, 43, 0.65); }
  .sidebar-resizer.hidden { display: none !important; }

  .sidebar-header { padding: 10px 12px; height: 112px; }
  .vault-title {
    font-size: 12px; font-weight: 800; letter-spacing: 0.5px;
    color: #e03131; margin-bottom: 8px; cursor: pointer;
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-pack: justify; -webkit-justify-content: space-between; justify-content: space-between;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
  }
  body.theme-light .vault-title { color: #c81e1e; }
  .vault-title:hover { text-decoration: underline; }
  .search-input { width: 100%; padding: 6px 8px; border-radius: 4px; font-size: 12px; outline: none; }
  .sidebar-actions {
    display: -webkit-box; display: -webkit-flex; display: flex;
    margin-top: 8px;
  }
  .sidebar-actions .btn {
    -webkit-box-flex: 1; -webkit-flex: 1; flex: 1;
    padding: 5px 4px; font-size: 11px; margin-right: 5px;
  }
  .sidebar-actions .btn:last-child { margin-right: 0; }

  .active-folder-bar {
    height: 30px; padding: 0 10px 0 12px; font-size: 11px;
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
    -webkit-box-pack: justify; -webkit-justify-content: space-between; justify-content: space-between;
    -webkit-user-select: none; user-select: none;
  }
  .active-folder-text {
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    -webkit-box-flex: 1; -webkit-flex: 1; flex: 1;
    margin-right: 6px; cursor: pointer;
  }
  .active-folder-text:hover { text-decoration: underline; }
  .bar-right-btns {
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
  }
  .mini-bar-btn {
    border: 1px solid rgba(217, 43, 43, 0.35);
    background: rgba(217, 43, 43, 0.12);
    color: #ff8585; border-radius: 3px;
    font-size: 10.5px; font-weight: 600;
    padding: 2px 6px; margin-left: 4px; cursor: pointer;
  }
  body.theme-light .mini-bar-btn {
    color: #b91c1c; background: rgba(200, 30, 30, 0.08);
    border-color: rgba(200, 30, 30, 0.25);
  }
  .mini-bar-btn:hover { background: #d92b2b; color: #ffffff; }

  .note-list {
    position: absolute; top: 142px; bottom: 0; left: 0; right: 0;
    overflow-y: auto; padding: 4px 0 90px 0; list-style: none;
  }

  .folder-header {
    min-height: 36px; padding: 6px 8px 6px 10px;
    font-size: 13px; font-weight: 700; cursor: pointer;
    border-left: 4px solid transparent;
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-pack: justify; -webkit-justify-content: space-between; justify-content: space-between;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
    -webkit-user-select: none; user-select: none;
  }
  .folder-title-wrap {
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    -webkit-box-flex: 1; -webkit-flex: 1; flex: 1; margin-right: 6px;
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
    pointer-events: none;
  }
  .folder-toggle-arrow {
    display: inline-block; width: 18px; height: 18px; line-height: 18px;
    text-align: center; font-size: 14.5px; color: #e03131;
    background: transparent; margin-right: 5px; pointer-events: none;
  }
  body.theme-light .folder-toggle-arrow { color: #c81e1e; }
  .folder-right-controls {
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
  }
  .folder-action-mini-btn {
    border: none; background: rgba(217, 43, 43, 0.14); color: #ff8080;
    border-radius: 4px; font-size: 12px; font-weight: bold;
    padding: 0 6px; height: 22px; line-height: 22px;
    margin-right: 4px; cursor: pointer; opacity: 0.78;
  }
  body.theme-light .folder-action-mini-btn { color: #b91c1c; background: rgba(200, 30, 30, 0.12); }
  .folder-action-mini-btn:hover { opacity: 1; background: #d92b2b; color: #ffffff; }
  .folder-badge {
    font-size: 11px; opacity: 0.75; font-weight: 600;
    min-width: 16px; text-align: right; pointer-events: none;
  }

  .note-item {
    padding: 8px 14px; cursor: pointer;
    border-left: 4px solid transparent;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    font-size: 13px; position: relative;
    -webkit-user-select: none; user-select: none;
  }
  .note-item-title { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; pointer-events: none; }
  .note-item-date { display: block; font-size: 10px; opacity: 0.58; margin-top: 2px; pointer-events: none; }

  /* 2nd Division: Unified Live Editor/Viewer Workspace */
  .workspace {
    -webkit-box-flex: 1; -webkit-flex: 1; flex: 1;
    height: 100%; position: relative; overflow: hidden;
  }

  .topbar {
    position: absolute; top: 0; left: 0; right: 0; height: 44px;
    padding: 0 18px;
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
    -webkit-box-pack: justify; -webkit-justify-content: space-between; justify-content: space-between;
  }
  .title-wrapper {
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
    -webkit-box-flex: 1; -webkit-flex: 1; flex: 1; margin-right: 12px; min-width: 0;
  }
  .folder-tag-pill {
    font-size: 11px; padding: 2px 7px; border-radius: 4px;
    background-color: rgba(217, 43, 43, 0.16); color: #ff8080;
    border: 1px solid rgba(217, 43, 43, 0.3); margin-right: 8px; white-space: nowrap;
  }
  body.theme-light .folder-tag-pill { color: #b91c1c; background-color: rgba(200, 30, 30, 0.1); }
  /* v2.7: 제목칸은 폭 제한(예전 480px) 없이 상단 줄의 남는 자리를 모두 쓴다.
     (width: 100% 는 예전 방식 flex(-webkit-box)만 알아듣는 구형 WebKit 을 위한 값이고, 폴더 표시가 함께 있을 때는
      flex 가 그만큼 줄여 준다. 새 방식 flex 에서는 flex-basis 0% 가 우선한다.) */
  .title-input {
    display: block; width: 100%; min-width: 0;
    -webkit-box-flex: 1; -webkit-flex: 1 1 0%; flex: 1 1 0%;
    -webkit-box-sizing: border-box; box-sizing: border-box;
    background: transparent;
    border: 1px solid transparent; font-size: 16px; font-weight: 700;
    padding: 4px 8px; border-radius: 4px; outline: none;
  }
  /* 칸보다 긴 제목을 고치는 동안에는 오른쪽 단추들을 잠시 숨겨, 제목칸이 상단 줄 전체를 쓴다 (입력을 마치면 되돌아옴) */
  .topbar.title-wide .topbar-controls { display: none; }
  .topbar.title-wide .title-wrapper { margin-right: 0; }
  .topbar-controls {
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
  }
  .topbar-controls .btn { margin-left: 6px; }

  .toolbar {
    position: absolute; top: 44px; left: 0; right: 0; height: 36px;
    padding: 0 14px;
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
    overflow-x: auto;
  }
  .toolbar.hidden { display: none; }
  .tool-btn {
    background: transparent; border: 1px solid transparent; color: inherit;
    opacity: 0.8; padding: 3px 7px; margin-right: 2px;
    border-radius: 4px; font-size: 11.5px; font-weight: 600;
    cursor: pointer; white-space: nowrap;
  }
  .tool-btn:hover {
    opacity: 1; background-color: rgba(217, 43, 43, 0.18); color: #e03131;
  }
  .tool-btn.active-tool {
    opacity: 1; background-color: #d92b2b; color: #ffffff !important;
  }
  body.theme-light .tool-btn:hover { color: #c81e1e; }
  .tool-sep { width: 1px; height: 16px; background-color: #554848; margin: 0 5px; opacity: 0.4; }

  /* Unified Single-Pane Live Editor & Viewer */
  .live-editor-scroll {
    position: absolute; top: 80px; bottom: 0; left: 0; right: 0;
    overflow-y: auto; padding: 32px 48px 120px 48px; cursor: text;
  }
  .live-editor-scroll.zen-active { top: 44px; }
  /* 시그니처 기능 2: 타자기 중앙 고정 스크롤 시 마지막 줄도 화면 중앙에 올 수 있도록 상하 여백 확장 */
  .live-editor-scroll.typewriter-scroll-pad {
    padding-top: 28vh;
    padding-bottom: 45vh;
  }

  .live-editor-canvas {
    max-width: 820px; min-height: 100%; margin: 0 auto;
    outline: none; word-wrap: break-word;
    font-size: 15px; line-height: 1.8; caret-color: #e03131;
  }

  /* 시그니처 기능 2: 문장 집중 조명 (Focus Light Mode) + v2.1 글로우
     - 작성 중인 문단은 은은하게 빛나고, 타이핑하는 순간(typing-now) 더 밝아졌다가 서서히 잦아듭니다.
     - 다크 테마: 하얀 네온 / 라이트 테마: 스탠드 불빛(호박색) + 갓 찍힌 붉은 잉크 번짐 */
  .live-editor-canvas.focus-mode-active > * {
    opacity: 0.26;
    -webkit-transition: opacity 0.16s ease, text-shadow 0.5s ease-out, color 0.5s ease-out, background-color 0.5s ease-out, box-shadow 0.5s ease-out;
    transition: opacity 0.16s ease, text-shadow 0.5s ease-out, color 0.5s ease-out, background-color 0.5s ease-out, box-shadow 0.5s ease-out;
  }
  .live-editor-canvas.focus-mode-active > *.active-focus-block {
    opacity: 1.0 !important;
    -webkit-transition: opacity 0.16s ease, text-shadow 0.9s ease-out, color 0.9s ease-out, background-color 0.9s ease-out, box-shadow 0.9s ease-out;
    transition: opacity 0.16s ease, text-shadow 0.9s ease-out, color 0.9s ease-out, background-color 0.9s ease-out, box-shadow 0.9s ease-out;
  }
  .live-editor-canvas.focus-mode-active.typing-now > *.active-focus-block {
    -webkit-transition-duration: 0.08s;
    transition-duration: 0.08s;
  }

  /* 다크 테마: 하얀 네온 */
  body.theme-dark .live-editor-canvas.focus-mode-active > *.active-focus-block {
    color: #f3f6ff;
    text-shadow: 0 0 5px rgba(255, 255, 255, 0.38), 0 0 14px rgba(190, 215, 255, 0.20);
  }
  body.theme-dark .live-editor-canvas.focus-mode-active.typing-now > *.active-focus-block {
    color: #ffffff;
    text-shadow: 0 0 2px rgba(255, 255, 255, 0.95), 0 0 7px rgba(255, 255, 255, 0.85),
                 0 0 16px rgba(220, 235, 255, 0.70), 0 0 30px rgba(170, 205, 255, 0.45),
                 0 0 54px rgba(140, 185, 255, 0.25);
  }

  /* 라이트 테마: 스탠드 불빛 + 붉은 잉크 번짐 (흰 종이에서는 하얀 네온이 보이지 않으므로) */
  body.theme-light .live-editor-canvas.focus-mode-active > *.active-focus-block {
    color: #17110f;
    background-color: rgba(255, 214, 102, 0.12);
    box-shadow: 0 0 0 5px rgba(255, 214, 102, 0.12);
    border-radius: 2px;
    text-shadow: 0 0 1px rgba(60, 10, 10, 0.25);
  }
  body.theme-light .live-editor-canvas.focus-mode-active.typing-now > *.active-focus-block {
    color: #0c0605;
    background-color: rgba(255, 207, 77, 0.30);
    box-shadow: 0 0 0 5px rgba(255, 207, 77, 0.30), 0 0 22px 8px rgba(255, 190, 60, 0.28);
    text-shadow: 0 0 1px rgba(40, 0, 0, 0.55), 0 0 9px rgba(200, 30, 30, 0.42), 0 0 20px rgba(226, 110, 30, 0.30);
  }

  /* 시그니처 기능 5: 클래식 타자기 폰트 모드 (Courier / AppleMyungjo) */
  .live-editor-canvas.style-typewriter {
    font-family: "Courier New", "Courier", "AppleMyungjo", "NanumMyeongjo", monospace !important;
    letter-spacing: 0.4px;
    line-height: 1.95;
  }

  /* 시그니처 기능 5: 원고지(줄) 모드 — v2.1 줄 맞춤 수정
     예전에는 위쪽 여백(18px)이 줄 간격(36px)의 절반이라 붉은 줄이 글자 한가운데를 지나갔고,
     제목·목록·인용·코드·구분선의 높이도 제각각이라 아래로 갈수록 더 어긋났습니다.
     이제 위 여백을 정확히 한 줄(36px)로 두고, 모든 블록의 줄 높이·여백을 36px 배수로 고정합니다. */
  .live-editor-canvas.style-manuscript {
    font-family: "AppleMyungjo", "NanumMyeongjo", "Batang", serif !important;
    font-size: 17px;
    letter-spacing: 1.5px;
    line-height: 36px;
    padding: 36px 26px;
    border: 2px solid rgba(217, 43, 43, 0.45);
    border-radius: 4px;
    -webkit-background-origin: padding-box;
    background-origin: padding-box;
    background-position: 0 0;
    background-repeat: repeat;
    -webkit-background-size: 100% 36px;
    background-size: 100% 36px;
    background-image: -webkit-linear-gradient(top, transparent 35px, rgba(217, 43, 43, 0.32) 35px, rgba(217, 43, 43, 0.32) 36px);
    background-image: linear-gradient(to bottom, transparent 35px, rgba(217, 43, 43, 0.32) 35px, rgba(217, 43, 43, 0.32) 36px);
  }
  .live-editor-canvas.style-manuscript p,
  .live-editor-canvas.style-manuscript div,
  .live-editor-canvas.style-manuscript h1,
  .live-editor-canvas.style-manuscript h2,
  .live-editor-canvas.style-manuscript h3,
  .live-editor-canvas.style-manuscript h4,
  .live-editor-canvas.style-manuscript h5,
  .live-editor-canvas.style-manuscript h6,
  .live-editor-canvas.style-manuscript ul,
  .live-editor-canvas.style-manuscript ol,
  .live-editor-canvas.style-manuscript li,
  .live-editor-canvas.style-manuscript blockquote,
  .live-editor-canvas.style-manuscript pre {
    line-height: 36px;
    min-height: 36px;
    margin-top: 0;
    margin-bottom: 0;
    padding-top: 0;
    padding-bottom: 0;
    border-top: 0;
    border-bottom: 0;
  }
  .live-editor-canvas.style-manuscript h1 { font-size: 1.45em; }
  .live-editor-canvas.style-manuscript h2 { font-size: 1.28em; }
  .live-editor-canvas.style-manuscript h3 { font-size: 1.14em; }
  .live-editor-canvas.style-manuscript h4,
  .live-editor-canvas.style-manuscript h5,
  .live-editor-canvas.style-manuscript h6 { font-size: 1em; }
  .live-editor-canvas.style-manuscript pre {
    border: 0;
    border-radius: 0;
    font-size: 13px;
    background-color: rgba(217, 43, 43, 0.07) !important;
  }
  .live-editor-canvas.style-manuscript hr {
    height: 36px;
    margin: 0;
    border: 0;
    background-image: -webkit-linear-gradient(top, transparent 17px, rgba(217, 43, 43, 0.60) 17px, rgba(217, 43, 43, 0.60) 19px, transparent 19px);
    background-image: linear-gradient(to bottom, transparent 17px, rgba(217, 43, 43, 0.60) 17px, rgba(217, 43, 43, 0.60) 19px, transparent 19px);
  }
  /* 글줄 안의 굵게·코드·링크 등이 줄 높이를 1~2px 밀어 올려 줄이 어긋나는 것을 방지 */
  .live-editor-canvas.style-manuscript strong,
  .live-editor-canvas.style-manuscript b,
  .live-editor-canvas.style-manuscript em,
  .live-editor-canvas.style-manuscript i,
  .live-editor-canvas.style-manuscript del,
  .live-editor-canvas.style-manuscript s,
  .live-editor-canvas.style-manuscript strike,
  .live-editor-canvas.style-manuscript code,
  .live-editor-canvas.style-manuscript a,
  .live-editor-canvas.style-manuscript span {
    line-height: 1;
  }

  /* ==========================================================================
     v2.1 원고지(칸) 모드: 20×20 칸에 한 글자씩 쓰는 원고지
     - .ms-row 하나가 [줄 사이 여백 띠 + 20칸 글줄(.ms-cells)] 입니다. 줄들은 #gridPaper 의 형제 요소이고,
       20줄(400칸)마다 장(張) 테두리와 꼬리말을 CSS(nth-child)로 그립니다.
     - 칸 크기는 창 너비에 맞춰 스크립트가 #gridDynStyle 에 정수 px 로 기록합니다.
     ========================================================================== */
  .ms-surface { position: relative; margin: 0 auto; display: none; }
  .ms-input {
    position: absolute; top: 0; left: 0; width: 20px; height: 20px;
    margin: 0; padding: 0; border: 0; outline: none; resize: none; overflow: hidden;
    opacity: 0; background: transparent; color: transparent;
    font-size: 16px; line-height: 20px; white-space: pre;
    pointer-events: none; z-index: 0;
    -webkit-appearance: none;
  }
  .ms-grid {
    font-size: 36px; line-height: 1; cursor: text;
    font-family: "AppleMyungjo", "NanumMyeongjo", "Batang", serif;
    -webkit-user-select: none; user-select: none;
  }
  .ms-row {
    position: relative;
    -webkit-box-sizing: content-box; box-sizing: content-box;
    border-left: 1px solid; border-right: 1px solid;
  }
  /* 한 장(20줄 = 400칸)의 첫 줄: 위 테두리. 그 위 여백에 머리말(제목)이 놓입니다 */
  .ms-row:nth-child(20n+1) { border-top: 1px solid; margin-top: 72px; }
  .ms-row:first-child { margin-top: 40px; }
  /* 한 장의 마지막 줄: 아래 테두리 + 꼬리말(왼쪽 "20×20", 가운데 쪽 번호, 오른쪽 "©TypeGrapher") */
  .ms-row:nth-child(20n) { border-bottom: 1px solid; margin-bottom: 24px; }
  /* 꼬리말 가운데의 쪽 번호 "- 1 -": 스크립트가 각 장의 마지막 줄 요소 안에 붙이는 실제 글자 요소 */
  .ms-foot-no {
    position: absolute; left: 0; right: 0; bottom: -20px; height: 20px; text-align: center; white-space: nowrap;
    font: 10px/20px "Helvetica Neue", Arial, sans-serif; letter-spacing: 0.5px;
    pointer-events: none; cursor: default;
  }
  .ms-row:nth-child(20n):after {
    content: "20×20";
    position: absolute; left: 0; bottom: -20px;
    font: 10px/20px "Helvetica Neue", Arial, sans-serif; letter-spacing: 0.5px;
  }
  .ms-row:nth-child(20n):before {
    content: "©TypeGrapher";
    position: absolute; right: 0; bottom: -20px;
    font: 10px/20px "Helvetica Neue", Arial, sans-serif; letter-spacing: 0.5px;
  }

  /* 머리말: 왼쪽 위 제목(글자 길이만큼 붉은 밑줄이 늘어남). 오른쪽 위는 비워 두고, 조판(인쇄 · PDF)에서
     자동 표기를 켰을 때만 날짜가 들어갑니다. 각 장 첫 줄 요소 안에 붙어 있어서 줄과 함께 움직입니다. */
  .ms-head {
    position: absolute; left: -1px; right: -1px; bottom: 100%; margin-bottom: 6px; height: 30px;
    pointer-events: none; cursor: default;
  }
  .ms-head input {
    pointer-events: auto;
    -webkit-appearance: none; -webkit-box-sizing: border-box; box-sizing: border-box;
    -webkit-user-select: text; user-select: text;
    margin: 0; padding: 0 4px; height: 28px; line-height: 27px;
    background: transparent; color: inherit; outline: none;
    border: 0; border-bottom: 1px solid; border-radius: 0;
    font-family: "AppleMyungjo", "NanumMyeongjo", "Batang", serif;
    cursor: text;
  }
  .ms-head input:focus { border-bottom-color: #e03131 !important; }
  .ms-title { position: absolute; left: 0; bottom: 0; font-size: 16px; }
  .ms-date {
    display: none; position: absolute; right: 2px; bottom: 0; height: 28px; line-height: 27px; white-space: nowrap;
    font-family: "AppleMyungjo", "NanumMyeongjo", "Batang", serif; font-size: 13px;
  }
  .ms-title-measure {
    position: absolute; left: -9999px; top: 0; visibility: hidden; white-space: pre;
    font-family: "AppleMyungjo", "NanumMyeongjo", "Batang", serif; font-size: 16px;
  }
  .ms-row .c {
    float: left; position: relative;
    -webkit-box-sizing: border-box; box-sizing: border-box;
    border-top: 1px solid; border-bottom: 1px solid; border-left: 1px solid;
    text-align: center; white-space: pre;
  }
  .ms-row .c:first-child { border-left: 0; }
  /* 숫자·영문 소문자는 한 칸에 두 자 */
  .ms-row .c.h i { display: block; margin-left: 50%; font-style: normal; font-size: 0.84em; }
  .ms-row .c.h i:first-child { float: left; width: 50%; margin-left: 0; }
  /* 마침표·쉼표는 칸의 왼쪽 아래 */
  .ms-row .c.pl { text-align: left; text-indent: 0.18em; }

  body.theme-dark .ms-grid { color: #e8e4dc; }
  body.theme-dark .ms-row { background-color: #201c1c; border-color: rgba(226, 78, 78, 0.66); }
  body.theme-dark .ms-row .c { border-color: rgba(226, 78, 78, 0.52); }
  body.theme-dark .ms-row:before,
  body.theme-dark .ms-row:after,
  body.theme-dark .ms-foot-no { color: rgba(240, 120, 120, 0.85); }
  body.theme-dark .ms-head input { border-bottom-color: rgba(226, 78, 78, 0.70); }
  body.theme-dark .ms-head input::-webkit-input-placeholder { color: rgba(232, 228, 220, 0.30); }

  body.theme-light .ms-grid { color: #2a2420; }
  body.theme-light .ms-row { background-color: #fdf7ee; border-color: rgba(205, 92, 92, 0.80); }
  body.theme-light .ms-row .c { border-color: rgba(214, 110, 110, 0.62); }
  body.theme-light .ms-row:before,
  body.theme-light .ms-row:after,
  body.theme-light .ms-foot-no { color: rgba(190, 70, 70, 0.95); }
  body.theme-light .ms-head input { border-bottom-color: rgba(205, 92, 92, 0.85); }
  body.theme-light .ms-head input::-webkit-input-placeholder { color: rgba(42, 36, 32, 0.32); }

  /* 커서(현재 칸) · 선택 · 한글 조합 중 표시 */
  .ms-caret { position: absolute; left: 0; display: none; pointer-events: none; }
  .ms-grid.focused .ms-caret { display: block; background-color: rgba(217, 43, 43, 0.15); }
  .ms-grid.focused .ms-caret.end { background-color: transparent; }
  .ms-caret:after {
    content: ""; position: absolute; top: 12%; bottom: 12%; left: 1px; width: 2px;
    background-color: #e03131;
    -webkit-animation: msCaretBlink 1.06s steps(1, end) infinite;
    animation: msCaretBlink 1.06s steps(1, end) infinite;
  }
  .ms-caret.mid:after { left: 50%; margin-left: -1px; }
  .ms-caret.end:after { left: auto; right: 1px; }
  @-webkit-keyframes msCaretBlink { 0% { opacity: 1; } 50% { opacity: 0; } 100% { opacity: 1; } }
  @keyframes msCaretBlink { 0% { opacity: 1; } 50% { opacity: 0; } 100% { opacity: 1; } }
  .ms-row .c.sel,
  .ms-row .c.h i.sel { background-color: rgba(217, 43, 43, 0.30); }
  .ms-row .c.cmp { box-shadow: inset 0 -2px 0 #e03131; }

  /* 원고지(칸) 집중 모드: 작성 중인 문단만 밝게 + 글로우 */
  .ms-grid.focus-on .ms-row,
  .ms-grid.focus-on .ms-row .c {
    -webkit-transition: color 0.9s ease-out, text-shadow 0.9s ease-out, background-color 0.9s ease-out;
    transition: color 0.9s ease-out, text-shadow 0.9s ease-out, background-color 0.9s ease-out;
  }
  .ms-grid.focus-on.typing-now .ms-row.act,
  .ms-grid.focus-on.typing-now .ms-row.act .c {
    -webkit-transition-duration: 0.08s;
    transition-duration: 0.08s;
  }
  body.theme-dark .ms-grid.focus-on .ms-row .c { color: rgba(232, 228, 220, 0.28); }
  body.theme-dark .ms-grid.focus-on .ms-row.act .c {
    color: #f3f6ff;
    text-shadow: 0 0 5px rgba(255, 255, 255, 0.38), 0 0 14px rgba(190, 215, 255, 0.20);
  }
  body.theme-dark .ms-grid.focus-on.typing-now .ms-row.act .c {
    color: #ffffff;
    text-shadow: 0 0 2px rgba(255, 255, 255, 0.95), 0 0 7px rgba(255, 255, 255, 0.85),
                 0 0 16px rgba(220, 235, 255, 0.70), 0 0 30px rgba(170, 205, 255, 0.45);
  }
  body.theme-light .ms-grid.focus-on .ms-row .c { color: rgba(42, 36, 32, 0.28); }
  body.theme-light .ms-grid.focus-on .ms-row.act { background-color: #fdeebd; }
  body.theme-light .ms-grid.focus-on .ms-row.act .c {
    color: #17110f;
    text-shadow: 0 0 1px rgba(60, 10, 10, 0.25);
  }
  body.theme-light .ms-grid.focus-on.typing-now .ms-row.act { background-color: #fde39a; }
  body.theme-light .ms-grid.focus-on.typing-now .ms-row.act .c {
    color: #0c0605;
    text-shadow: 0 0 1px rgba(40, 0, 0, 0.55), 0 0 9px rgba(200, 30, 30, 0.42), 0 0 20px rgba(226, 110, 30, 0.30);
  }

  .live-editor-canvas h1, .live-editor-canvas h2, .live-editor-canvas h3,
  .live-editor-canvas h4, .live-editor-canvas h5, .live-editor-canvas h6 {
    margin-top: 0.9em; margin-bottom: 0.35em; font-weight: 700; line-height: 1.35;
  }
  .live-editor-canvas h1:first-child, .live-editor-canvas h2:first-child { margin-top: 0; }
  .live-editor-canvas h1 { font-size: 1.9em; padding-bottom: 0.22em; border-bottom: 2px solid rgba(217, 43, 43, 0.38); }
  .live-editor-canvas h2 { font-size: 1.5em; padding-bottom: 0.18em; border-bottom: 1px solid rgba(217, 43, 43, 0.22); }
  .live-editor-canvas h3 { font-size: 1.25em; color: #f06565; }
  body.theme-light .live-editor-canvas h3 { color: #b91c1c; }

  .live-editor-canvas p, .live-editor-canvas div { min-height: 1.75em; margin-bottom: 0.25em; line-height: 1.8; }
  .live-editor-canvas ul, .live-editor-canvas ol { margin: 0.35em 0 0.65em 0; padding-left: 26px; }
  .live-editor-canvas li { margin-bottom: 4px; line-height: 1.75; }

  .live-editor-canvas blockquote {
    border-left: 4px solid #d92b2b; padding: 8px 16px; margin: 0.5em 0;
    background-color: rgba(217, 43, 43, 0.08); border-radius: 0 5px 5px 0;
  }

  .live-editor-canvas code {
    font-family: "Menlo", "Monaco", "Consolas", monospace; font-size: 0.9em;
    padding: 2px 6px; border-radius: 4px;
    background-color: rgba(217, 43, 43, 0.14); color: #ff7b7b;
  }
  body.theme-light .live-editor-canvas code { color: #b91c1c; background-color: #f9ebeb; }

  .live-editor-canvas pre {
    background-color: #141414; color: #e2e0dc; padding: 14px 18px;
    border-radius: 6px; overflow-x: auto; margin: 0.7em 0;
    border: 1px solid #332a2a;
    font-family: "Menlo", "Monaco", "Consolas", monospace;
    font-size: 13px; line-height: 1.6; white-space: pre-wrap;
  }
  body.theme-light .live-editor-canvas pre { background-color: #f3efe9; color: #262422; border-color: #dcd5ca; }
  .live-editor-canvas pre code { background: transparent; color: inherit; padding: 0; }

  .live-editor-canvas hr { border: none; border-top: 1px solid rgba(217, 43, 43, 0.35); margin: 20px 0; }
  .live-editor-canvas a { color: #e03131; text-decoration: underline; cursor: pointer; }
  body.theme-light .live-editor-canvas a { color: #c81e1e; }

  .live-editor-canvas .wiki-tag {
    color: #ff8080; background-color: rgba(217, 43, 43, 0.16);
    padding: 2px 7px; border-radius: 4px; font-size: 0.94em; font-weight: 600;
    cursor: pointer; border: 1px solid rgba(217, 43, 43, 0.32);
  }
  body.theme-light .live-editor-canvas .wiki-tag {
    color: #b91c1c; background-color: rgba(200, 30, 30, 0.12); border-color: rgba(200, 30, 30, 0.28);
  }
  .live-editor-canvas .wiki-tag:hover { background-color: rgba(217, 43, 43, 0.28); }

  .live-editor-canvas .task-item { list-style: none; margin-left: -22px; }
  .live-editor-canvas .task-item input[type="checkbox"] {
    margin-right: 8px; vertical-align: middle; cursor: pointer; accent-color: #d92b2b;
  }
  .live-editor-canvas .task-done { text-decoration: line-through; opacity: 0.6; }

  .statusbar {
    position: absolute; bottom: 0; left: 0; right: 0; height: 26px;
    padding: 0 14px; font-size: 11px;
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
    -webkit-box-pack: justify; -webkit-justify-content: space-between; justify-content: space-between;
    -webkit-user-select: none; user-select: none;
  }
  .status-dot { color: #e03131; margin-right: 4px; }
  .status-right span { margin-left: 14px; }

  .btn { padding: 5px 10px; border-radius: 4px; font-size: 12px; cursor: pointer; outline: none; white-space: nowrap; }

  /* Modals */
  .modal-backdrop {
    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background-color: rgba(0, 0, 0, 0.62); display: none;
    -webkit-box-align: center; -webkit-align-items: center; align-items: center;
    -webkit-box-pack: center; -webkit-justify-content: center; justify-content: center;
    z-index: 9999;
  }
  .modal-backdrop.show { display: -webkit-box; display: -webkit-flex; display: flex; }
  .modal-box {
    width: 90%; max-width: 440px; padding: 20px;
    border-radius: 8px; box-shadow: 0 10px 25px rgba(0,0,0,0.5);
  }
  .modal-box.stats-modal-wide { max-width: 560px; }
  .modal-title { font-size: 16px; font-weight: 700; margin-bottom: 10px; color: #e03131; }
  body.theme-light .modal-title { color: #c81e1e; }
  .modal-desc { font-size: 13px; margin-bottom: 14px; line-height: 1.5; white-space: pre-line; }
  .modal-input { width: 100%; padding: 8px 10px; border-radius: 4px; font-size: 13px; margin-bottom: 16px; outline: none; display: none; }
  .modal-actions {
    display: -webkit-box; display: -webkit-flex; display: flex;
    -webkit-box-pack: end; -webkit-justify-content: flex-end; justify-content: flex-end;
  }
  .modal-actions .btn { margin-left: 8px; }

  /* 시그니처 기능 4: 타자기 천공 카드(Punch-Card) 월간 히트맵 스타일 */
  .stats-summary-grid {
    display: -webkit-box; display: -webkit-flex; display: flex;
    margin-bottom: 16px;
  }
  .stat-card {
    -webkit-box-flex: 1; -webkit-flex: 1; flex: 1;
    padding: 10px 8px; margin-right: 8px; border-radius: 6px;
    background: rgba(217, 43, 43, 0.1); border: 1px solid rgba(217, 43, 43, 0.25);
    text-align: center;
  }
  .stat-card:last-child { margin-right: 0; }
  .stat-card-val { font-size: 18px; font-weight: 800; color: #e03131; }
  body.theme-light .stat-card-val { color: #c81e1e; }
  .stat-card-lbl { font-size: 11px; opacity: 0.78; margin-top: 2px; }

  .heatmap-table { width: 100%; border-collapse: separate; border-spacing: 4px; margin-bottom: 14px; }
  .heatmap-table th { font-size: 11px; opacity: 0.7; padding-bottom: 4px; text-align: center; }
  .heatmap-cell {
    height: 36px; border-radius: 5px; text-align: center; vertical-align: middle;
    font-size: 11px; font-weight: 600; cursor: pointer;
    border: 1px solid rgba(128,128,128,0.18);
  }
  .heatmap-cell:hover { outline: 2px solid #e03131; }
  .heat-lv0 { background: rgba(128, 128, 128, 0.08); opacity: 0.65; }
  .heat-lv1 { background: rgba(217, 43, 43, 0.25); color: #ffffff; }
  .heat-lv2 { background: rgba(217, 43, 43, 0.50); color: #ffffff; }
  .heat-lv3 { background: rgba(217, 43, 43, 0.78); color: #ffffff; }
  .heat-lv4 { background: #d92b2b; color: #ffffff; font-weight: 800; }
  body.theme-light .heat-lv1 { color: #7f1d1d; }

  /* Print Stylesheet for Native Print / PDF Export */
  /* ==========================================================================
     조판(인쇄 · PDF) 레이아웃 (v2.3 도입, v2.4 수정)
     인쇄/PDF 를 만드는 순간에만 <html> 에 tg-print-root 클래스가 붙습니다.
     화면용 틀(사이드바·스크롤 영역)을 걷어 내고 내용만 왼쪽 위에 펼친 뒤, 앱이 원고지 한 장
     (또는 본문 한 쪽) 단위로 벡터 PDF 를 떠서 용지 크기에 맞춰 배치합니다.

     [중요] 이 구역의 규칙은 @media 로 감싸지 않습니다. WebView 는 PDF 로 그릴 때 문서를
     '인쇄 매체'로 바꿔 다시 배치하므로, 화면 매체와 인쇄 매체에서 배치가 한 치도 달라지면 안 됩니다.
     (v2.3 에서는 아래쪽 대체 경로용 @media print 규칙이 이때 끼어들어 원고지 칸 크기를 바꿨습니다.)
     ========================================================================== */
  html.tg-print-root,
  html.tg-print-root body {
    width: auto !important; height: auto !important; overflow: visible !important; background: #ffffff !important;
  }
  html.tg-print-root .app-shell { position: static !important; width: auto !important; height: auto !important; }
  html.tg-print-root .ribbon,
  html.tg-print-root .sidebar,
  html.tg-print-root .sidebar-resizer,
  html.tg-print-root .topbar,
  html.tg-print-root .toolbar,
  html.tg-print-root .statusbar,
  html.tg-print-root .modal-backdrop { display: none !important; }
  html.tg-print-root .main-body,
  html.tg-print-root .workspace,
  html.tg-print-root .live-editor-scroll {
    position: static !important; display: block !important; overflow: visible !important;
    width: auto !important; height: auto !important; margin: 0 !important; padding: 0 !important;
    background: #ffffff !important; color: #111111 !important;
  }
  /* 내용이 문서 가장자리에 붙지 않게(캡처 여유) */
  html.tg-print-root .live-editor-scroll { padding: 16px !important; }

  /* 일반 노트(기본 · 타자기체 · 원고지 줄): 고정 폭으로 다시 흘린 뒤 쪽 단위로 자른다 */
  html.tg-print-root .live-editor-canvas {
    width: 660px !important; max-width: none !important; min-height: 0 !important; margin: 0 !important;
    color: #111111 !important; background-color: #ffffff;
  }
  html.tg-print-root .live-editor-canvas pre { white-space: pre-wrap !important; word-wrap: break-word !important; }
  html.tg-print-root .live-editor-canvas img { max-width: 100% !important; }

  /* 원고지(칸): 흰 종이 · 검은 글씨 · 또렷한 붉은 줄 */
  html.tg-print-root .ms-surface { margin: 0 !important; }
  html.tg-print-root .ms-input,
  html.tg-print-root .ms-caret { display: none !important; }
  html.tg-print-root .ms-grid { color: #000000 !important; }
  html.tg-print-root .ms-row { background-color: #ffffff !important; border-color: #d94a4a !important; }
  html.tg-print-root .ms-row .c {
    color: #000000 !important; text-shadow: none !important; box-shadow: none !important;
    background: transparent !important; border-color: #e07070 !important;
  }
  html.tg-print-root .ms-row .c.h i { background: transparent !important; }
  html.tg-print-root .ms-row:before,
  html.tg-print-root .ms-row:after,
  html.tg-print-root .ms-foot-no,
  html.tg-print-root .ms-pad-label { color: #c93a3a !important; }
  /* 자동 표기의 날짜: 머리말 오른쪽 위 (글자가 채워졌을 때만 보임) */
  html.tg-print-root .ms-date { display: block !important; color: #444444 !important; }
  html.tg-print-root .ms-head input,
  html.tg-print-root .ms-blank-line { color: #000000 !important; border-bottom-color: #d94a4a !important; }
  html.tg-print-root .ms-head input::-webkit-input-placeholder { color: transparent !important; }

  /* 흑백(먹색) 잉크: 레이저 프린터용. 줄과 표시를 모두 먹색으로 */
  html.tg-print-mono .ms-row { border-color: #222222 !important; }
  html.tg-print-mono .ms-row .c { border-color: #555555 !important; }
  html.tg-print-mono .ms-row:before,
  html.tg-print-mono .ms-row:after,
  html.tg-print-mono .ms-foot-no,
  html.tg-print-mono .ms-pad-label { color: #222222 !important; }
  html.tg-print-mono .ms-date { color: #222222 !important; }
  html.tg-print-mono .ms-head input,
  html.tg-print-mono .ms-blank-line { border-bottom-color: #222222 !important; }
  html.tg-print-mono .live-editor-canvas,
  html.tg-print-mono .live-editor-canvas * { color: #111111 !important; border-color: #555555 !important; }
  html.tg-print-mono .live-editor-canvas pre,
  html.tg-print-mono .live-editor-canvas code,
  html.tg-print-mono .live-editor-canvas blockquote,
  html.tg-print-mono .live-editor-canvas .wiki-tag { background-color: #f1f1f1 !important; }
  html.tg-print-mono .live-editor-canvas.style-manuscript {
    border-color: #333333 !important;
    background-image: -webkit-linear-gradient(top, transparent 35px, #8a8a8a 35px, #8a8a8a 36px) !important;
    background-image: linear-gradient(to bottom, transparent 35px, #8a8a8a 35px, #8a8a8a 36px) !important;
  }
  html.tg-print-mono .live-editor-canvas.style-manuscript hr {
    background-image: -webkit-linear-gradient(top, transparent 17px, #444444 17px, #444444 19px, transparent 19px) !important;
    background-image: linear-gradient(to bottom, transparent 17px, #444444 17px, #444444 19px, transparent 19px) !important;
  }

  /* 빈 원고지 양식(손글씨 · 수동 타자기용): 조판할 때만 만들어지는 별도 원고지 */
  .ms-pad-surface { display: none !important; }
  html.tg-print-pad .ms-pad-surface { display: block !important; }
  html.tg-print-pad #gridSurface,
  html.tg-print-pad #liveEditor { display: none !important; }
  .ms-blank-line {
    display: inline-block; height: 28px; line-height: 27px; padding: 0 4px;
    -webkit-box-sizing: border-box; box-sizing: border-box;
    border-bottom: 1px solid; vertical-align: bottom; text-align: left;
    font-family: "AppleMyungjo", "NanumMyeongjo", "Batang", serif; font-size: 14px;
  }
  .ms-pad-title { position: absolute; left: 0; bottom: 0; height: 28px; line-height: 28px; font-size: 14px; white-space: nowrap; }
  .ms-pad-title .ms-blank-line { width: 230px; }
  .ms-pad-label { font: 12px "Helvetica Neue", Arial, sans-serif; letter-spacing: 0.5px; margin-right: 2px; }

  /* 자동 표기(제목 · 날짜 · 쪽 번호) 띠: 일반 노트를 조판할 때만 본문 아래에 만들어 조각으로 떠 간다
     (원고지는 띠를 쓰지 않는다: 제목 · 날짜 · 쪽 번호가 모두 원고지 한 장 안에 들어 있다) */
  .tg-stamp-box { display: none; }
  html.tg-print-root .tg-stamp-box { display: block; margin-top: 48px; }
  .tg-stamp {
    position: relative; height: 18px; line-height: 18px; overflow: hidden; white-space: nowrap;
    font-family: "AppleMyungjo", "NanumMyeongjo", "Batang", serif; font-size: 12px; color: #444444;
    margin-bottom: 6px;
  }
  .tg-stamp .sl { position: absolute; left: 0; top: 0; }
  .tg-stamp .sr { position: absolute; right: 0; top: 0; }
  .tg-stamp .sc { display: block; text-align: center; }

  /* 배치 검증용 표식: 문서 맨 끝에 놓이는 12×12 검은 네모(테두리만으로 그려서 배경 인쇄 설정과 무관).
     스크립트가 잰 자리에서 네이티브가 떠 보았을 때 이 네모가 보이지 않으면, 캡처하는 동안 배치가
     달라졌다는 뜻이므로 사용자에게 알린다. */
  .tg-probe { display: none; }
  html.tg-print-root .tg-probe {
    display: block !important; width: 0 !important; height: 0 !important; margin: 24px 0 0 0 !important; padding: 0 !important;
    border: 6px solid #000000 !important; background: #000000 !important;
  }

  /* 조판 설정 창 */
  .print-modal { max-width: 470px !important; }
  .print-opt-row { margin-bottom: 12px; font-size: 13px; line-height: 1.9; }
  .print-opt-label { display: inline-block; min-width: 82px; font-weight: 700; }
  .print-opt-row label { margin-right: 12px; white-space: nowrap; cursor: pointer; }
  .print-opt-row input[type="number"] { width: 52px; padding: 2px 4px; font-size: 13px; }
  .print-opt-row select { font-size: 13px; padding: 2px 4px; }
  .print-opt-hint { font-size: 12px; opacity: 0.75; margin: 4px 0 14px 0; line-height: 1.6; white-space: pre-line; }

  /* ==========================================================================
     대체 경로(기존 인쇄 방식) 전용 규칙: 새 조판 엔진을 쓸 수 없을 때 WebKit 인쇄 기능이 쓰는 배치.
     새 엔진이 조판하는 동안(html.tg-print-root)에는 단 하나도 적용되지 않도록 모든 선택자를
     html:not(.tg-print-root) 로 묶었습니다.
     ========================================================================== */
  @page { margin: 12mm; }
  @media print {
    html:not(.tg-print-root),
    html:not(.tg-print-root) body { width: auto !important; height: auto !important; overflow: visible !important; }
    html:not(.tg-print-root) .app-shell { position: static !important; width: auto !important; height: auto !important; }
    html:not(.tg-print-root) .ribbon,
    html:not(.tg-print-root) .sidebar,
    html:not(.tg-print-root) .sidebar-resizer,
    html:not(.tg-print-root) .topbar,
    html:not(.tg-print-root) .toolbar,
    html:not(.tg-print-root) .statusbar,
    html:not(.tg-print-root) .modal-backdrop { display: none !important; }
    html:not(.tg-print-root) .main-body,
    html:not(.tg-print-root) .workspace,
    html:not(.tg-print-root) .live-editor-scroll {
      position: static !important; overflow: visible !important;
      padding: 0 !important; background: #ffffff !important; color: #000000 !important;
    }
    html:not(.tg-print-root) .live-editor-canvas { max-width: 100% !important; color: #000000 !important; }
    html:not(.tg-print-root) .live-editor-canvas.focus-mode-active > * {
      opacity: 1.0 !important; text-shadow: none !important;
      background-color: transparent !important; box-shadow: none !important;
    }
    /* 원고지(칸): A4/Letter 세로에 20칸이 들어가도록 24px 칸으로 고정, 원고지 한 장 = 종이 한 장 */
    html:not(.tg-print-root) .ms-input { display: none !important; }
    html:not(.tg-print-root) .ms-surface { width: 482px !important; margin: 0 auto !important; }
    html:not(.tg-print-root) #gridPaper { font-size: 24px !important; }
    html:not(.tg-print-root) #gridPaper .ms-row { height: 24px !important; padding-top: 7px !important; background: #ffffff !important; page-break-inside: avoid; }
    html:not(.tg-print-root) #gridPaper .ms-row:nth-child(20n) { padding-bottom: 7px !important; page-break-after: always; }
    html:not(.tg-print-root) #gridPaper .c {
      width: 24px !important; height: 24px !important; line-height: 22px !important; font-size: 15px !important;
      color: #000000 !important; text-shadow: none !important; background: transparent !important;
    }
    html:not(.tg-print-root) .ms-caret { display: none !important; }
    html:not(.tg-print-root) .ms-head input { color: #000000 !important; }
    html:not(.tg-print-root) .ms-head input::-webkit-input-placeholder { color: transparent !important; }
  }
</style>
<style id="gridDynStyle"></style>
</head>
<body class="theme-dark">

<div class="app-shell">
  <div class="main-body">
    <!-- Left Icon Ribbon (5대 시그니처 토글 탑재) -->
    <div class="ribbon">
      <button class="ribbon-btn" id="btnToggleSidebar" title="사이드바 접기/펼치기 (Cmd + \)">&#9776;</button>
      <button class="ribbon-btn" id="btnRibbonNew" title="새 마크다운 노트 하단 추가 (Cmd + N)">&#65291;</button>
      <button class="ribbon-btn" id="btnRibbonDaily" title="오늘 일기 열기/하단 생성 (Cmd + D)">&#128197;</button>
      <button class="ribbon-btn" id="btnZenMode" title="방해 금지 타자기 모드 (Zen Mode)">&#9673;</button>
      <button class="ribbon-btn active-ribbon" id="btnToggleSound" title="[시그니처 1] 타건음(활자·스페이스 소리) 켜기/끄기">&#128266;</button>
      <button class="ribbon-btn active-ribbon" id="btnToggleBell" title="[시그니처 1] 엔터(줄바꿈) 벨소리 켜기/끄기">&#128276;</button>
      <button class="ribbon-btn" id="btnToggleFocusMode" title="[시그니처 2] 타자기 롤러 중앙 고정 스크롤 & 문장 집중 조명 켜기/끄기">&#127919;</button>
      <button class="ribbon-btn" id="btnOpenStats" title="[시그니처 4] 타자기 천공 카드 월간 집필 히트맵 & 통계 (Cmd + G)">&#128202;</button>
      <div class="ribbon-spacer"></div>
      <button class="ribbon-btn" id="btnToggleTheme" title="다크 / 라이트 테마 전환 (Cmd + T)">&#9788;</button>
    </div>

    <!-- 1st Division: Left File Explorer Sidebar -->
    <div class="sidebar" id="sidebar">
      <div class="sidebar-header">
        <div class="vault-title" id="vaultHeaderBtn" title="클릭하여 보관함(Vault) 루트 폴더 변경 (Cmd + O)">
          <span id="vaultNameText">📕 TYPEGRAPHER ▾</span>
          <span id="noteCountBadge">0</span>
        </div>
        <input type="text" id="searchInput" class="search-input" placeholder="폴더 / 노트 제목 및 본문 검색...">
        <div class="sidebar-actions">
          <button class="btn btn-primary" id="btnNewNote" title="새 노트를 목록 맨 아래(하단)에 추가 (Cmd + N)">+ 새 노트</button>
          <button class="btn" id="btnDailyNote" title="오늘 날짜(YYYY년 MM월 DD일 (요일)) 빈 일기장 열기 (Cmd + D)">일기</button>
          <button class="btn" id="btnAddSubfolder" title="새 폴더를 목록 맨 아래(하단)에 추가">폴더</button>
          <button class="btn" id="btnDeleteItem" title="현재 선택된 파일 또는 폴더 삭제 (Cmd + Delete)">삭제</button>
        </div>
      </div>
      <div class="active-folder-bar" id="activeFolderBar" title="파일/폴더를 이 위로 드래그하거나 사이드바 빈 공간을 클릭하면 루트로 올라갑니다">
        <span class="active-folder-text" id="activeFolderLabel" title="클릭하면 최상위(루트) 폴더로 작성 위치를 초기화합니다">📍 위치: 기본 보관함 (루트)</span>
        <div class="bar-right-btns">
          <button class="mini-bar-btn" id="btnRootReset" title="작성 위치를 최상위(루트)로 초기화">루트로</button>
          <button class="mini-bar-btn" id="btnAutoSort" title="폴더 및 파일을 이름순/생성순으로 자동 정렬합니다 (이름순: 가나다, 이름 안의 숫자는 작은 수부터 — 9일 다음에 10일)">⇅ 자동 정렬</button>
        </div>
      </div>
      <ul class="note-list" id="noteList" title="항목을 우클릭(Control+클릭)하거나 길게 누르면 이름 바꾸기 · 삭제 · 새로고침 메뉴가 열립니다. 빈 공간을 클릭하면 루트 폴더로 올라갑니다"></ul>
    </div>

    <!-- 사이드바 우측 너비 조절 드래그 핸들 -->
    <div class="sidebar-resizer" id="sidebarResizer" title="드래그하여 사이드바 너비를 조절하세요"></div>

    <!-- 2nd Division: Unified Live Editor & Viewer Workspace -->
    <div class="workspace">
      <div class="topbar">
        <div class="title-wrapper">
          <span class="folder-tag-pill" id="currentNoteFolderBadge" style="display:none;">폴더</span>
          <input type="text" id="noteTitleInput" class="title-input" placeholder="노트 제목 (.md 파일명)...">
        </div>
        <div class="topbar-controls">
          <button class="btn" id="btnPrintNote" title="[시그니처 5] 인쇄 설정 창 열기: 용지 · 잉크 · 자동 표기 · 빈 원고지 양식을 고르고 인쇄합니다 (Cmd + P)">🖨️ 인쇄</button>
          <button class="btn" id="btnExportPDF" title="PDF 내보내기: 현재 노트를 바로 PDF 파일로 저장합니다 (인쇄 설정 창에서 고른 용지 · 잉크 · 자동 표기 그대로)">📄 PDF</button>
          <button class="btn" id="btnRefreshVault" title="파인더 폴더 및 파일 트리 새로고침">새로고침</button>
          <button class="btn btn-primary" id="btnRevealFinder" title="파인더의 [문서 - TypeGrapher] 폴더에서 현재 항목 보기">파인더에서 보기</button>
          <button class="btn" id="btnSyncVault" title="외부 폴더 / iCloud 보관함과 양방향 동기화 (rsync). 한쪽에서 지운 노트는 반대쪽에서도 지워집니다 (숨김 폴더 .typegrapher-trash 에 보관)">🔄 동기화</button>
        </div>
      </div>

      <div class="toolbar" id="formatToolbar">
        <button class="tool-btn" data-Action="h1" title="제목 1 (# + 스페이스바)">H1</button>
        <button class="tool-btn" data-Action="h2" title="제목 2 (## + 스페이스바)">H2</button>
        <button class="tool-btn" data-Action="h3" title="제목 3 (### + 스페이스바)">H3</button>
        <button class="tool-btn" data-Action="p" title="일반 본문 단락">본문</button>
        <div class="tool-sep"></div>
        <button class="tool-btn" data-Action="bold" title="굵게 (Cmd + B)"><b>B</b></button>
        <button class="tool-btn" data-Action="italic" title="기울임 (Cmd + I)"><i>I</i></button>
        <button class="tool-btn" data-Action="strike" title="취소선"><s>S</s></button>
        <div class="tool-sep"></div>
        <button class="tool-btn" data-Action="quote" title="인용구 (> + 스페이스바)">&ldquo; 인용</button>
        <button class="tool-btn" data-Action="ul" title="글머리 기호 목록 (- + 스페이스바)">&bull; 목록</button>
        <button class="tool-btn" data-Action="task" title="할 일 체크박스 (- [ ] + 스페이스바)">&#9745; 할일</button>
        <div class="tool-sep"></div>
        <button class="tool-btn" data-Action="code" title="코드 블록">&lt;/&gt; 코드</button>
        <button class="tool-btn" data-Action="wikilink" title="내부 문서 링크 [[노트제목]]">[[링크]]</button>
        <button class="tool-btn" data-Action="hr" title="구분선 삽입">&mdash; 구분선</button>
        <button class="tool-btn" data-Action="timestamp" title="현재 날짜 삽입">&#128337; 일시</button>
        <div class="tool-sep"></div>
        <!-- 시그니처 3, 2, 5 툴바 버튼 -->
        <button class="tool-btn" data-Action="bgm" title="[시그니처 3] 지금 재생 중인 음악(Music/iTunes)을 일기에 자동 각인 (Cmd + M)">&#9835; BGM</button>
        <button class="tool-btn" id="btnToolbarFocus" title="[시그니처 2] 타자기 롤러 중앙 고정 스크롤 & 문장 집중 조명">&#127919; 집중</button>
        <button class="tool-btn" id="btnNoBackspace" title="[시그니처 5] 수동 타자기처럼 지우기(Backspace) 키를 잠그는 무후회 초고 모드">&#128274; 무후회</button>
        <button class="tool-btn" id="btnPaperStyle" title="[시그니처 5] 기본 / 타자기체(Courier) / 원고지(줄) / 원고지(칸·20×20, 한 칸에 한 글자) 스타일 전환">&#128220; 스타일: 기본</button>
      </div>

      <!-- Single Unified Live Editor & Viewer Surface -->
      <div class="live-editor-scroll" id="editorScrollContainer">
        <div id="liveEditor" class="live-editor-canvas" contenteditable="true" spellcheck="false"></div>
        <!-- v2.1 원고지(칸) 모드: 보이지 않는 입력창 + 20×20 원고지 -->
        <div id="gridSurface" class="ms-surface">
          <textarea id="gridInput" class="ms-input" spellcheck="false" autocomplete="off" autocorrect="off" autocapitalize="off" wrap="off" tabindex="-1"></textarea>
          <div id="gridPaper" class="ms-grid"></div>
          <span id="gridTitleMeasure" class="ms-title-measure"></span>
        </div>
        <!-- 조판 전용: 빈 원고지 양식 / 자동 표기 띠 / 배치 검증용 표식 (인쇄 · PDF 를 만드는 순간에만 쓰임) -->
        <div id="printPadSurface" class="ms-surface ms-pad-surface"><div id="printPadPaper" class="ms-grid"></div></div>
        <div id="printStampBox" class="tg-stamp-box"></div>
        <div id="printProbe" class="tg-probe"></div>
      </div>
    </div>
  </div>

  <!-- Bottom Status Bar -->
  <div class="statusbar">
    <div class="status-left">
      <span class="status-dot">&#9679;</span>
      <span id="saveStatusText">TypeGrapher 준비 완료 (문서/TypeGrapher)</span>
    </div>
    <div class="status-right">
      <span id="statModeBadge">🔊 타건음 ON · 🔔 벨 ON</span>
      <span id="statLines">0 줄</span>
      <span id="statWords">0 단어</span>
      <span id="statChars">0 글자</span>
    </div>
  </div>
</div>

<!-- Standard Alert/Prompt Modal Dialog -->
<div class="modal-backdrop" id="modalBackdrop">
  <div class="modal-box">
    <div class="modal-title" id="modalTitle">알림</div>
    <div class="modal-desc" id="modalDesc"></div>
    <input type="text" id="modalInput" class="modal-input" placeholder="이름을 입력하세요...">
    <div class="modal-actions">
      <button class="btn" id="modalBtnCancel">취소</button>
      <button class="btn" id="modalBtnExtra" style="display:none;">생성일순 정렬</button>
      <button class="btn btn-primary" id="modalBtnConfirm">확인</button>
    </div>
  </div>
</div>

<!-- 인쇄 설정 창 (v2.7: 인쇄 전용. PDF 저장은 상단의 「📄 PDF」 버튼이 맡는다) -->
<div class="modal-backdrop" id="printModalBackdrop">
  <div class="modal-box print-modal">
    <div class="modal-title">🖨️ 인쇄 설정</div>
    <div class="print-opt-row">
      <span class="print-opt-label">인쇄할 내용</span>
      <label><input type="radio" name="printTarget" value="note" checked> 현재 노트</label>
      <label><input type="radio" name="printTarget" value="pad"> 빈 원고지 양식</label>
      <input type="number" id="printPadCount" min="1" max="50" value="2" title="빈 원고지 장수 (1~50)"> 장
    </div>
    <div class="print-opt-row">
      <span class="print-opt-label">용지</span>
      <select id="printPaper">
        <option value="A4">A4 (210 × 297mm)</option>
        <option value="B5">B5 (182 × 257mm)</option>
        <option value="Letter">Letter (216 × 279mm)</option>
      </select>
    </div>
    <div class="print-opt-row">
      <span class="print-opt-label">잉크</span>
      <label><input type="radio" name="printInk" value="red" checked> 빨간 원고지</label>
      <label><input type="radio" name="printInk" value="mono"> 흑백(먹색) · 레이저 프린터용</label>
    </div>
    <div class="print-opt-row">
      <span class="print-opt-label">자동 표기</span>
      <label><input type="checkbox" id="printAuto"> 제목 · 날짜 · 쪽 번호를 자동으로 넣기</label>
    </div>
    <div class="print-opt-hint" id="printModalHint"></div>
    <div class="modal-actions">
      <button class="btn" id="printBtnCancel">닫기</button>
      <button class="btn btn-primary" id="printBtnPrint">🖨️ 인쇄…</button>
    </div>
  </div>
</div>

<!-- 시그니처 기능 4: 타자기 천공 카드(Punch-Card) 월간 집필 히트맵 모달 -->
<div class="modal-backdrop" id="statsModalBackdrop">
  <div class="modal-box stats-modal-wide">
    <div class="modal-title" id="statsModalTitle">🟥 TypeGrapher 월간 집필 천공 카드</div>
    <div class="stats-summary-grid">
      <div class="stat-card">
        <div class="stat-card-val" id="statTotalNotes">0개</div>
        <div class="stat-card-lbl">전체 보관함 노트</div>
      </div>
      <div class="stat-card">
        <div class="stat-card-val" id="statTotalChars">0자</div>
        <div class="stat-card-lbl">누적 집필 글자 수</div>
      </div>
      <div class="stat-card">
        <div class="stat-card-val" id="statMonthDays">0일</div>
        <div class="stat-card-lbl">이번 달 집필 일수</div>
      </div>
      <div class="stat-card">
        <div class="stat-card-val" id="statStreakDays">0일</div>
        <div class="stat-card-lbl">연속 집필 스트릭</div>
      </div>
    </div>
    <div id="heatmapContainer"></div>
    <div class="modal-desc" style="font-size:11.5px; opacity:0.75; margin-bottom:10px;">
      * 빨간색 타자기 잉크가 진할수록 해당 날짜에 많은 글자를 기록한 날입니다. 날짜 칸을 클릭하면 해당 날짜의 일기장으로 즉시 이동합니다.
    </div>
    <div class="modal-actions">
      <button class="btn btn-primary" id="btnCloseStatsModal">닫기</button>
    </div>
  </div>
</div>

<script>
(function () {
  var state = {
    vaultPath: '',
    vaultName: 'TypeGrapher',
    folders: [],
    notes: [],
    folderOrder: [],
    noteOrder: [],
    activeRelPath: null,
    selectedFolder: '',
    selectionTargetType: 'note',
    collapsedFolders: {},
    foldersInitializedFor: null,   // 폴더 펼침 상태를 초기화해 둔 보관함 경로 (앱을 처음 열었을 때 = null)
    zenMode: false,
    searchQuery: '',
    isComposing: false,
    isModalOpen: false,
    dragPayload: null,
    sidebarWidth: 280,
    // 5대 시그니처 상태값
    keySoundEnabled: true,   // 타건음 (활자·스페이스)
    bellSoundEnabled: true,  // 엔터 벨소리
    typingNow: false,        // 집중 모드 글로우: 지금 타이핑 중인지
    focusMode: false,
    noBackspaceMode: false,
    paperStyle: 'default', // 'default', 'typewriter', 'manuscript'(원고지 줄), 'grid'(원고지 칸)
    sheetMeta: {},         // 원고지(칸) 머리말 값: { 보관함 경로: { 노트 경로: { t: 제목 } } }
    printOpts: { ink: 'red', auto: false, paper: 'A4', padCount: 2 },   // 조판(인쇄 · PDF) 설정
    isPrintModalOpen: false
  };

  var elSidebar = document.getElementById('sidebar');
  var elSidebarResizer = document.getElementById('sidebarResizer');
  var elVaultName = document.getElementById('vaultNameText');
  var elNoteList = document.getElementById('noteList');
  var elNoteCountBadge = document.getElementById('noteCountBadge');
  var elActiveFolderBar = document.getElementById('activeFolderBar');
  var elActiveFolderLabel = document.getElementById('activeFolderLabel');
  var elNoteFolderBadge = document.getElementById('currentNoteFolderBadge');
  var elSearchInput = document.getElementById('searchInput');
  var elTitleInput = document.getElementById('noteTitleInput');
  var elScrollContainer = document.getElementById('editorScrollContainer');
  var elLiveEditor = document.getElementById('liveEditor');
  var elFormatToolbar = document.getElementById('formatToolbar');
  var elSaveStatus = document.getElementById('saveStatusText');
  var elStatModeBadge = document.getElementById('statModeBadge');
  var elStatLines = document.getElementById('statLines');
  var elStatWords = document.getElementById('statWords');
  var elStatChars = document.getElementById('statChars');

  var elBtnToggleSound = document.getElementById('btnToggleSound');
  var elBtnToggleBell = document.getElementById('btnToggleBell');
  var elBtnToggleFocus = document.getElementById('btnToggleFocusMode');
  var elBtnToolbarFocus = document.getElementById('btnToolbarFocus');
  var elBtnNoBackspace = document.getElementById('btnNoBackspace');
  var elBtnPaperStyle = document.getElementById('btnPaperStyle');

  var elModalBackdrop = document.getElementById('modalBackdrop');
  var elModalTitle = document.getElementById('modalTitle');
  var elModalDesc = document.getElementById('modalDesc');
  var elModalInput = document.getElementById('modalInput');
  var elModalCancel = document.getElementById('modalBtnCancel');
  var elModalExtra = document.getElementById('modalBtnExtra');
  var elModalConfirm = document.getElementById('modalBtnConfirm');
  var modalConfirmCallback = null;
  var modalExtraCallback = null;

  var elStatsModalBackdrop = document.getElementById('statsModalBackdrop');

  var elGridSurface = document.getElementById('gridSurface');
  var elGridInput = document.getElementById('gridInput');
  var elGridPaper = document.getElementById('gridPaper');

  function hasNative() {
    return typeof window.NativeBridge !== 'undefined' && window.NativeBridge !== null;
  }

  function formatDateTime(timestamp) {
    var d = new Date(timestamp);
    var yyyy = d.getFullYear();
    var mm = ('0' + (d.getMonth() + 1)).slice(-2);
    var dd = ('0' + d.getDate()).slice(-2);
    var hh = ('0' + d.getHours()).slice(-2);
    var min = ('0' + d.getMinutes()).slice(-2);
    return yyyy + '-' + mm + '-' + dd + ' ' + hh + ':' + min;
  }

  function formatKoreanDailyTitle(dateObj) {
    var d = dateObj || new Date();
    var yyyy = d.getFullYear();
    var mm = ('0' + (d.getMonth() + 1)).slice(-2);
    var dd = ('0' + d.getDate()).slice(-2);
    var weekDays = ['일', '월', '화', '수', '목', '금', '토'];
    var dayStr = weekDays[d.getDay()];
    return yyyy + '년 ' + mm + '월 ' + dd + '일 (' + dayStr + ')';
  }

  function sanitizeSingleName(raw) {
    var s = String(raw || '').replace(/[\\/:*?"<>|]/g, '_').replace(/^\.+/, '').trim();
    return s || '제목 없는 노트';
  }

  function sanitizeFolderPath(rawPath) {
    var parts = String(rawPath || '').replace(/\\/g, '/').split('/');
    var cleaned = [];
    for (var i = 0; i < parts.length; i++) {
      var seg = parts[i].replace(/[:*?"<>|]/g, '_').replace(/^\.+/, '').trim();
      if (seg) cleaned.push(seg);
    }
    return cleaned.join('/');
  }

  function escapeHtml(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function showModal(title, desc, onConfirm, hideCancel, extraBtnText, onExtra) {
    state.isModalOpen = true;
    elModalTitle.innerHTML = escapeHtml(title);
    elModalDesc.innerHTML = escapeHtml(desc);
    elModalInput.style.display = 'none';
    elModalInput.value = '';
    elModalConfirm.innerHTML = '확인';
    modalConfirmCallback = onConfirm || null;
    modalExtraCallback = onExtra || null;
    elModalCancel.style.display = hideCancel ? 'none' : 'inline-block';
    if (extraBtnText && onExtra) {
      elModalExtra.innerHTML = escapeHtml(extraBtnText);
      elModalExtra.style.display = 'inline-block';
      elModalConfirm.innerHTML = '이름순 정렬 (가나다)';
    } else {
      elModalExtra.style.display = 'none';
    }
    elModalBackdrop.className = 'modal-backdrop show';
    elModalConfirm.focus();
  }

  function showPromptModal(title, desc, placeholder, defaultVal, onConfirm) {
    state.isModalOpen = true;
    elModalTitle.innerHTML = escapeHtml(title);
    elModalDesc.innerHTML = escapeHtml(desc);
    elModalInput.style.display = 'block';
    elModalInput.placeholder = placeholder || '';
    elModalInput.value = defaultVal || '';
    elModalExtra.style.display = 'none';
    elModalConfirm.innerHTML = '확인';
    modalConfirmCallback = function () {
      if (typeof onConfirm === 'function') {
        onConfirm(elModalInput.value);
      }
    };
    modalExtraCallback = null;
    elModalCancel.style.display = 'inline-block';
    elModalBackdrop.className = 'modal-backdrop show';
    setTimeout(function () {
      elModalInput.focus();
      elModalInput.select();
    }, 20);
  }

  function closeModal() {
    state.isModalOpen = false;
    elModalBackdrop.className = 'modal-backdrop';
    elStatsModalBackdrop.className = 'modal-backdrop';
    modalConfirmCallback = null;
    modalExtraCallback = null;
  }

  elModalCancel.onclick = closeModal;
  elModalConfirm.onclick = function () {
    var cb = modalConfirmCallback;
    closeModal();
    if (typeof cb === 'function') cb();
  };
  elModalExtra.onclick = function () {
    var cb = modalExtraCallback;
    closeModal();
    if (typeof cb === 'function') cb();
  };
  document.getElementById('btnCloseStatsModal').onclick = closeModal;

  elModalInput.onkeydown = function (e) {
    var key = e.keyCode || e.which;
    if (key === 13) {
      e.preventDefault();
      if (e.stopPropagation) e.stopPropagation();
      elModalConfirm.click();
    } else if (key === 27) {
      e.preventDefault();
      if (e.stopPropagation) e.stopPropagation();
      closeModal();
    }
  };

  /* ==========================================================================
     시그니처 기능 1, 2, 3, 4, 5 핵심 제어 함수들
     ========================================================================== */
  function updateSignatureUIStates() {
    // 1. 타건음 / 엔터 벨소리 버튼 (v2.1: 각각 따로 켜고 끔)
    elBtnToggleSound.className = 'ribbon-btn' + (state.keySoundEnabled ? ' active-ribbon' : '');
    elBtnToggleSound.innerHTML = state.keySoundEnabled ? '&#128266;' : '&#128263;';
    elBtnToggleBell.className = 'ribbon-btn' + (state.bellSoundEnabled ? ' active-ribbon' : '');
    elBtnToggleBell.innerHTML = state.bellSoundEnabled ? '&#128276;' : '&#128277;';

    // 2. 집중 조명 & 타자기 중앙 스크롤
    elBtnToggleFocus.className = 'ribbon-btn' + (state.focusMode ? ' active-ribbon' : '');
    elBtnToolbarFocus.className = 'tool-btn' + (state.focusMode ? ' active-tool' : '');

    // 5-A. 무후회 모드
    elBtnNoBackspace.className = 'tool-btn' + (state.noBackspaceMode ? ' active-tool' : '');

    // 5-B. 타자기체 / 원고지(줄) / 원고지(칸) 스타일
    var styleLabel = '기본';
    if (state.paperStyle === 'typewriter') styleLabel = '타자기체';
    else if (state.paperStyle === 'manuscript') styleLabel = '원고지(줄)';
    else if (state.paperStyle === 'grid') styleLabel = '원고지(칸)';
    elBtnPaperStyle.innerHTML = '&#128220; 스타일: ' + styleLabel;
    elBtnPaperStyle.className = 'tool-btn' + (state.paperStyle !== 'default' ? ' active-tool' : '');

    var canvasCls = 'live-editor-canvas';
    if (state.focusMode) canvasCls += ' focus-mode-active';
    if (state.typingNow) canvasCls += ' typing-now';
    if (state.paperStyle === 'typewriter') canvasCls += ' style-typewriter';
    else if (state.paperStyle === 'manuscript') canvasCls += ' style-manuscript';
    elLiveEditor.className = canvasCls;

    var scrollCls = 'live-editor-scroll';
    if (state.zenMode) scrollCls += ' zen-active';
    if (state.focusMode) scrollCls += ' typewriter-scroll-pad';
    elScrollContainer.className = scrollCls;

    // 원고지(칸) 모드에서는 일반 편집기 대신 원고지 편집기를 보여 준다
    var gridOn = isGridMode();
    elLiveEditor.style.display = gridOn ? 'none' : '';
    elGridSurface.style.display = gridOn ? 'block' : 'none';
    applyGridPaperClass();
    if (gridOn) {
      refreshGridMetrics();
      scheduleGridRender(false);
    }

    var badges = [];
    badges.push(state.keySoundEnabled ? '🔊 타건음 ON' : '🔇 타건음 OFF');
    badges.push(state.bellSoundEnabled ? '🔔 벨 ON' : '🔕 벨 OFF');
    if (state.focusMode) badges.push('🎯 집중 스크롤');
    if (state.noBackspaceMode) badges.push('🔒 무후회');
    elStatModeBadge.innerHTML = badges.join(' · ');
  }

  /* 시그니처 1: 리얼 수동 타자기 사운드 재생 (v2.1: 타건음과 엔터 벨소리를 따로 제어) */
  function triggerTypewriterSound(keyCode) {
    if (!hasNative()) return;
    if (!state.keySoundEnabled && !state.bellSoundEnabled) return;
    if (keyCode === 16 || keyCode === 17 || keyCode === 18 || keyCode === 91 || keyCode === 93 ||
        (keyCode >= 37 && keyCode <= 40)) {
      return; // 방향키 및 조합키는 소리 생략
    }
    if (keyCode === 13) {
      if (state.bellSoundEnabled) {
        window.NativeBridge.playTypeSound('bell'); // 엔터키: 챙~! 황동 벨소리
      } else if (state.keySoundEnabled) {
        window.NativeBridge.playTypeSound('space'); // 벨만 끈 경우: 엔터도 일반 키처럼 묵직한 타격음
      }
      return;
    }
    if (!state.keySoundEnabled) return; // 타건음만 끈 경우: 엔터 벨만 울림
    if (keyCode === 32 || keyCode === 8 || keyCode === 46) {
      window.NativeBridge.playTypeSound('space'); // 스페이스/백스페이스: 묵직한 타격음
    } else {
      window.NativeBridge.playTypeSound('key'); // 일반 활자 키: 경쾌한 철컥거림
    }
  }

  /* 시그니처 2: 현재 타이핑 문단 집중 조명 & 타자기 롤러 중앙 고정 스크롤 */
  function updateFocusAndTypewriterScroll() {
    if (isGridMode()) {
      scheduleGridRender(state.focusMode);
      return;
    }
    var children = elLiveEditor.children;
    for (var i = 0; i < children.length; i++) {
      if (children[i].className && children[i].className.indexOf('active-focus-block') !== -1) {
        children[i].className = children[i].className.replace(/\bactive-focus-block\b/g, '').trim();
      }
    }
    if (!state.focusMode) return;

    var block = getActiveBlockElement();
    if (!block) return;

    // 최상위 블록 찾기
    var topBlock = block;
    while (topBlock.parentNode && topBlock.parentNode !== elLiveEditor) {
      topBlock = topBlock.parentNode;
    }
    if (topBlock && topBlock.nodeType === 1) {
      topBlock.className = (topBlock.className ? topBlock.className + ' ' : '') + 'active-focus-block';
    }

    // 현재 커서/문단 위치를 화면 세로 중앙(45% 지점)으로 부드럽게 고정
    try {
      var containerRect = elScrollContainer.getBoundingClientRect();
      var blockRect = block.getBoundingClientRect();
      var targetCenter = containerRect.top + (containerRect.height * 0.45);
      var diff = (blockRect.top + blockRect.height * 0.5) - targetCenter;
      if (Math.abs(diff) > 18) {
        elScrollContainer.scrollTop += diff * 0.65;
      }
    } catch (e) {}
  }

  /* 시그니처 3: 현재 흐르는 음악(BGM) 스탬프 자동 각인 */
  function insertNowPlayingBGMStamp() {
    if (isGridMode()) {
      var gTrack = hasNative() ? (window.NativeBridge.getCurrentBGM() || '') : '';
      gTrack = String(gTrack).replace(/^\s+|\s+$/g, '');
      gridInsertBlock('> 🎵 Now Playing: **' + (gTrack || '아티스트 — 곡 제목') + '**');
      updateSaveStatus(gTrack
        ? ('🎵 현재 재생 중인 BGM이 일기에 각인되었습니다: ' + gTrack)
        : '🎵 BGM 스탬프 양식이 삽입되었습니다 (Music/iTunes 재생 시 곡명이 자동 입력됩니다)');
      return;
    }
    elLiveEditor.focus();
    var trackInfo = '';
    if (hasNative()) {
      trackInfo = window.NativeBridge.getCurrentBGM() || '';
    }
    var stampHtml = '';
    if (trackInfo && trackInfo.trim().length > 0) {
      stampHtml = '<blockquote><p>🎵 Now Playing: <strong>' + escapeHtml(trackInfo.trim()) + '</strong></p></blockquote><p><br></p>';
      updateSaveStatus('🎵 현재 재생 중인 BGM이 일기에 각인되었습니다: ' + trackInfo);
    } else {
      stampHtml = '<blockquote><p>🎵 Now Playing: <strong>아티스트 — 곡 제목</strong></p></blockquote><p><br></p>';
      updateSaveStatus('🎵 BGM 스탬프 양식이 삽입되었습니다 (Music/iTunes 재생 시 곡명이 자동 입력됩니다)');
    }
    document.execCommand('insertHTML', false, stampHtml);
    syncEditorToDisk();
  }

  /* 시그니처 4: 타자기 천공 카드 월간 집필 히트맵 & 통계 계산 */
  function openPunchCardStatsModal() {
    state.isModalOpen = true;
    var now = new Date();
    var curYear = now.getFullYear();
    var curMonth = now.getMonth(); // 0 ~ 11

    document.getElementById('statsModalTitle').innerHTML =
      '🟥 ' + curYear + '년 ' + (curMonth + 1) + '월 TypeGrapher 집필 천공 카드';

    var totalNotes = state.notes.length;
    var totalChars = 0;
    var dayCharMap = {}; // 'YYYY-MM-DD' -> chars

    for (var i = 0; i < state.notes.length; i++) {
      var n = state.notes[i];
      var len = (n.content || '').length;
      totalChars += len;

      // 1. 제목에서 날짜 추출 (예: "2026년 11월 15일")
      var dateKey = null;
      var korMatch = n.title.match(/(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일/);
      if (korMatch) {
        dateKey = korMatch[1] + '-' + ('0' + korMatch[2]).slice(-2) + '-' + ('0' + korMatch[3]).slice(-2);
      } else {
        var isoMatch = n.title.match(/^(\d{4})-(\d{2})-(\d{2})/);
        if (isoMatch) {
          dateKey = isoMatch[1] + '-' + isoMatch[2] + '-' + isoMatch[3];
        } else {
          var dObj = new Date(n.updatedAt || n.createdAt || now.getTime());
          dateKey = dObj.getFullYear() + '-' + ('0' + (dObj.getMonth() + 1)).slice(-2) + '-' + ('0' + dObj.getDate()).slice(-2);
        }
      }
      dayCharMap[dateKey] = (dayCharMap[dateKey] || 0) + Math.max(len, 1);
    }

    // 이번 달 집필 일수 계산
    var monthPrefix = curYear + '-' + ('0' + (curMonth + 1)).slice(-2) + '-';
    var monthActiveDays = 0;
    for (var k in dayCharMap) {
      if (dayCharMap.hasOwnProperty(k) && k.indexOf(monthPrefix) === 0) {
        monthActiveDays++;
      }
    }

    // 연속 집필 스트릭(Streak) 계산
    var streak = 0;
    var checkDate = new Date(curYear, curMonth, now.getDate());
    while (true) {
      var ckKey = checkDate.getFullYear() + '-' + ('0' + (checkDate.getMonth() + 1)).slice(-2) + '-' + ('0' + checkDate.getDate()).slice(-2);
      if (dayCharMap[ckKey]) {
        streak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else {
        break;
      }
    }

    document.getElementById('statTotalNotes').innerHTML = totalNotes + '개';
    document.getElementById('statTotalChars').innerHTML = totalChars.toLocaleString() + '자';
    document.getElementById('statMonthDays').innerHTML = monthActiveDays + '일';
    document.getElementById('statStreakDays').innerHTML = streak + '일 연속';

    // 달력 매트릭스 생성
    var firstDayOfWeek = new Date(curYear, curMonth, 1).getDay();
    var daysInMonth = new Date(curYear, curMonth + 1, 0).getDate();

    var tbl = ['<table class="heatmap-table"><thead><tr><th>일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th>토</th></tr></thead><tbody><tr>'];
    var col = 0;
    for (var b = 0; b < firstDayOfWeek; b++) {
      tbl.push('<td></td>');
      col++;
    }

    for (var day = 1; day <= daysInMonth; day++) {
      if (col === 7) {
        tbl.push('</tr><tr>');
        col = 0;
      }
      var dKey = monthPrefix + ('0' + day).slice(-2);
      var cCount = dayCharMap[dKey] || 0;
      var lv = 'heat-lv0';
      if (cCount > 0 && cCount < 150) lv = 'heat-lv1';
      else if (cCount >= 150 && cCount < 500) lv = 'heat-lv2';
      else if (cCount >= 500 && cCount < 1200) lv = 'heat-lv3';
      else if (cCount >= 1200) lv = 'heat-lv4';

      tbl.push(
        '<td class="heatmap-cell ' + lv + '" data-day="' + day + '" title="' + dKey + ' (' + cCount + '자 기록됨 - 클릭하여 일기 열기)">' +
        day + '일<div style="font-size:9px; opacity:0.85;">' + (cCount > 0 ? (cCount + '자') : '-') + '</div></td>'
      );
      col++;
    }
    while (col > 0 && col < 7) {
      tbl.push('<td></td>');
      col++;
    }
    tbl.push('</tr></tbody></table>');

    var container = document.getElementById('heatmapContainer');
    container.innerHTML = tbl.join('');

    // 달력 날짜 클릭 시 해당 일기로 즉시 이동/생성
    container.onclick = function (e) {
      var target = e.target || e.srcElement;
      while (target && target !== container && !target.getAttribute('data-day')) {
        target = target.parentNode;
      }
      if (target && target.getAttribute('data-day')) {
        var clickedDay = parseInt(target.getAttribute('data-day'), 10);
        closeModal();
        var targetDateObj = new Date(curYear, curMonth, clickedDay);
        openOrCreateDailyNoteForDate(targetDateObj);
      }
    };

    elStatsModalBackdrop.className = 'modal-backdrop show';
  }

  /* 1. Markdown -> Live Editable DOM Parser */
  function parseInline(text) {
    var s = escapeHtml(text);
    s = s.replace(/`([^`]+)`/g, '<code>$1</code>');
    s = s.replace(/\[\[([^\]]+)\]\]/g, '<span class="wiki-tag" contenteditable="false" data-wikilink="$1">[[$1]]</span>');
    s = s.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>');
    s = s.replace(/\*\*\*([^*]+)\*\*\*/g, '<strong><em>$1</em></strong>');
    s = s.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
    s = s.replace(/__([^_]+)__/g, '<strong>$1</strong>');
    s = s.replace(/\*([^*]+)\*/g, '<em>$1</em>');
    s = s.replace(/_([^_]+)_/g, '<em>$1</em>');
    s = s.replace(/~~([^~]+)~~/g, '<del>$1</del>');
    return s;
  }

  function parseMarkdownToHTML(md) {
    if (!md || md.trim() === '') return '<p><br></p>';
    var lines = md.replace(/\r\n/g, '\n').split('\n');
    var html = [];
    var inCodeBlock = false;
    var codeBuffer = [];
    var inUl = false;
    var inOl = false;
    var inBlockquote = false;

    function closeLists() {
      if (inUl) { html.push('</ul>'); inUl = false; }
      if (inOl) { html.push('</ol>'); inOl = false; }
      if (inBlockquote) { html.push('</blockquote>'); inBlockquote = false; }
    }

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      if (/^```/.test(line.trim())) {
        closeLists();
        if (!inCodeBlock) {
          inCodeBlock = true;
          codeBuffer = [];
        } else {
          html.push('<pre><code>' + escapeHtml(codeBuffer.join('\n')) + '</code></pre>');
          inCodeBlock = false;
        }
        continue;
      }
      if (inCodeBlock) { codeBuffer.push(line); continue; }

      if (line.trim() === '') {
        closeLists();
        html.push('<p><br></p>');
        continue;
      }

      if (/^(---|\*\*\*|___)\s*$/.test(line.trim())) {
        closeLists();
        html.push('<hr>');
        continue;
      }

      var hMatch = line.match(/^(#{1,6})\s+(.*)$/);
      if (hMatch) {
        closeLists();
        var level = hMatch[1].length;
        html.push('<h' + level + '>' + (parseInline(hMatch[2]) || '<br>') + '</h' + level + '>');
        continue;
      }

      var bqMatch = line.match(/^>\s?(.*)$/);
      if (bqMatch) {
        if (inUl) { html.push('</ul>'); inUl = false; }
        if (inOl) { html.push('</ol>'); inOl = false; }
        if (!inBlockquote) { html.push('<blockquote>'); inBlockquote = true; }
        html.push('<p>' + (parseInline(bqMatch[1]) || '<br>') + '</p>');
        continue;
      } else if (inBlockquote) {
        html.push('</blockquote>');
        inBlockquote = false;
      }

      var taskMatch = line.match(/^\s*[-*]\s+\[([ xX])\]\s*(.*)$/);
      if (taskMatch) {
        if (inOl) { html.push('</ol>'); inOl = false; }
        if (!inUl) { html.push('<ul>'); inUl = true; }
        var checked = taskMatch[1].toLowerCase() === 'x';
        html.push(
          '<li class="task-item' + (checked ? ' task-done' : '') + '">' +
          '<input type="checkbox" contenteditable="false"' + (checked ? ' checked' : '') + '>' +
          '<span>' + (parseInline(taskMatch[2]) || '<br>') + '</span></li>'
        );
        continue;
      }

      var ulMatch = line.match(/^\s*[-*+]\s+(.*)$/);
      if (ulMatch) {
        if (inOl) { html.push('</ol>'); inOl = false; }
        if (!inUl) { html.push('<ul>'); inUl = true; }
        html.push('<li>' + (parseInline(ulMatch[1]) || '<br>') + '</li>');
        continue;
      }

      var olMatch = line.match(/^\s*\d+\.\s+(.*)$/);
      if (olMatch) {
        if (inUl) { html.push('</ul>'); inUl = false; }
        if (!inOl) { html.push('<ol>'); inOl = true; }
        html.push('<li>' + (parseInline(olMatch[1]) || '<br>') + '</li>');
        continue;
      }

      closeLists();
      html.push('<p>' + parseInline(line) + '</p>');
    }

    if (inCodeBlock) {
      html.push('<pre><code>' + escapeHtml(codeBuffer.join('\n')) + '</code></pre>');
    }
    closeLists();
    return html.length > 0 ? html.join('\n') : '<p><br></p>';
  }

  /* 2. Live Editable DOM -> Pure Markdown Serializer */
  function serializeInlineNodes(parent) {
    var out = '';
    var children = parent.childNodes;
    for (var i = 0; i < children.length; i++) {
      var n = children[i];
      if (n.nodeType === 3) {
        out += n.nodeValue.replace(/\u00A0/g, ' ');
      } else if (n.nodeType === 1) {
        var tag = n.tagName.toUpperCase();
        if (tag === 'BR' || tag === 'INPUT') {
          continue;
        } else if (n.className && n.className.indexOf('wiki-tag') !== -1) {
          var wk = n.getAttribute('data-wikilink') || n.textContent || '';
          wk = wk.replace(/^\[\[|\]\]$/g, '');
          out += '[[' + wk + ']]';
        } else if (tag === 'STRONG' || tag === 'B') {
          out += '**' + serializeInlineNodes(n) + '**';
        } else if (tag === 'EM' || tag === 'I') {
          out += '*' + serializeInlineNodes(n) + '*';
        } else if (tag === 'DEL' || tag === 'S' || tag === 'STRIKE') {
          out += '~~' + serializeInlineNodes(n) + '~~';
        } else if (tag === 'CODE') {
          out += '`' + serializeInlineNodes(n) + '`';
        } else if (tag === 'A') {
          out += '[' + serializeInlineNodes(n) + '](' + (n.getAttribute('href') || '') + ')';
        } else {
          out += serializeInlineNodes(n);
        }
      }
    }
    return out;
  }

  function serializeDOMToMarkdown(root) {
    var mdLines = [];
    var children = root.childNodes;

    for (var i = 0; i < children.length; i++) {
      var node = children[i];
      if (node.nodeType === 3) {
        var rawTxt = node.nodeValue.replace(/\u00A0/g, ' ').trim();
        if (rawTxt) mdLines.push(rawTxt);
        continue;
      }
      if (node.nodeType !== 1) continue;

      var tag = node.tagName.toUpperCase();
      if (/^H[1-6]$/.test(tag)) {
        var level = parseInt(tag.charAt(1), 10);
        var hashes = new Array(level + 1).join('#');
        mdLines.push(hashes + ' ' + serializeInlineNodes(node).trim());
      } else if (tag === 'HR') {
        mdLines.push('---');
      } else if (tag === 'PRE') {
        var codeText = (node.innerText || node.textContent || '').replace(/\u00A0/g, ' ').replace(/\n$/, '');
        mdLines.push('```\n' + codeText + '\n```');
      } else if (tag === 'BLOCKQUOTE') {
        var bqKids = node.childNodes;
        var hasBlock = false;
        for (var b = 0; b < bqKids.length; b++) {
          if (bqKids[b].nodeType === 1) {
            hasBlock = true;
            mdLines.push('> ' + serializeInlineNodes(bqKids[b]));
          }
        }
        if (!hasBlock) {
          mdLines.push('> ' + serializeInlineNodes(node));
        }
      } else if (tag === 'UL' || tag === 'OL') {
        var items = node.childNodes;
        var olIdx = 1;
        for (var k = 0; k < items.length; k++) {
          var li = items[k];
          if (li.nodeType !== 1 || li.tagName.toUpperCase() !== 'LI') continue;
          var cb = li.querySelector ? li.querySelector('input[type="checkbox"]') : null;
          if (cb) {
            var isChecked = cb.checked;
            mdLines.push('- [' + (isChecked ? 'x' : ' ') + '] ' + serializeInlineNodes(li).trim());
          } else if (tag === 'OL') {
            mdLines.push(olIdx + '. ' + serializeInlineNodes(li).trim());
            olIdx++;
          } else {
            mdLines.push('- ' + serializeInlineNodes(li).trim());
          }
        }
      } else {
        var lineStr = serializeInlineNodes(node);
        mdLines.push(lineStr);
      }
    }

    var joined = mdLines.join('\n').replace(/\n{3,}/g, '\n\n');
    if (joined.trim() === '') return '';
    return joined;
  }

  /* 3. Caret & Block Formatting Helpers */
  function placeCaretAtStart(el) {
    if (el === elLiveEditor && isGridMode()) {
      gridFocusInput();
      if (!elGridInput.value) gridSetSel(0, 0);
      scheduleGridRender(true);
      return;
    }
    el.focus();
    if (window.getSelection && document.createRange) {
      var range = document.createRange();
      range.selectNodeContents(el);
      range.collapse(true);
      var sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    }
  }

  function placeCaretAtEnd(el) {
    if (el === elLiveEditor && isGridMode()) {
      gridFocusInput();
      gridSetSel(elGridInput.value.length, elGridInput.value.length);
      scheduleGridRender(true);
      return;
    }
    el.focus();
    if (window.getSelection && document.createRange) {
      var range = document.createRange();
      range.selectNodeContents(el);
      range.collapse(false);
      var sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    }
  }

  function getActiveBlockElement() {
    var sel = window.getSelection ? window.getSelection() : null;
    if (!sel || !sel.anchorNode) return null;
    var node = sel.anchorNode;
    while (node && node !== elLiveEditor) {
      if (node.nodeType === 1) {
        var t = node.tagName.toUpperCase();
        if (t === 'P' || t === 'DIV' || /^H[1-6]$/.test(t) || t === 'LI' || t === 'PRE' || t === 'BLOCKQUOTE') {
          return node;
        }
      }
      node = node.parentNode;
    }
    return null;
  }

  function replaceBlockWithTag(oldBlock, newTagName, initialHtml) {
    var newEl = document.createElement(newTagName);
    newEl.innerHTML = initialHtml || '<br>';
    oldBlock.parentNode.replaceChild(newEl, oldBlock);
    placeCaretAtStart(newEl);
    syncEditorToDisk();
  }

  function checkBlockMarkdownShortcutOnSpace() {
    var block = getActiveBlockElement();
    if (!block) return false;
    var rawText = (block.innerText || block.textContent || '').replace(/\u00A0/g, ' ');

    var hMatch = rawText.match(/^(#{1,6})\s(.*)$/);
    if (hMatch) {
      var level = hMatch[1].length;
      var rest = escapeHtml(hMatch[2]) || '<br>';
      replaceBlockWithTag(block, 'h' + level, rest);
      return true;
    }

    var bqMatch = rawText.match(/^>\s(.*)$/);
    if (bqMatch) {
      var bq = document.createElement('blockquote');
      var p = document.createElement('p');
      p.innerHTML = escapeHtml(bqMatch[1]) || '<br>';
      bq.appendChild(p);
      block.parentNode.replaceChild(bq, block);
      placeCaretAtStart(p);
      syncEditorToDisk();
      return true;
    }

    var taskMatch = rawText.match(/^(?:[-*]\s+)?\[([ xX]?)\]\s(.*)$/);
    if (taskMatch) {
      var checked = taskMatch[1].toLowerCase() === 'x';
      var ul = document.createElement('ul');
      var li = document.createElement('li');
      li.className = 'task-item' + (checked ? ' task-done' : '');
      var cb = document.createElement('input');
      cb.type = 'checkbox';
      cb.setAttribute('contenteditable', 'false');
      cb.checked = checked;
      var sp = document.createElement('span');
      sp.innerHTML = escapeHtml(taskMatch[2]) || '<br>';
      li.appendChild(cb);
      li.appendChild(sp);
      ul.appendChild(li);
      block.parentNode.replaceChild(ul, block);
      placeCaretAtStart(sp);
      syncEditorToDisk();
      return true;
    }

    var ulMatch = rawText.match(/^[-*+]\s(.*)$/);
    if (ulMatch && block.tagName.toUpperCase() !== 'LI') {
      var ul2 = document.createElement('ul');
      var li2 = document.createElement('li');
      li2.innerHTML = escapeHtml(ulMatch[1]) || '<br>';
      ul2.appendChild(li2);
      block.parentNode.replaceChild(ul2, block);
      placeCaretAtStart(li2);
      syncEditorToDisk();
      return true;
    }

    return false;
  }

  function checkInlineMarkdownShortcuts() {
    var sel = window.getSelection ? window.getSelection() : null;
    if (!sel || !sel.isCollapsed || !sel.anchorNode || sel.anchorNode.nodeType !== 3) return;

    var textNode = sel.anchorNode;
    var text = textNode.nodeValue;
    var offset = sel.anchorOffset;
    var beforeCaret = text.slice(0, offset);
    var afterCaret = text.slice(offset);

    var wikiMatch = beforeCaret.match(/\[\[([^\[\]\n]+)\]\]$/);
    if (wikiMatch) {
      var linkTitle = wikiMatch[1];
      var prefix = beforeCaret.slice(0, wikiMatch.index);
      var span = document.createElement('span');
      span.className = 'wiki-tag';
      span.setAttribute('contenteditable', 'false');
      span.setAttribute('data-wikilink', linkTitle);
      span.innerHTML = '[[' + escapeHtml(linkTitle) + ']]';

      var parent = textNode.parentNode;
      var beforeNode = document.createTextNode(prefix);
      var afterNode = document.createTextNode('\u00A0' + afterCaret);
      parent.insertBefore(beforeNode, textNode);
      parent.insertBefore(span, textNode);
      parent.insertBefore(afterNode, textNode);
      parent.removeChild(textNode);

      var range = document.createRange();
      range.setStart(afterNode, 1);
      range.collapse(true);
      sel.removeAllRanges();
      sel.addRange(range);
      syncEditorToDisk();
      return;
    }

    var boldMatch = beforeCaret.match(/\*\*([^*]+)\*\*$/);
    if (boldMatch) {
      var bText = boldMatch[1];
      var bPrefix = beforeCaret.slice(0, boldMatch.index);
      var strong = document.createElement('strong');
      strong.innerText = bText;

      var bParent = textNode.parentNode;
      var bBefore = document.createTextNode(bPrefix);
      var bAfter = document.createTextNode('\u00A0' + afterCaret);
      bParent.insertBefore(bBefore, textNode);
      bParent.insertBefore(strong, textNode);
      bParent.insertBefore(bAfter, textNode);
      bParent.removeChild(textNode);

      var r2 = document.createRange();
      r2.setStart(bAfter, 1);
      r2.collapse(true);
      sel.removeAllRanges();
      sel.addRange(r2);
      syncEditorToDisk();
      return;
    }

    var codeMatch = beforeCaret.match(/`([^`\n]+)`$/);
    if (codeMatch) {
      var cText = codeMatch[1];
      var cPrefix = beforeCaret.slice(0, codeMatch.index);
      var codeEl = document.createElement('code');
      codeEl.innerText = cText;

      var cParent = textNode.parentNode;
      var cBefore = document.createTextNode(cPrefix);
      var cAfter = document.createTextNode('\u00A0' + afterCaret);
      cParent.insertBefore(cBefore, textNode);
      cParent.insertBefore(codeEl, textNode);
      cParent.insertBefore(cAfter, textNode);
      cParent.removeChild(textNode);

      var r3 = document.createRange();
      r3.setStart(cAfter, 1);
      r3.collapse(true);
      sel.removeAllRanges();
      sel.addRange(r3);
      syncEditorToDisk();
    }
  }

  /* 4. 기본 '하단 추가(Append)' 순서 보존 엔진 & 설정 저장 */
  function saveOrderConfigToNative() {
    if (!hasNative()) return;
    try {
      var payload = JSON.stringify({
        folderOrder: state.folderOrder,
        noteOrder: state.noteOrder,
        sidebarWidth: state.sidebarWidth,
        keySoundEnabled: state.keySoundEnabled,
        bellSoundEnabled: state.bellSoundEnabled,
        focusMode: state.focusMode,
        noBackspaceMode: state.noBackspaceMode,
        paperStyle: state.paperStyle,
        sheetMeta: state.sheetMeta,
        printOpts: state.printOpts
      });
      window.NativeBridge.saveOrderConfig(payload);
    } catch (e) {}
  }

  function applySidebarWidth(w) {
    var clamped = Math.max(180, Math.min(520, parseInt(w, 10) || 280));
    state.sidebarWidth = clamped;
    elSidebar.style.width = clamped + 'px';
    elSidebar.style.minWidth = clamped + 'px';
    if (isGridMode()) {
      refreshGridMetrics();
      scheduleGridRender(false);
    }
  }

  function reconcileOrdersAndPreserveAppend(rawFolders, rawNotes, savedOrderObj) {
    if (savedOrderObj) {
      if (savedOrderObj.folderOrder && savedOrderObj.folderOrder.length) {
        state.folderOrder = savedOrderObj.folderOrder;
      }
      if (savedOrderObj.noteOrder && savedOrderObj.noteOrder.length) {
        state.noteOrder = savedOrderObj.noteOrder;
      }
      if (savedOrderObj.sidebarWidth) {
        applySidebarWidth(savedOrderObj.sidebarWidth);
      }
      // v2.0 까지는 soundEnabled 하나로 타건음과 벨을 함께 제어했으므로, 새 값이 없으면 그 값을 이어받는다
      if (typeof savedOrderObj.keySoundEnabled === 'boolean') {
        state.keySoundEnabled = savedOrderObj.keySoundEnabled;
      } else if (typeof savedOrderObj.soundEnabled === 'boolean') {
        state.keySoundEnabled = savedOrderObj.soundEnabled;
      }
      if (typeof savedOrderObj.bellSoundEnabled === 'boolean') {
        state.bellSoundEnabled = savedOrderObj.bellSoundEnabled;
      } else if (typeof savedOrderObj.soundEnabled === 'boolean') {
        state.bellSoundEnabled = savedOrderObj.soundEnabled;
      }
      if (typeof savedOrderObj.focusMode === 'boolean') {
        state.focusMode = savedOrderObj.focusMode;
      }
      if (typeof savedOrderObj.noBackspaceMode === 'boolean') {
        state.noBackspaceMode = savedOrderObj.noBackspaceMode;
      }
      if (savedOrderObj.paperStyle === 'typewriter' || savedOrderObj.paperStyle === 'manuscript' ||
          savedOrderObj.paperStyle === 'grid' || savedOrderObj.paperStyle === 'default') {
        state.paperStyle = savedOrderObj.paperStyle;
      }
      if (savedOrderObj.sheetMeta && typeof savedOrderObj.sheetMeta === 'object') {
        state.sheetMeta = savedOrderObj.sheetMeta;
        sheetMetaSanitize();
      }
      if (savedOrderObj.printOpts && typeof savedOrderObj.printOpts === 'object') {
        var po = savedOrderObj.printOpts;
        state.printOpts = {
          ink: (po.ink === 'mono') ? 'mono' : 'red',
          auto: !!po.auto,
          paper: (po.paper === 'B5' || po.paper === 'Letter') ? po.paper : 'A4',
          padCount: (parseInt(po.padCount, 10) >= 1) ? Math.min(50, parseInt(po.padCount, 10)) : 2
        };
      }
    }
    updateSignatureUIStates();

    var discoveredFolders = [];
    var seenFolder = {};
    var i, parts, p, cur;

    for (i = 0; i < rawFolders.length; i++) {
      parts = String(rawFolders[i] || '').split('/');
      cur = '';
      for (p = 0; p < parts.length; p++) {
        if (!parts[p]) continue;
        cur = cur ? (cur + '/' + parts[p]) : parts[p];
        if (!seenFolder[cur]) {
          seenFolder[cur] = true;
          discoveredFolders.push(cur);
        }
      }
    }

    for (i = 0; i < rawNotes.length; i++) {
      var nf = rawNotes[i].folder;
      if (nf) {
        parts = String(nf).split('/');
        cur = '';
        for (p = 0; p < parts.length; p++) {
          if (!parts[p]) continue;
          cur = cur ? (cur + '/' + parts[p]) : parts[p];
          if (!seenFolder[cur]) {
            seenFolder[cur] = true;
            discoveredFolders.push(cur);
          }
        }
      }
    }

    var nextFolderOrder = [];
    var addedFolder = {};
    for (i = 0; i < state.folderOrder.length; i++) {
      var fo = state.folderOrder[i];
      if (seenFolder[fo] && !addedFolder[fo]) {
        nextFolderOrder.push(fo);
        addedFolder[fo] = true;
      }
    }
    for (i = 0; i < discoveredFolders.length; i++) {
      var df = discoveredFolders[i];
      if (!addedFolder[df]) {
        nextFolderOrder.push(df);
        addedFolder[df] = true;
      }
    }
    state.folderOrder = nextFolderOrder;
    state.folders = nextFolderOrder.slice(0);

    var noteMap = {};
    for (i = 0; i < rawNotes.length; i++) {
      noteMap[rawNotes[i].relPath] = rawNotes[i];
    }

    var nextNoteOrder = [];
    var orderedNotes = [];
    var addedNote = {};

    for (i = 0; i < state.noteOrder.length; i++) {
      var no = state.noteOrder[i];
      if (noteMap[no] && !addedNote[no]) {
        nextNoteOrder.push(no);
        orderedNotes.push(noteMap[no]);
        addedNote[no] = true;
      }
    }
    for (i = 0; i < rawNotes.length; i++) {
      var rn = rawNotes[i];
      if (!addedNote[rn.relPath]) {
        nextNoteOrder.push(rn.relPath);
        orderedNotes.push(rn);
        addedNote[rn.relPath] = true;
      }
    }

    state.noteOrder = nextNoteOrder;
    state.notes = orderedNotes;
    saveOrderConfigToNative();
  }

  /* v2.8 자연스러운 이름 비교: 글자는 가나다(로캘) 순서로, 이름 안의 숫자는 '수의 크기'로 비교한다.
     글자 단위로만 비교하면 "2026년 11월 10일"이 "2026년 11월 9일"보다 앞에 온다 ('1' 이 '9' 보다 앞이므로).
     이름을 숫자 덩어리와 그 밖의 덩어리로 나누어 차례로 비교한다.  예) 9일 < 10일,  1장 < 2장 < 10장 */
  function naturalChunks(str) {
    var out = [], re = /\d+|\D+/g, m;
    while ((m = re.exec(str)) !== null) out.push(m[0]);
    return out;
  }

  function compareDigitRuns(a, b) {
    /* 자릿수가 아주 긴 숫자도 정확히 비교하도록 수로 바꾸지 않고, 앞의 0 을 뗀 뒤 길이 → 글자 순으로 비교한다 */
    var x = a.replace(/^0+/, ''), y = b.replace(/^0+/, '');
    if (x.length !== y.length) return x.length < y.length ? -1 : 1;
    if (x !== y) return x < y ? -1 : 1;
    return 0;
  }

  function naturalCompare(a, b) {
    var sa = String(a), sb = String(b);
    var ca = naturalChunks(sa), cb = naturalChunks(sb);
    var n = Math.min(ca.length, cb.length), i, da, db, r;
    for (i = 0; i < n; i++) {
      da = /^\d/.test(ca[i]);
      db = /^\d/.test(cb[i]);
      if (da && db) r = compareDigitRuns(ca[i], cb[i]);
      else if (da !== db) r = da ? -1 : 1;                 /* 같은 자리에서 숫자와 글자가 만나면 숫자가 먼저 */
      else r = ca[i].localeCompare(cb[i], 'ko');
      if (r !== 0) return r;
    }
    if (ca.length !== cb.length) return ca.length < cb.length ? -1 : 1;
    return sa.localeCompare(sb, 'ko');                     /* 수의 크기까지 같으면(9 와 09 등) 글자 비교로 순서를 정한다 */
  }

  function performManualAutoSort(mode) {
    if (mode === 'name') {
      state.folders.sort(naturalCompare);
      state.notes.sort(function (a, b) {
        return naturalCompare(a.title, b.title);
      });
    } else if (mode === 'created') {
      state.notes.sort(function (a, b) {
        return (a.createdAt || 0) - (b.createdAt || 0);
      });
    }

    state.folderOrder = state.folders.slice(0);
    state.noteOrder = [];
    for (var i = 0; i < state.notes.length; i++) {
      state.noteOrder.push(state.notes[i].relPath);
    }
    saveOrderConfigToNative();
    renderSidebar();
    updateSaveStatus(mode === 'name' ? '자동 정렬 완료 (이름순 가나다/A-Z, 숫자는 작은 수부터)' : '자동 정렬 완료 (생성일순)');
  }

  function openAutoSortModal() {
    showModal(
      '⇅ 폴더 및 파일 자동 정렬',
      '기본 상태에서는 새로 만드는 폴더와 파일이 항상 하단에 추가됩니다.\n지금 전체 목록을 자동으로 정렬하시겠습니까?',
      function () {
        performManualAutoSort('name');
      },
      false,
      '생성일순 정렬 (오래된 순)',
      function () {
        performManualAutoSort('created');
      }
    );
  }

  function getDirectChildFolders(parentFolder) {
    var children = [];
    var prefix = parentFolder ? (parentFolder + '/') : '';

    for (var i = 0; i < state.folders.length; i++) {
      var f = state.folders[i];
      if (!parentFolder) {
        if (f.indexOf('/') === -1) children.push(f);
      } else {
        if (f.indexOf(prefix) === 0) {
          var rest = f.slice(prefix.length);
          if (rest && rest.indexOf('/') === -1) {
            children.push(f);
          }
        }
      }
    }
    return children;
  }

  function countNotesInSubtree(folderPath, q) {
    var prefix = folderPath + '/';
    var count = 0;
    for (var i = 0; i < state.notes.length; i++) {
      var n = state.notes[i];
      if (n.folder === folderPath || (n.folder && n.folder.indexOf(prefix) === 0)) {
        if (q) {
          var mT = n.title.toLowerCase().indexOf(q) !== -1;
          var mB = n.content.toLowerCase().indexOf(q) !== -1;
          var mF = n.folder.toLowerCase().indexOf(q) !== -1;
          if (!mT && !mB && !mF) continue;
        }
        count++;
      }
    }
    return count;
  }

  function executeDropMove(targetFolderPath) {
    var payload = state.dragPayload;
    state.dragPayload = null;
    if (!payload || !hasNative()) return;

    var destFolder = targetFolderPath || '';

    if (payload.type === 'note') {
      var oldRel = payload.path;
      var fileName = oldRel.split('/').pop();
      var newRel = destFolder ? (destFolder + '/' + fileName) : fileName;

      if (oldRel === newRel) return;

      var ok = window.NativeBridge.moveItem(oldRel, newRel);
      if (ok) {
        var nIdx = state.noteOrder.indexOf(oldRel);
        if (nIdx !== -1) state.noteOrder.splice(nIdx, 1);
        state.noteOrder.push(newRel);
        sheetMetaMove(oldRel, newRel, false);
        saveOrderConfigToNative();

        if (state.activeRelPath === oldRel) {
          state.activeRelPath = newRel;
        }
        state.selectedFolder = destFolder;
        expandAllParentFolders(destFolder);
        loadVaultFromNative(true);
        updateSaveStatus('파일 이동 완료: ' + newRel);
      } else {
        showModal('이동 불가', '대상 폴더에 동일한 이름의 파일이 이미 존재합니다.', null, true);
      }
    } else if (payload.type === 'folder') {
      var srcFolder = payload.path;
      var folderBaseName = srcFolder.split('/').pop();
      var newFolderRel = destFolder ? (destFolder + '/' + folderBaseName) : folderBaseName;

      if (srcFolder === destFolder || srcFolder === newFolderRel || (destFolder && destFolder.indexOf(srcFolder + '/') === 0)) {
        return;
      }

      var okFolder = window.NativeBridge.moveItem(srcFolder, newFolderRel);
      if (okFolder) {
        var fIdx = state.folderOrder.indexOf(srcFolder);
        if (fIdx !== -1) state.folderOrder.splice(fIdx, 1);
        state.folderOrder.push(newFolderRel);
        sheetMetaMove(srcFolder, newFolderRel, true);
        saveOrderConfigToNative();

        if (state.activeRelPath && state.activeRelPath.indexOf(srcFolder + '/') === 0) {
          state.activeRelPath = newFolderRel + state.activeRelPath.slice(srcFolder.length);
        }
        state.selectedFolder = newFolderRel;
        expandAllParentFolders(newFolderRel);
        loadVaultFromNative(true);
        updateSaveStatus('폴더 이동 완료: ' + newFolderRel);
      } else {
        showModal('폴더 이동 불가', '대상 위치에 동일한 이름의 폴더가 이미 존재합니다.', null, true);
      }
    }
  }

  function loadVaultFromNative(keepSelection) {
    if (!hasNative()) return;
    try {
      var rawJson = window.NativeBridge.getVaultStateJSON();
      var data = JSON.parse(rawJson);
      state.vaultPath = data.vaultPath || '';
      state.vaultName = data.vaultName || 'TypeGrapher';

      var savedOrderObj = null;
      if (data.orderConfigJSON) {
        try { savedOrderObj = JSON.parse(data.orderConfigJSON); } catch (e) {}
      }

      reconcileOrdersAndPreserveAppend(data.folders || [], data.notes || [], savedOrderObj);
      /* 사이드바 폴더는 닫힌 상태가 기본이다.
         - 앱을 처음 열었을 때, 다른 보관함으로 바꿨을 때: 모든 폴더를 닫힌 상태로 시작한다.
         - 같은 보관함을 다시 읽을 때(새로고침 · 동기화 · 노트 이동 등): 사용자가 펼쳐 둔 상태는 그대로 두고,
           새로 나타난 폴더만 닫힌 상태로 넣는다. (새 노트 · 새 폴더 · 이동처럼 사용자가 방금 한 동작은
           이 함수를 부르기 전에 해당 폴더를 펼침으로 표시해 두므로 그대로 펼쳐져 보인다.) */
      if (state.foldersInitializedFor !== state.vaultPath) {
        state.collapsedFolders = {};
        state.foldersInitializedFor = state.vaultPath;
      }
      for (var cfi = 0; cfi < state.folders.length; cfi++) {
        if (!state.collapsedFolders.hasOwnProperty(state.folders[cfi])) {
          state.collapsedFolders[state.folders[cfi]] = true;
        }
      }
      elVaultName.innerHTML = '📕 ' + escapeHtml(state.vaultName.toUpperCase()) + ' ▾';

      if (data.theme === 'light') {
        document.body.className = 'theme-light';
      } else {
        document.body.className = 'theme-dark';
      }

      if (state.selectedFolder) {
        var folderStillExists = false;
        for (var f = 0; f < state.folders.length; f++) {
          if (state.folders[f] === state.selectedFolder) {
            folderStillExists = true;
            break;
          }
        }
        if (!folderStillExists) state.selectedFolder = '';
      }

      var found = false;
      if (keepSelection && state.activeRelPath) {
        for (var i = 0; i < state.notes.length; i++) {
          if (state.notes[i].relPath === state.activeRelPath) {
            found = true;
            break;
          }
        }
      }
      if (!found) {
        state.activeRelPath = state.notes.length > 0 ? state.notes[0].relPath : null;
      }
      updateSelectedFolderUI();
      renderSidebar();
      renderActiveNote();
      updateSaveStatus('저장 위치: ' + state.vaultPath);
    } catch (e) {
      elSaveStatus.innerHTML = '보관함 로드 오류: ' + e;
    }
  }

  function updateSelectedFolderUI() {
    if (state.selectedFolder) {
      elActiveFolderLabel.innerHTML = '📁 선택 폴더: <b>' + escapeHtml(state.selectedFolder) + '</b>';
    } else {
      elActiveFolderLabel.innerHTML = '📍 위치: 기본 보관함 (루트)';
    }
  }

  function updateSaveStatus(customMsg) {
    var now = new Date();
    var timeStr = ('0' + now.getHours()).slice(-2) + ':' +
                  ('0' + now.getMinutes()).slice(-2) + ':' +
                  ('0' + now.getSeconds()).slice(-2);
    if (customMsg) {
      elSaveStatus.innerHTML = escapeHtml(customMsg);
    } else if (state.activeRelPath) {
      elSaveStatus.innerHTML = '문서/TypeGrapher/' + escapeHtml(state.activeRelPath) + ' 저장됨 (' + timeStr + ')';
    } else {
      elSaveStatus.innerHTML = '문서/TypeGrapher 대기 중';
    }
  }

  function getActiveNote() {
    for (var i = 0; i < state.notes.length; i++) {
      if (state.notes[i].relPath === state.activeRelPath) {
        return state.notes[i];
      }
    }
    return null;
  }

  function syncEditorToDisk() {
    var note = getActiveNote();
    if (!note) {
      var rawCheck = getEditorMarkdown();
      if (rawCheck && rawCheck.trim().length > 0) {
        createNewNote('새 노트 1', rawCheck);
      }
      return;
    }
    var md = getEditorMarkdown();
    note.content = md;
    note.updatedAt = new Date().getTime();
    updateStats(md);
    if (hasNative()) {
      window.NativeBridge.saveNote(note.relPath, md);
    }
    updateSaveStatus();
  }

  function createNoteItemDOM(note, depth) {
    var li = document.createElement('li');
    li.className = 'note-item' + (note.relPath === state.activeRelPath ? ' active' : '');
    li.style.paddingLeft = (16 + depth * 18) + 'px';
    li.setAttribute('draggable', 'true');
    li.setAttribute('data-tg-kind', 'note');
    li.setAttribute('data-tg-path', note.relPath);

    var titleText = note.title ? escapeHtml(note.title) : '제목 없는 노트';
    var dateText = formatDateTime(note.updatedAt);

    li.innerHTML = '<div class="note-item-title">' + titleText + '</div><span class="note-item-date">' + dateText + '</span>';

    li.onclick = (function (rPath, folderName) {
      return function (e) {
        if (e && e.stopPropagation) e.stopPropagation();
        else if (window.event) window.event.cancelBubble = true;
        state.selectionTargetType = 'note';
        state.selectedFolder = folderName || '';
        updateSelectedFolderUI();
        selectNote(rPath);
      };
    })(note.relPath, note.folder);

    li.ondragstart = (function (rPath, fName) {
      return function (e) {
        state.dragPayload = { type: 'note', path: rPath, name: fName };
        this.className += ' dragging-item';
        if (e.dataTransfer) {
          e.dataTransfer.effectAllowed = 'move';
          try { e.dataTransfer.setData('text/plain', 'note:' + rPath); } catch (err) {}
        }
      };
    })(note.relPath, note.filename);

    li.ondragend = function () {
      this.className = this.className.replace(/\bdragging-item\b/g, '').trim();
    };

    li.ondragover = (function (parentFolder) {
      return function (e) {
        if (!state.dragPayload) return;
        e.preventDefault();
        if (e.dataTransfer) e.dataTransfer.dropEffect = 'move';
        if (this.className.indexOf('drag-over-target') === -1) {
          this.className += ' drag-over-target';
        }
      };
    })(note.folder || '');

    li.ondragleave = function () {
      this.className = this.className.replace(/\bdrag-over-target\b/g, '').trim();
    };

    li.ondrop = (function (parentFolder) {
      return function (e) {
        e.preventDefault();
        e.stopPropagation();
        this.className = this.className.replace(/\bdrag-over-target\b/g, '').trim();
        executeDropMove(parentFolder);
      };
    })(note.folder || '');

    return li;
  }

  function renderFolderTreeRecursive(folderPath, depth, q) {
    var totalMatchingNotes = countNotesInSubtree(folderPath, q);
    var childFolders = getDirectChildFolders(folderPath);

    if (q && totalMatchingNotes === 0 && folderPath.toLowerCase().indexOf(q) === -1) {
      return;
    }

    var shortName = folderPath.split('/').pop();
    var isCollapsed = !!state.collapsedFolders[folderPath] && !q;
    var arrowChar = isCollapsed ? '&#9656;' : '&#9662;';

    var folderLi = document.createElement('li');
    folderLi.className = 'folder-header' + (state.selectedFolder === folderPath ? ' selected-folder' : '');
    folderLi.style.paddingLeft = (10 + depth * 18) + 'px';
    folderLi.setAttribute('draggable', 'true');
    folderLi.setAttribute('data-tg-kind', 'folder');
    folderLi.setAttribute('data-tg-path', folderPath);

    var leftSpan = document.createElement('span');
    leftSpan.className = 'folder-title-wrap';
    leftSpan.innerHTML =
      '<span class="folder-toggle-arrow">' + arrowChar + '</span>' +
      '<span>' + escapeHtml(shortName) + '</span>';

    var rightWrap = document.createElement('div');
    rightWrap.className = 'folder-right-controls';

    var addSubBtn = document.createElement('button');
    addSubBtn.className = 'folder-action-mini-btn';
    addSubBtn.title = '[' + folderPath + '] 폴더 안에 새 하위 폴더 넣기';
    addSubBtn.innerHTML = '+';
    addSubBtn.onclick = (function (targetParent) {
      return function (e) {
        if (e && e.stopPropagation) e.stopPropagation();
        else if (window.event) window.event.cancelBubble = true;
        state.selectedFolder = targetParent;
        state.selectionTargetType = 'folder';
        state.collapsedFolders[targetParent] = false;
        updateSelectedFolderUI();
        renderSidebar();
        promptCreateSubfolder(targetParent);
      };
    })(folderPath);

    var delFolderBtn = document.createElement('button');
    delFolderBtn.className = 'folder-action-mini-btn';
    delFolderBtn.title = '[' + folderPath + '] 폴더 삭제';
    delFolderBtn.innerHTML = '&times;';
    delFolderBtn.onclick = (function (targetFolder) {
      return function (e) {
        if (e && e.stopPropagation) e.stopPropagation();
        else if (window.event) window.event.cancelBubble = true;
        confirmDeleteFolder(targetFolder);
      };
    })(folderPath);

    var badgeSpan = document.createElement('span');
    badgeSpan.className = 'folder-badge';
    badgeSpan.innerHTML = String(totalMatchingNotes);

    rightWrap.appendChild(addSubBtn);
    rightWrap.appendChild(delFolderBtn);
    rightWrap.appendChild(badgeSpan);

    folderLi.appendChild(leftSpan);
    folderLi.appendChild(rightWrap);

    folderLi.onclick = (function (fPath) {
      return function (e) {
        if (e && e.stopPropagation) e.stopPropagation();
        else if (window.event) window.event.cancelBubble = true;

        state.selectionTargetType = 'folder';
        state.selectedFolder = fPath;

        var willCollapse = !state.collapsedFolders[fPath];
        state.collapsedFolders[fPath] = willCollapse;

        if (willCollapse) {
          var subPrefix = fPath + '/';
          for (var s = 0; s < state.folders.length; s++) {
            var cand = state.folders[s];
            if (cand.indexOf(subPrefix) === 0) {
              state.collapsedFolders[cand] = true;
            }
          }
        }

        updateSelectedFolderUI();
        renderSidebar();
      };
    })(folderPath);

    folderLi.ondragstart = (function (fPath, sName) {
      return function (e) {
        state.dragPayload = { type: 'folder', path: fPath, name: sName };
        this.className += ' dragging-item';
        if (e.dataTransfer) {
          e.dataTransfer.effectAllowed = 'move';
          try { e.dataTransfer.setData('text/plain', 'folder:' + fPath); } catch (err) {}
        }
      };
    })(folderPath, shortName);

    folderLi.ondragend = function () {
      this.className = this.className.replace(/\bdragging-item\b/g, '').trim();
    };

    folderLi.ondragover = (function (targetFPath) {
      return function (e) {
        if (!state.dragPayload) return;
        if (state.dragPayload.type === 'folder') {
          if (state.dragPayload.path === targetFPath || targetFPath.indexOf(state.dragPayload.path + '/') === 0) {
            return;
          }
        }
        e.preventDefault();
        if (e.dataTransfer) e.dataTransfer.dropEffect = 'move';
        if (this.className.indexOf('drag-over-target') === -1) {
          this.className += ' drag-over-target';
        }
      };
    })(folderPath);

    folderLi.ondragleave = function () {
      this.className = this.className.replace(/\bdrag-over-target\b/g, '').trim();
    };

    folderLi.ondrop = (function (targetFPath) {
      return function (e) {
        e.preventDefault();
        e.stopPropagation();
        this.className = this.className.replace(/\bdrag-over-target\b/g, '').trim();
        executeDropMove(targetFPath);
      };
    })(folderPath);

    elNoteList.appendChild(folderLi);

    if (!isCollapsed) {
      for (var c = 0; c < childFolders.length; c++) {
        renderFolderTreeRecursive(childFolders[c], depth + 1, q);
      }

      for (var i = 0; i < state.notes.length; i++) {
        var n = state.notes[i];
        if (n.folder === folderPath) {
          if (q) {
            var mT = n.title.toLowerCase().indexOf(q) !== -1;
            var mB = n.content.toLowerCase().indexOf(q) !== -1;
            var mF = folderPath.toLowerCase().indexOf(q) !== -1;
            if (!mT && !mB && !mF) continue;
          }
          elNoteList.appendChild(createNoteItemDOM(n, depth + 1));
        }
      }
    }
  }

  function renderSidebar() {
    ctxClose();
    elNoteList.innerHTML = '';
    var q = state.searchQuery.toLowerCase();

    var topFolders = getDirectChildFolders('');
    for (var f = 0; f < topFolders.length; f++) {
      renderFolderTreeRecursive(topFolders[f], 0, q);
    }

    for (var k = 0; k < state.notes.length; k++) {
      var rootNote = state.notes[k];
      if (rootNote.folder && rootNote.folder !== '') continue;
      if (q) {
        var matchTitle = rootNote.title.toLowerCase().indexOf(q) !== -1;
        var matchBody = rootNote.content.toLowerCase().indexOf(q) !== -1;
        if (!matchTitle && !matchBody) continue;
      }
      elNoteList.appendChild(createNoteItemDOM(rootNote, 0));
    }

    elNoteCountBadge.innerHTML = String(state.notes.length);
  }

  function updateStats(text) {
    var content = text || '';
    var lines = content ? content.split('\n').length : 0;
    var trimmed = content.trim();
    var words = trimmed ? trimmed.split(/\s+/).length : 0;
    var chars = content.length;

    elStatLines.innerHTML = lines + ' 줄';
    elStatWords.innerHTML = words + ' 단어';
    elStatChars.innerHTML = chars + ' 글자';
  }

  function renderActiveNote() {
    var note = getActiveNote();
    if (!note) {
      elTitleInput.value = '';
      elTitleInput.title = '';
      elTitleInput.placeholder = '노트가 없습니다 (+ 새 노트 또는 일기를 눌러 작성하세요)';
      elNoteFolderBadge.style.display = 'none';
      elLiveEditor.innerHTML = '<p><br></p>';
      updateStats('');
      gridLoadText('');
      return;
    }
    elTitleInput.placeholder = '노트 제목 (.md 파일명)...';
    elTitleInput.value = note.title;
    elTitleInput.title = note.title;
    if (note.folder && note.folder !== '') {
      elNoteFolderBadge.style.display = 'inline-block';
      elNoteFolderBadge.innerHTML = '📁 ' + escapeHtml(note.folder);
    } else {
      elNoteFolderBadge.style.display = 'none';
    }
    if (isGridMode()) {
      elLiveEditor.innerHTML = '<p><br></p>';
      gridLoadText(note.content);
    } else {
      elLiveEditor.innerHTML = parseMarkdownToHTML(note.content);
    }
    updateStats(note.content);
    updateFocusAndTypewriterScroll();
  }

  function selectNote(relPath) {
    state.activeRelPath = relPath;
    renderSidebar();
    renderActiveNote();
    updateSaveStatus();
  }

  function buildRelPath(folder, filename) {
    return (folder && folder !== '') ? (folder + '/' + filename) : filename;
  }

  function expandAllParentFolders(folderPath) {
    if (!folderPath) return;
    var parts = folderPath.split('/');
    var cur = '';
    for (var i = 0; i < parts.length; i++) {
      cur = cur ? (cur + '/' + parts[i]) : parts[i];
      state.collapsedFolders[cur] = false;
    }
  }

  function createNewNote(customTitle, customContent) {
    var targetFolder = state.selectedFolder || '';
    var baseTitle = sanitizeSingleName(customTitle || ('새 노트 ' + (state.notes.length + 1)));
    var candidateTitle = baseTitle;
    var counter = 1;

    while (true) {
      var candidateRel = buildRelPath(targetFolder, candidateTitle + '.md');
      var exists = false;
      for (var i = 0; i < state.notes.length; i++) {
        if (state.notes[i].relPath.toLowerCase() === candidateRel.toLowerCase()) {
          exists = true;
          break;
        }
      }
      if (!exists) break;
      counter++;
      candidateTitle = baseTitle + ' ' + counter;
    }

    var finalRelPath = buildRelPath(targetFolder, candidateTitle + '.md');
    var body = (typeof customContent === 'string') ? customContent : '';

    if (hasNative()) {
      window.NativeBridge.saveNote(finalRelPath, body);
      state.noteOrder.push(finalRelPath);
      saveOrderConfigToNative();
      state.activeRelPath = finalRelPath;
      state.selectionTargetType = 'note';
      expandAllParentFolders(targetFolder);
      loadVaultFromNative(true);
    }
    placeCaretAtStart(elLiveEditor);
  }

  function openOrCreateDailyNoteForDate(dateObj) {
    var dTitle = formatKoreanDailyTitle(dateObj || new Date());
    var fname = dTitle + '.md';
    var targetFolder = state.selectedFolder || '';
    var preferredRel = buildRelPath(targetFolder, fname);

    for (var i = 0; i < state.notes.length; i++) {
      if (state.notes[i].relPath === preferredRel || state.notes[i].title === dTitle) {
        state.selectionTargetType = 'note';
        selectNote(state.notes[i].relPath);
        placeCaretAtEnd(elLiveEditor);
        return;
      }
    }

    if (hasNative()) {
      window.NativeBridge.saveNote(preferredRel, '');
      state.noteOrder.push(preferredRel);
      saveOrderConfigToNative();
      state.activeRelPath = preferredRel;
      state.selectionTargetType = 'note';
      expandAllParentFolders(targetFolder);
      loadVaultFromNative(true);
      placeCaretAtStart(elLiveEditor);
    }
  }

  function openOrCreateDailyNote() {
    openOrCreateDailyNoteForDate(new Date());
  }

  function promptCreateSubfolder(explicitParent) {
    var parentFolder = (typeof explicitParent === 'string') ? explicitParent : (state.selectedFolder || '');
    var locationDesc = parentFolder
      ? ('📂 상위 폴더: [' + parentFolder + ']\n이 폴더의 하단에 추가할 새 폴더 이름을 입력하세요:\n(팁: 맨 앞에 / 를 붙이면 최상위 루트 하단에 추가됩니다)')
      : '📍 생성 위치: 기본 보관함 (최상위 하단)\n새 폴더 이름을 입력하세요 (예: 일기장 또는 일기장/2026년):';

    showPromptModal(
      parentFolder ? '📁 폴더 안에 하위 폴더 추가' : '📁 새 폴더 하단 추가',
      locationDesc,
      parentFolder ? '하위 폴더 이름 입력...' : '폴더 이름 입력 (예: 일기장)...',
      '',
      function (rawInput) {
        if (!rawInput || !rawInput.trim()) return;
        var trimmed = rawInput.trim();
        var fullFolderPath = '';

        if (trimmed.charAt(0) === '/') {
          fullFolderPath = sanitizeFolderPath(trimmed.slice(1));
        } else if (parentFolder) {
          fullFolderPath = sanitizeFolderPath(parentFolder + '/' + trimmed);
        } else {
          fullFolderPath = sanitizeFolderPath(trimmed);
        }

        if (!fullFolderPath) return;

        if (hasNative()) {
          var ok = window.NativeBridge.createSubfolder(fullFolderPath);
          if (ok) {
            if (state.folderOrder.indexOf(fullFolderPath) === -1) {
              state.folderOrder.push(fullFolderPath);
              saveOrderConfigToNative();
            }
            state.selectedFolder = fullFolderPath;
            state.selectionTargetType = 'folder';
            expandAllParentFolders(fullFolderPath);
            loadVaultFromNative(true);
            updateSaveStatus('새 폴더 하단 추가 완료: ' + fullFolderPath);
          } else {
            showModal('폴더 생성 실패', '폴더를 생성할 수 없습니다.', null, true);
          }
        }
      }
    );
  }

  /* v2.7: 상단 제목칸에 글자를 넣고, 원고지 제목란(모든 장)에도 같은 글자를 비춘다 */
  function titleShow(text) {
    if (elTitleInput.value !== text) elTitleInput.value = text;
    elTitleInput.title = text;
    gridSyncHeadFields(null);
  }

  /* 제목 입력을 마쳤을 때(상단 제목칸이나 원고지 제목란에서 Enter 를 누르거나 다른 곳을 누름): 노트(.md 파일)의 이름을 바꾼다.
     두 제목칸은 같은 값을 보여 주므로, 결과(실제로 붙은 이름 또는 되돌린 이름)를 양쪽에 함께 반영한다. */
  function commitTitleRename() {
    var note = getActiveNote();
    if (!note || !hasNative()) return;
    var newTitle = sanitizeSingleName(elTitleInput.value);
    if (newTitle === note.title) {
      titleShow(note.title);
      return;
    }
    var oldRelPath = note.relPath;
    var newRelPath = buildRelPath(note.folder, newTitle + '.md');
    var ok = (oldRelPath.toLowerCase() === newRelPath.toLowerCase())
      ? moveItemRenaming(oldRelPath, newRelPath)             /* 대소문자만 바꾸는 경우 (v2.8) */
      : window.NativeBridge.renameNote(oldRelPath, newRelPath, note.content);
    if (ok) {
      var ordIdx = state.noteOrder.indexOf(oldRelPath);
      if (ordIdx !== -1) {
        state.noteOrder[ordIdx] = newRelPath;
      } else {
        state.noteOrder.push(newRelPath);
      }
      sheetMetaMove(oldRelPath, newRelPath, false);
      saveOrderConfigToNative();

      note.title = newTitle;
      note.filename = newTitle + '.md';
      note.relPath = newRelPath;
      state.activeRelPath = newRelPath;
      titleShow(newTitle);
      renderSidebar();
      updateSaveStatus('파일 이름 변경됨: ' + newRelPath);
    } else {
      titleShow(note.title);
      showModal('이름 변경 불가', '같은 이름의 노트가 이미 이 폴더에 있거나, 파일 이름으로 쓸 수 없는 제목입니다 (너무 긴 제목 포함).\n제목을 원래대로 되돌렸습니다.', null, true);
    }
  }

  function confirmDeleteFolder(folderRelPath) {
    if (!folderRelPath || folderRelPath === '') {
      showModal('기본 보관함 보호', '기본 저장소 루트 폴더(Documents/TypeGrapher) 자체는 삭제할 수 없습니다.', null, true);
      return;
    }
    var noteCount = countNotesInSubtree(folderRelPath, '');
    var descMsg = noteCount > 0
      ? ('"📁 ' + folderRelPath + '" 폴더와 그 안의 노트 ' + noteCount + '개를 모두 삭제하시겠습니까?\n(Enter를 누르면 즉시 삭제됩니다)')
      : ('빈 폴더 "📁 ' + folderRelPath + '"을(를) 파인더에서 삭제하시겠습니까?\n(Enter를 누르면 즉시 삭제됩니다)');

    showModal(
      '폴더 삭제 확인',
      descMsg,
      function () {
        if (hasNative()) {
          var ok = window.NativeBridge.deleteFolder(folderRelPath);
          if (ok) {
            sheetMetaDelete(folderRelPath, true);
            if (state.selectedFolder === folderRelPath || state.selectedFolder.indexOf(folderRelPath + '/') === 0) {
              state.selectedFolder = '';
            }
            if (state.activeRelPath && state.activeRelPath.indexOf(folderRelPath + '/') === 0) {
              state.activeRelPath = null;
            }
            state.selectionTargetType = 'note';
            loadVaultFromNative(false);
            updateSaveStatus('폴더 삭제 완료: ' + folderRelPath);
          }
        }
      },
      false
    );
  }

  function deleteSelectedItemOrNote() {
    if ((state.selectionTargetType === 'folder' && state.selectedFolder !== '') || (!getActiveNote() && state.selectedFolder !== '')) {
      confirmDeleteFolder(state.selectedFolder);
      return;
    }

    var note = getActiveNote();
    if (!note) {
      showModal('삭제할 항목 없음', '삭제할 파일이나 하위 폴더를 먼저 선택해 주세요.\n(기본 저장소인 Documents/TypeGrapher 루트 폴더는 삭제되지 않습니다.)', null, true);
      return;
    }

    showModal(
      '파인더(.md) 파일 삭제 확인 (Cmd + Delete)',
      '실제 파인더 폴더에서 "' + note.relPath + '" 파일을 삭제하시겠습니까?\n(Enter를 누르면 즉시 삭제됩니다)',
      function () {
        if (hasNative()) {
          window.NativeBridge.deleteNote(note.relPath);
          sheetMetaDelete(note.relPath, false);
          state.activeRelPath = null;
          loadVaultFromNative(false);
          updateSaveStatus('파일 삭제 완료');
        }
      },
      false
    );
  }

  /* ==========================================================================
     v2.1 공통 도우미 (클래스 토글 · 타이핑 글로우 · 현재 편집기의 마크다운 얻기)
     ========================================================================== */
  function isGridMode() {
    return state.paperStyle === 'grid';
  }

  function setCls(el, cls, on) {
    var padded = ' ' + (el.className || '') + ' ';
    var has = padded.indexOf(' ' + cls + ' ') !== -1;
    if (on && !has) {
      el.className = (el.className ? el.className + ' ' : '') + cls;
    } else if (!on && has) {
      el.className = padded.replace(' ' + cls + ' ', ' ').replace(/^\s+|\s+$/g, '');
    }
  }

  var typingGlowTimer = null;

  function applyGridPaperClass() {
    var cls = 'ms-grid';
    if (state.focusMode) cls += ' focus-on';
    if (state.typingNow) cls += ' typing-now';
    if (gridFocused) cls += ' focused';
    if (elGridPaper.className !== cls) elGridPaper.className = cls;
  }

  function applyTypingGlowClass() {
    setCls(elLiveEditor, 'typing-now', state.typingNow);
    applyGridPaperClass();
  }

  /* 집중 모드에서 글자를 입력하는 순간 글로우를 밝히고, 1.1초 동안 입력이 없으면 서서히 되돌립니다 */
  function markTypingActivity() {
    if (!state.focusMode) return;
    if (!state.typingNow) {
      state.typingNow = true;
      applyTypingGlowClass();
    }
    if (typingGlowTimer) clearTimeout(typingGlowTimer);
    typingGlowTimer = setTimeout(function () {
      typingGlowTimer = null;
      state.typingNow = false;
      applyTypingGlowClass();
    }, 1100);
  }

  function getEditorMarkdown() {
    return isGridMode() ? elGridInput.value : serializeDOMToMarkdown(elLiveEditor);
  }

  /* ==========================================================================
     v2.1 원고지(칸) 편집기: 20×20 칸에 한 글자씩
     - 실제 입력은 보이지 않는 textarea(#gridInput)가 받습니다. 그래서 한글 조합, 실행 취소,
       복사/붙여넣기가 그대로 동작하고, 화면에는 그 내용을 한 칸에 한 글자씩 그려 줍니다.
     - 원고지 쓰기 관행: 한글·한자·영문 대문자·문장부호·빈칸은 한 칸에 하나,
       두 자 이상 이어지는 아라비아 숫자와 영문 소문자는 같은 종류끼리 한 칸에 두 자
       (낱자 하나만 있으면 한 칸에 한 자), 마침표·쉼표는 칸의 왼쪽 아래.
     - 글자를 칸마다 따로 그리므로 글꼴 폭과 무관하게 격자와 글자가 항상 맞습니다.
     ========================================================================== */
  var GRID_COLS = 20;
  var GRID_ROWS_PER_PAGE = 20;
  var gridLayout = null;
  var gridLayoutText = null;
  var gridRowEls = [];    /* #gridPaper 의 자식 줄 요소 (본문 줄 + 장을 채우는 빈 줄) */
  var gridRowSig = [];    /* 줄 내용 서명: 커서·선택이 없는 '평범한' 줄이면 그 줄의 원문, 아니면 null */
  var gridRowHtml = [];
  var gridRowCls = [];
  var gridTextRows = 0;   /* gridRowEls 중 본문 줄의 개수 (나머지는 빈 줄) */
  var gridCaretEl = document.createElement('div');   /* 현재 칸 표시 + 깜박이는 커서 (줄 위에 겹쳐 그림) */
  gridCaretEl.className = 'ms-caret';
  var gridHeadEls = [];   /* 장마다 하나: 머리말(제목 입력칸 + 조판 때만 쓰는 날짜 자리). 그 장의 첫 줄 요소 안에 붙인다 */
  var gridFootEls = [];   /* 장마다 하나: 꼬리말 가운데의 쪽 번호. 그 장의 마지막 줄 요소 안에 붙인다 */
  var elGridTitleMeasure = document.getElementById('gridTitleMeasure');
  var gridCellPx = 0;
  var gridForcedCell = 0;   /* 조판(인쇄 · PDF) 중에는 창 너비와 무관하게 이 칸 크기를 쓴다 (0 = 자동) */
  var gridCompLen = 0;
  var gridFocused = false;
  var gridRenderTimer = null;
  var gridScrollWanted = false;
  var gridDragAnchor = -1;
  var gridDragStartX = 0;
  var gridDragStartY = 0;
  var gridDragMoved = false;
  var GRID_EMPTY_ROW = (function () {
    var s = '';
    for (var i = 0; i < GRID_COLS; i++) s += '<span class="c"></span>';
    return s;
  })();

  /* 칸 크기를 작업 영역 너비에 맞춰 정수 px 로 계산 (20칸이 항상 한 줄에 들어가도록) */
  function refreshGridMetrics() {
    if (!isGridMode() && gridForcedCell <= 0) return;
    var avail = elScrollContainer.clientWidth - 96;
    if (avail > 820) avail = 820;
    var cell = Math.floor((avail - 2) / GRID_COLS);
    if (cell > 40) cell = 40;
    if (cell < 14) cell = 14;
    if (gridForcedCell > 0) cell = gridForcedCell;
    if (cell === gridCellPx) return;
    gridCellPx = cell;

    var font = Math.round(cell * 0.62);
    var gap = Math.max(4, Math.round(cell * 0.3));
    var titleFont = Math.max(12, Math.min(17, Math.round(cell * 0.46)));
    var css =
      '.ms-grid{font-size:' + cell + 'px;}' +
      '.ms-grid .ms-row{height:' + cell + 'px;padding-top:' + gap + 'px;}' +
      '.ms-grid .ms-row:nth-child(20n){padding-bottom:' + gap + 'px;}' +
      '.ms-grid .c{width:' + cell + 'px;height:' + cell + 'px;line-height:' + (cell - 2) + 'px;font-size:' + font + 'px;}' +
      '.ms-grid .ms-caret{width:' + cell + 'px;height:' + cell + 'px;top:' + gap + 'px;}' +
      '.ms-grid .ms-title{font-size:' + titleFont + 'px;}';
    elGridTitleMeasure.style.fontSize = titleFont + 'px';
    var styleEl = document.getElementById('gridDynStyle');
    if (styleEl.styleSheet) {
      styleEl.styleSheet.cssText = css;
    } else {
      styleEl.innerHTML = '';
      styleEl.appendChild(document.createTextNode(css));
    }
    elGridSurface.style.width = (cell * GRID_COLS + 2) + 'px';
    gridSyncHeadFields(null);
  }

  /* 한 칸에 두 자씩 쓰는 글자 종류: 1 = 아라비아 숫자, 2 = 영문 소문자, 0 = 해당 없음.
     숫자와 영문자가 만나면 성격이 다르므로 한 칸에 섞어 쓰지 않는다. */
  function gridHalfKind(code) {
    if (code >= 48 && code <= 57) return 1;
    if (code >= 97 && code <= 122) return 2;
    return 0;
  }

  /* 앞 글자와 한 칸에 합쳐야 하는 부호인지 (결합 문자, 이모지 연결자, 조합형 한글 자모 등) */
  function gridIsJoiner(text, i, unitLen, code) {
    if (unitLen === 1) {
      if (code >= 0x0300 && code <= 0x036F) return true;
      if (code === 0x200D || code === 0xFE0F || code === 0xFE0E || code === 0x20E3) return true;
      if (code >= 0x1160 && code <= 0x11FF) return true;
      return false;
    }
    var lo = text.charCodeAt(i + 1);
    return code === 0xD83C && lo >= 0xDFFB && lo <= 0xDFFF;
  }

  /* 본문 → 원고지 줄/칸 배치. pr/pc/ps 는 커서 위치(문자 인덱스)별 줄·칸·칸 안 위치(0=왼쪽, 1=가운데) */
  function computeGridLayout(text) {
    var rows = [], pr = [], pc = [], ps = [];
    var len = text.length, i = 0, para = 0, k;
    var cur = { para: 0, cells: [], start: 0, end: 0 };
    var last = null;

    while (i < len) {
      var code = text.charCodeAt(i);

      if (code === 10) {
        pr[i] = rows.length; pc[i] = cur.cells.length; ps[i] = 0;
        cur.end = i;
        rows.push(cur);
        para++;
        cur = { para: para, cells: [], start: i + 1, end: i + 1 };
        last = null;
        i++;
        continue;
      }
      if (code === 13) {
        pr[i] = rows.length; pc[i] = cur.cells.length; ps[i] = 0;
        i++;
        continue;
      }

      var unitLen = 1;
      var low = 0;
      if (code >= 0xD800 && code <= 0xDBFF && i + 1 < len) {
        low = text.charCodeAt(i + 1);
        if (low >= 0xDC00 && low <= 0xDFFF) unitLen = 2;
      }
      var isRI = (unitLen === 2 && code === 0xD83C && low >= 0xDDE6 && low <= 0xDDFF);

      if (last && (last.zwj || gridIsJoiner(text, i, unitLen, code) || (isRI && last.ri === 1))) {
        if (last.k === 'h' && last.t2) last.t2 += text.substr(i, unitLen);
        else last.t += text.substr(i, unitLen);
        last.e = i + unitLen;
        last.zwj = (code === 0x200D);
        if (isRI) last.ri = 2;
        for (k = 0; k < unitLen; k++) {
          pr[i + k] = last.row; pc[i + k] = last.col; ps[i + k] = 0;
        }
        i += unitLen;
        continue;
      }

      if (cur.cells.length >= GRID_COLS) {
        cur.end = i;
        rows.push(cur);
        cur = { para: para, cells: [], start: i, end: i };
      }

      var rowIdx = rows.length, colIdx = cur.cells.length;
      var cell;
      var halfKind = (unitLen === 1) ? gridHalfKind(code) : 0;
      if (halfKind !== 0 && i + 1 < len && gridHalfKind(text.charCodeAt(i + 1)) === halfKind) {
        cell = { k: 'h', t: text.charAt(i), t2: text.charAt(i + 1), s: i, e: i + 2, row: rowIdx, col: colIdx, zwj: false, ri: 0 };
        pr[i] = rowIdx; pc[i] = colIdx; ps[i] = 0;
        pr[i + 1] = rowIdx; pc[i + 1] = colIdx; ps[i + 1] = 1;
        cur.cells.push(cell);
        last = cell;
        i += 2;
        continue;
      }
      cell = { k: 'f', t: text.substr(i, unitLen), t2: '', s: i, e: i + unitLen, row: rowIdx, col: colIdx, zwj: false, ri: (isRI ? 1 : 0) };
      for (k = 0; k < unitLen; k++) {
        pr[i + k] = rowIdx; pc[i + k] = colIdx; ps[i + k] = 0;
      }
      cur.cells.push(cell);
      last = cell;
      i += unitLen;
    }

    cur.end = len;
    rows.push(cur);
    if (cur.cells.length >= GRID_COLS) {
      /* 마지막 줄이 20칸으로 꽉 찼으면 다음 글자가 들어갈 새 줄 첫 칸에 커서를 둔다 */
      rows.push({ para: cur.para, cells: [], start: len, end: len });
      pr[len] = rows.length - 1; pc[len] = 0; ps[len] = 0;
    } else {
      pr[len] = rows.length - 1; pc[len] = cur.cells.length; ps[len] = 0;
    }
    return { rows: rows, pr: pr, pc: pc, ps: ps, len: len };
  }

  /* 한 줄(20칸)의 HTML. 커서는 여기 넣지 않고 따로 겹쳐 그리므로, 선택·조합 중이 아닌 줄은 내용만으로 결정됩니다 */
  function buildGridRowHtml(row, a, b, collapsed, compA, compB) {
    var h = [], c, cell, cls;
    for (c = 0; c < GRID_COLS; c++) {
      cell = row.cells[c];
      if (!cell) {
        h.push('<span class="c"></span>');
        continue;
      }
      cls = 'c';
      if (cell.s >= compA && cell.s < compB) cls += ' cmp';
      if (cell.k === 'h') {
        var s1 = (!collapsed && cell.s >= a && cell.s < b) ? ' class="sel"' : '';
        var s2 = (!collapsed && cell.t2 && (cell.s + 1) >= a && (cell.s + 1) < b) ? ' class="sel"' : '';
        h.push('<span class="' + cls + ' h"><i' + s1 + '>' + escapeHtml(cell.t) + '</i><i' + s2 + '>' + escapeHtml(cell.t2) + '</i></span>');
      } else {
        if (!collapsed && cell.s >= a && cell.s < b) cls += ' sel';
        if (cell.t === '.' || cell.t === ',' || cell.t === '\u3002' || cell.t === '\u3001') cls += ' pl';
        h.push('<span class="' + cls + '">' + escapeHtml(cell.t) + '</span>');
      }
    }
    return h.join('');
  }

  function gridMakeRowEl(cls, html) {
    var el = document.createElement('div');
    el.className = cls;
    el.innerHTML = '<div class="ms-cells">' + html + '</div>';
    return el;
  }

  /* ---- 원고지 머리말 값(제목) 저장소 (v2.6.1 까지 사용) ----
     v2.7 부터 원고지 제목란은 노트 제목을 그대로 보여 주고 고치므로, 이 저장소에는 더 이상 값을 넣지 않습니다
     (읽을 때 비웁니다: sheetMetaSanitize). 아래 함수들은 예전 설정과의 호환을 위해 남겨 둔 것입니다.
     state.sheetMeta[보관함 경로][노트 경로] = { t: 제목 }
     노트 본문(.md)은 건드리지 않고 앱 설정에 저장합니다. 앱에서 노트 이름을 바꾸거나 옮기면 따라갑니다.
     (v2.3 까지 있던 장별 No. 값 n 은 v2.4 에서 없어졌습니다. 쪽 번호는 꼬리말 가운데에 자동으로 찍힙니다.
      예전 설정에 남아 있는 n 은 읽을 때 버립니다.) */
  function sheetMetaVault(create) {
    if (!state.sheetMeta || typeof state.sheetMeta !== 'object') state.sheetMeta = {};
    var key = state.vaultPath || '';
    if (!state.sheetMeta[key] && create) state.sheetMeta[key] = {};
    return state.sheetMeta[key] || null;
  }

  function sheetMetaForActive(create) {
    var note = getActiveNote();
    if (!note) return null;
    var byVault = sheetMetaVault(create);
    if (!byVault) return null;
    var m = byVault[note.relPath];
    if (!m) {
      if (!create) return null;
      m = byVault[note.relPath] = { t: '' };
    }
    if (m.hasOwnProperty('n')) delete m.n;
    if (typeof m.t !== 'string') m.t = '';
    return m;
  }

  /* 저장된 설정을 읽은 직후: v2.7 부터 원고지 제목은 노트 제목을 그대로 쓰므로, 예전에 따로 저장하던 값은 모두 버린다 */
  function sheetMetaSanitize() {
    state.sheetMeta = {};
  }

  /* 제목이 비었으면 항목 자체를 지워 설정이 불어나지 않게 한다 */
  function sheetMetaPruneActive() {
    var note = getActiveNote();
    var byVault = sheetMetaVault(false);
    if (!note || !byVault || !byVault[note.relPath]) return;
    if (!byVault[note.relPath].t) delete byVault[note.relPath];
  }

  function sheetMetaMove(oldPath, newPath, isFolder) {
    var byVault = sheetMetaVault(false), k, changed = false;
    if (!byVault) return;
    if (!isFolder) {
      if (byVault.hasOwnProperty(oldPath)) {
        byVault[newPath] = byVault[oldPath];
        delete byVault[oldPath];
        changed = true;
      }
    } else {
      var prefix = oldPath + '/', moved = {};
      for (k in byVault) {
        if (byVault.hasOwnProperty(k) && k.indexOf(prefix) === 0) {
          moved[newPath + k.slice(oldPath.length)] = byVault[k];
          delete byVault[k];
          changed = true;
        }
      }
      for (k in moved) {
        if (moved.hasOwnProperty(k)) byVault[k] = moved[k];
      }
    }
    if (changed) saveOrderConfigToNative();
  }

  function sheetMetaDelete(path, isFolder) {
    var byVault = sheetMetaVault(false), k, changed = false;
    if (!byVault) return;
    if (!isFolder) {
      if (byVault.hasOwnProperty(path)) { delete byVault[path]; changed = true; }
    } else {
      var prefix = path + '/';
      for (k in byVault) {
        if (byVault.hasOwnProperty(k) && k.indexOf(prefix) === 0) { delete byVault[k]; changed = true; }
      }
    }
    if (changed) saveOrderConfigToNative();
  }

  /* 제목 입력칸 너비 = 글자 폭 + 여유. 붉은 밑줄(입력칸 아래 테두리)이 제목 길이만큼 늘어난다 */
  function gridTitleWidthFor(text) {
    var sheetW = gridCellPx * GRID_COLS;
    /* 화면에서는 원고지 폭 끝까지 늘어난다. 조판(인쇄 · PDF) 때는 오른쪽 위 날짜 자리를 남긴다 */
    var maxW = Math.max(80, sheetW - (gridForcedCell > 0 ? 150 : 8));
    var minW = Math.min(maxW, Math.max(64, Math.min(90, gridCellPx * 2)));   /* 빈 제목칸의 기본 밑줄 길이 */
    var measure = elGridTitleMeasure;
    while (measure.firstChild) measure.removeChild(measure.firstChild);
    measure.appendChild(document.createTextNode(text || '제목'));
    var w = measure.offsetWidth + 14;
    if (w < minW) w = minW;
    if (w > maxW) w = maxW;
    return w;
  }

  /* 모든 장의 제목란을 '노트 제목'으로 맞춘다 (skipEl: 지금 입력 중인 칸은 값을 덮어쓰지 않음).
     v2.7: 원고지 제목란과 상단의 노트 제목칸은 같은 값을 쓴다. 기준은 상단 제목칸(elTitleInput)에 지금 들어 있는
     글자다. 어느 쪽에서 입력하든 입력하는 대로 반대쪽에 비치고, 입력을 마치면 노트(파일) 이름이 바뀐다. */
  function gridSyncHeadFields(skipEl) {
    if (!isGridMode() || gridHeadEls.length === 0) return;
    var hasNote = !!getActiveNote();
    var title = hasNote ? elTitleInput.value : '';
    var w = gridTitleWidthFor(title) + 'px';
    var p, titleEl;
    for (p = 0; p < gridHeadEls.length; p++) {
      titleEl = gridHeadEls[p].firstChild;
      if (titleEl !== skipEl && titleEl.value !== title) titleEl.value = title;
      if (titleEl.style.width !== w) titleEl.style.width = w;
      titleEl.readOnly = !hasNote;
    }
  }

  function gridHeadKeydown(e) {
    var key = e.keyCode || e.which;
    /* Command + Delete: 입력칸 안에서는 '줄 처음까지 지우기'로만 동작 (노트 삭제 창이 뜨지 않게) */
    if ((e.metaKey || e.ctrlKey) && (key === 8 || key === 46)) {
      if (e.stopPropagation) e.stopPropagation();
      return;
    }
    /* Enter: 입력을 마치고(노트 이름 변경) 원고지 본문으로 돌아간다. Esc: 고치던 제목을 버리고 돌아간다 */
    if ((key === 13 || key === 27) && !state.isComposing) {
      e.preventDefault();
      if (key === 27) {
        var escNote = getActiveNote();
        if (escNote) {
          elTitleInput.value = escNote.title;
          gridSyncHeadFields(null);
        }
      }
      /* 이 키 입력이 문서 전체 단축키 처리로 올라가지 않게 한다 (이름을 바꿀 수 없어 알림창이 뜬 경우,
         같은 Enter 가 그 알림창의 '확인'까지 눌러 버려 알림을 볼 수 없게 되는 것을 막는다) */
      if (e.stopPropagation) e.stopPropagation();
      this.blur();
      if (!state.isModalOpen) {
        gridFocusInput();
        scheduleGridRender(false);
      }
    }
  }

  function gridMakeHeadEl() {
    var head = document.createElement('div');
    head.className = 'ms-head';
    /* 제목 입력칸 + 날짜 자리(조판에서 자동 표기를 켰을 때만 글자가 들어가고, 화면에서는 보이지 않는다) */
    head.innerHTML =
      '<input type="text" class="ms-title" placeholder="제목" spellcheck="false" autocomplete="off" title="원고지 제목 = 노트 제목 (글자 길이에 맞춰 붉은 밑줄이 늘어납니다. 고치면 노트 이름도 바뀝니다)">' +
      '<span class="ms-date"></span>';
    var titleEl = head.firstChild;

    titleEl.oninput = function () {
      if (!getActiveNote()) { titleEl.value = ''; return; }
      elTitleInput.value = titleEl.value;       /* 입력하는 대로 상단 제목칸과 다른 장의 제목란에 비춘다 */
      gridSyncHeadFields(titleEl);
    };
    /* 입력을 마치면(다른 곳을 누르거나 Enter) 상단 제목칸에서 고친 것과 똑같이 노트 이름을 바꾼다 */
    titleEl.onchange = commitTitleRename;
    titleEl.onblur = commitTitleRename;
    titleEl.onkeydown = gridHeadKeydown;
    return head;
  }

  /* 꼬리말 가운데에 찍히는 쪽 번호 글자 (page: 1부터) */
  function gridPageLabel(page) {
    return '- ' + page + ' -';
  }

  function gridMakeFootEl(page) {
    var foot = document.createElement('div');
    foot.className = 'ms-foot-no';
    foot.appendChild(document.createTextNode(gridPageLabel(page)));
    return foot;
  }

  /* 장 수에 맞춰 머리말(제목)과 꼬리말 쪽 번호 요소를 만들고, 각 장의 첫 줄 / 마지막 줄 요소에 붙인다
     (줄이 끼워지거나 빠져 그 장의 첫 줄 · 마지막 줄이 바뀌면 옮겨 붙임) */
  function gridAttachHeads() {
    var pages = Math.floor(gridRowEls.length / GRID_ROWS_PER_PAGE);
    var changed = false, p, host, old;
    while (gridHeadEls.length > pages) {
      old = gridHeadEls.pop();
      if (old.parentNode) old.parentNode.removeChild(old);
      changed = true;
    }
    while (gridHeadEls.length < pages) {
      gridHeadEls.push(gridMakeHeadEl());
      changed = true;
    }
    while (gridFootEls.length > pages) {
      old = gridFootEls.pop();
      if (old.parentNode) old.parentNode.removeChild(old);
    }
    while (gridFootEls.length < pages) {
      gridFootEls.push(gridMakeFootEl(gridFootEls.length + 1));
    }
    for (p = 0; p < pages; p++) {
      host = gridRowEls[p * GRID_ROWS_PER_PAGE];
      if (gridHeadEls[p].parentNode !== host) host.appendChild(gridHeadEls[p]);
      host = gridRowEls[p * GRID_ROWS_PER_PAGE + GRID_ROWS_PER_PAGE - 1];
      if (gridFootEls[p].parentNode !== host) host.appendChild(gridFootEls[p]);
    }
    if (changed) gridSyncHeadFields(null);
  }

  /* 원고지 다시 그리기.
     이전 화면과 비교해 앞쪽·뒤쪽의 '그대로인 줄'은 건드리지 않고, 가운데 바뀐 줄만 고쳐 쓰거나
     끼워 넣거나 빼냅니다. (긴 글 중간에 한 줄이 늘어나도 뒤쪽 줄을 전부 다시 그리지 않도록) */
  function renderGrid(wantScroll) {
    if (!isGridMode()) return;
    var text = elGridInput.value;
    if (!gridLayout || gridLayoutText !== text) {
      gridLayout = computeGridLayout(text);
      gridLayoutText = text;
    }
    var lay = gridLayout;
    var len = lay.len;
    var a = elGridInput.selectionStart || 0;
    var b = elGridInput.selectionEnd || 0;
    if (a > len) a = len;
    if (b > len) b = len;
    if (a > b) { var tmp = a; a = b; b = tmp; }
    if (state.isComposing) a = b;
    var collapsed = (a === b);
    var fi = (elGridInput.selectionDirection === 'backward') ? a : b;
    var cRow = lay.pr[fi], cCol = lay.pc[fi], cSub = lay.ps[fi];
    var activePara = lay.rows[cRow] ? lay.rows[cRow].para : -1;

    var compA = -1, compB = -1;
    if (state.isComposing && gridCompLen > 0 && collapsed) {
      compB = a;
      compA = Math.max(0, a - gridCompLen);
    }

    var rows = lay.rows, N = rows.length, O = gridTextRows;
    var newSig = new Array(N), newCls = new Array(N);
    var r, row, touched;
    for (r = 0; r < N; r++) {
      row = rows[r];
      touched = (!collapsed && row.start < b && row.end > a) ||
                (compB > compA && row.start < compB && row.end > compA);
      newSig[r] = touched ? null : text.substring(row.start, row.end);
      newCls[r] = (state.focusMode && row.para === activePara) ? 'ms-row act' : 'ms-row';
    }

    var lim = Math.min(O, N);
    var P = 0;
    while (P < lim && newSig[P] !== null && newSig[P] === gridRowSig[P] && newCls[P] === gridRowCls[P]) P++;
    var S = 0;
    while (S < lim - P && newSig[N - 1 - S] !== null && newSig[N - 1 - S] === gridRowSig[O - 1 - S] &&
           newCls[N - 1 - S] === gridRowCls[O - 1 - S]) S++;

    var midOld = O - P - S, midNew = N - P - S;
    var common = Math.min(midOld, midNew);
    var k, idx, el, html;

    for (k = 0; k < common; k++) {
      idx = P + k;
      html = buildGridRowHtml(rows[idx], a, b, collapsed, compA, compB);
      el = gridRowEls[idx];
      if (gridRowHtml[idx] !== html) { el.firstChild.innerHTML = html; gridRowHtml[idx] = html; }
      if (gridRowCls[idx] !== newCls[idx]) { el.className = newCls[idx]; gridRowCls[idx] = newCls[idx]; }
      gridRowSig[idx] = newSig[idx];
    }

    if (midNew > midOld) {
      /* 줄이 늘어남: 바뀌지 않은 뒷부분(또는 빈 줄) 바로 앞에 새 줄 요소를 끼워 넣는다 */
      var at = P + midOld;
      var ref = gridRowEls[at] || null;
      var addEls = [], addSig = [], addHtml = [], addCls = [];
      for (k = common; k < midNew; k++) {
        idx = P + k;
        html = buildGridRowHtml(rows[idx], a, b, collapsed, compA, compB);
        el = gridMakeRowEl(newCls[idx], html);
        elGridPaper.insertBefore(el, ref);
        addEls.push(el); addSig.push(newSig[idx]); addHtml.push(html); addCls.push(newCls[idx]);
      }
      gridRowEls = gridRowEls.slice(0, at).concat(addEls, gridRowEls.slice(at));
      gridRowSig = gridRowSig.slice(0, at).concat(addSig, gridRowSig.slice(at));
      gridRowHtml = gridRowHtml.slice(0, at).concat(addHtml, gridRowHtml.slice(at));
      gridRowCls = gridRowCls.slice(0, at).concat(addCls, gridRowCls.slice(at));
    } else if (midOld > midNew) {
      /* 줄이 줄어듦: 남는 줄 요소를 빼낸다 */
      var from = P + midNew, rm = midOld - midNew;
      for (k = 0; k < rm; k++) elGridPaper.removeChild(gridRowEls[from + k]);
      gridRowEls.splice(from, rm);
      gridRowSig.splice(from, rm);
      gridRowHtml.splice(from, rm);
      gridRowCls.splice(from, rm);
    }
    gridTextRows = N;

    /* 마지막 장을 20줄로 채우는 빈 줄 개수 맞추기 */
    var total = Math.ceil(N / GRID_ROWS_PER_PAGE) * GRID_ROWS_PER_PAGE;
    while (gridRowEls.length < total) {
      el = gridMakeRowEl('ms-row', GRID_EMPTY_ROW);
      elGridPaper.appendChild(el);
      gridRowEls.push(el); gridRowSig.push(null); gridRowHtml.push(GRID_EMPTY_ROW); gridRowCls.push('ms-row');
    }
    while (gridRowEls.length > total) {
      elGridPaper.removeChild(gridRowEls.pop());
      gridRowSig.pop(); gridRowHtml.pop(); gridRowCls.pop();
    }
    gridAttachHeads();

    /* 커서(현재 칸) 겹쳐 그리기: 줄 내용과 분리되어 있어 커서만 움직일 때는 줄을 다시 그리지 않는다.
       매번 다시 붙이므로 입력 직후에는 깜박임이 처음(켜진 상태)부터 다시 시작된다. */
    var rowEl = gridRowEls[cRow];
    if (!rowEl) return;
    if (collapsed) {
      gridCaretEl.className = 'ms-caret' + (cCol >= GRID_COLS ? ' end' : (cSub === 1 ? ' mid' : ''));
      gridCaretEl.style.left = (Math.min(cCol, GRID_COLS - 1) * gridCellPx) + 'px';
      gridCaretEl.setAttribute('data-col', String(cCol));
      rowEl.appendChild(gridCaretEl);
    } else if (gridCaretEl.parentNode) {
      gridCaretEl.parentNode.removeChild(gridCaretEl);
    }

    /* 보이지 않는 입력창을 커서 칸 위치로 옮겨 둔다 (한자 변환 후보 창 등이 그 자리에 뜨도록) */
    var rowRect = rowEl.getBoundingClientRect();
    var surfRect = elGridSurface.getBoundingClientRect();
    var inTop = Math.round(rowRect.bottom - gridCellPx - surfRect.top) + 'px';
    var inLeft = (Math.min(cCol, GRID_COLS - 1) * gridCellPx) + 'px';
    if (elGridInput.style.top !== inTop) elGridInput.style.top = inTop;
    if (elGridInput.style.left !== inLeft) elGridInput.style.left = inLeft;

    if (!wantScroll) return;
    var contRect = elScrollContainer.getBoundingClientRect();
    if (state.focusMode) {
      /* 타자기 롤러 중앙 고정 스크롤 */
      var diff = (rowRect.top + rowRect.height * 0.5) - (contRect.top + contRect.height * 0.45);
      if (Math.abs(diff) > 18) elScrollContainer.scrollTop += diff * 0.65;
    } else {
      var margin = gridCellPx;
      if (rowRect.top < contRect.top + margin) {
        elScrollContainer.scrollTop -= (contRect.top + margin - rowRect.top);
      } else if (rowRect.bottom > contRect.bottom - margin) {
        elScrollContainer.scrollTop += (rowRect.bottom - (contRect.bottom - margin));
      }
    }
  }

  function scheduleGridRender(wantScroll) {
    if (wantScroll) gridScrollWanted = true;
    if (gridRenderTimer) return;
    gridRenderTimer = setTimeout(function () {
      gridRenderTimer = null;
      var ws = gridScrollWanted;
      gridScrollWanted = false;
      renderGrid(ws);
    }, 0);
  }

  /* 보이지 않는 입력창에 포커스. 입력창은 마지막 커서 칸에 놓여 있으므로, 브라우저가 포커스를 주면서
     그 위치로 화면을 스크롤해 버리지 않게 한다 (스크롤은 renderGrid 가 직접 관리). */
  function gridFocusInput() {
    if (document.activeElement === elGridInput) return;
    try {
      elGridInput.focus({ preventScroll: true });
    } catch (err) {
      elGridInput.focus();
    }
  }

  function gridSetSel(start, end, dir) {
    try {
      if (dir) elGridInput.setSelectionRange(start, end, dir);
      else elGridInput.setSelectionRange(start, end);
    } catch (err) {
      try { elGridInput.setSelectionRange(start, end); } catch (err2) {}
    }
  }

  function gridSetRange(anchor, focus) {
    if (focus < anchor) gridSetSel(focus, anchor, 'backward');
    else gridSetSel(anchor, focus, 'forward');
  }

  /* (줄, 가로 위치[칸 단위]) → 문자 인덱스 */
  function gridIndexAtRowX(r, x, nearest) {
    var lay = gridLayout;
    if (r < 0) return 0;
    if (r >= lay.rows.length) return lay.len;
    var row = lay.rows[r];
    var n = row.cells.length;
    if (x < 0) x = 0;
    var col = Math.floor(x);
    if (col >= n) {
      if (n >= GRID_COLS) return nearest ? row.cells[n - 1].e : row.cells[n - 1].s;
      return row.end;
    }
    var cell = row.cells[col];
    var frac = x - col;
    if (cell.k === 'h' && cell.t2) {
      if (nearest) {
        if (frac < 0.25) return cell.s;
        if (frac < 0.75) return cell.s + 1;
        return cell.e;
      }
      return frac >= 0.5 ? cell.s + 1 : cell.s;
    }
    if (nearest && frac >= 0.5) return cell.e;
    return cell.s;
  }

  function gridIndexFromEvent(e, nearest) {
    var lay = gridLayout;
    if (!lay) return 0;
    var node = e.target || e.srcElement;
    var r = -1;
    while (node && node.nodeType === 1 && node.parentNode !== elGridPaper) node = node.parentNode;
    if (node && node.nodeType === 1 && node.parentNode === elGridPaper) r = gridRowEls.indexOf(node);
    if (r < 0) {
      /* 줄 밖(장 사이 여백, 원고지 바깥): 세로 위치가 가장 가까운 줄을 이분 탐색으로 찾는다 */
      var lo = 0, hi = gridRowEls.length - 1, y = e.clientY, mid;
      if (hi < 0) return lay.len;
      while (lo < hi) {
        mid = (lo + hi) >> 1;
        if (gridRowEls[mid].getBoundingClientRect().bottom >= y) hi = mid; else lo = mid + 1;
      }
      r = lo;
    }
    var rowEl = gridRowEls[r];
    var rect = rowEl.getBoundingClientRect();
    var x = (e.clientX - rect.left - 1) / gridCellPx;   /* 1px = 원고지 왼쪽 테두리 */
    if (x > GRID_COLS - 0.01) x = GRID_COLS - 0.01;
    return gridIndexAtRowX(r, x, nearest);
  }

  /* ↑/↓: 원고지의 위/아래 줄 같은 칸으로 이동 (textarea 기본 동작은 문단 단위라서 직접 처리) */
  function gridMoveVertical(dir, extend) {
    if (!gridLayout || gridLayoutText !== elGridInput.value) {
      gridLayout = computeGridLayout(elGridInput.value);
      gridLayoutText = elGridInput.value;
    }
    var lay = gridLayout;
    var a = elGridInput.selectionStart, b = elGridInput.selectionEnd;
    var backward = (elGridInput.selectionDirection === 'backward');
    var focus = backward ? a : b;
    var anchor = backward ? b : a;
    if (!extend && a !== b) focus = (dir < 0) ? a : b;
    var x = lay.pc[focus] + (lay.ps[focus] === 1 ? 0.5 : 0);
    var target = gridIndexAtRowX(lay.pr[focus] + dir, x, false);
    if (extend) gridSetRange(anchor, target);
    else gridSetSel(target, target);
  }

  function gridLoadText(text) {
    if (!isGridMode()) return;
    text = text || '';
    if (elGridInput.value !== text) {
      elGridInput.value = text;
      gridSetSel(text.length, text.length);
    }
    refreshGridMetrics();
    renderGrid(false);
    gridSyncHeadFields(null);
  }

  /* 툴바·단축키용 텍스트 삽입 (실행 취소 기록을 유지하려고 execCommand 를 먼저 시도) */
  function gridInsertText(txt) {
    gridFocusInput();
    var s = elGridInput.selectionStart, e = elGridInput.selectionEnd;
    var before = elGridInput.value;
    var ok = false;
    try {
      if (txt === '') ok = (s === e) ? true : document.execCommand('delete', false, null);
      else ok = document.execCommand('insertText', false, txt);
    } catch (err) { ok = false; }
    if (!ok || (elGridInput.value === before && (txt !== '' || s !== e))) {
      elGridInput.value = before.slice(0, s) + txt + before.slice(e);
      gridSetSel(s + txt.length, s + txt.length);
    }
    syncEditorToDisk();
    scheduleGridRender(true);
  }

  function gridWrapSelection(pre, post, placeholder) {
    gridFocusInput();
    var v = elGridInput.value, s = elGridInput.selectionStart, e = elGridInput.selectionEnd;
    var inner = v.slice(s, e) || placeholder || '';
    gridInsertText(pre + inner + post);
    gridSetSel(s + pre.length, s + pre.length + inner.length, 'forward');
    scheduleGridRender(true);
  }

  function gridSetLinePrefix(prefix) {
    gridFocusInput();
    var v = elGridInput.value, s = elGridInput.selectionStart;
    var ls = (s > 0) ? (v.lastIndexOf('\n', s - 1) + 1) : 0;
    var le = v.indexOf('\n', ls);
    if (le === -1) le = v.length;
    var m = v.slice(ls, le).match(/^(#{1,6}\s+|>\s?|[-*+]\s+\[[ xX]\]\s+|[-*+]\s+)/);
    var oldLen = m ? m[0].length : 0;
    if (oldLen === 0 && !prefix) return;
    if (m && m[0] === prefix) return;
    gridSetSel(ls, ls + oldLen);
    gridInsertText(prefix);
    var caret = Math.max(ls + prefix.length, s - oldLen + prefix.length);
    gridSetSel(caret, caret);
    scheduleGridRender(true);
  }

  function gridInsertBlock(lineText) {
    var v = elGridInput.value, s = elGridInput.selectionStart;
    var atLineStart = (s === 0 || v.charAt(s - 1) === '\n');
    gridInsertText((atLineStart ? '' : '\n') + lineText + '\n');
  }

  /* 원고지(칸)는 원문(마크다운 기호 포함)을 그대로 보여 주므로, 서식 버튼은 기호를 직접 넣어 줍니다 */
  function gridApplyToolbarAction(action) {
    if (action === 'h1') gridSetLinePrefix('# ');
    else if (action === 'h2') gridSetLinePrefix('## ');
    else if (action === 'h3') gridSetLinePrefix('### ');
    else if (action === 'p') gridSetLinePrefix('');
    else if (action === 'bold') gridWrapSelection('**', '**', '굵게');
    else if (action === 'italic') gridWrapSelection('*', '*', '기울임');
    else if (action === 'strike') gridWrapSelection('~~', '~~', '취소선');
    else if (action === 'quote') gridSetLinePrefix('> ');
    else if (action === 'ul') gridSetLinePrefix('- ');
    else if (action === 'task') gridSetLinePrefix('- [ ] ');
    else if (action === 'code') gridWrapSelection('```\n', '\n```', '코드를 입력하세요');
    else if (action === 'wikilink') gridWrapSelection('[[', ']]', '연결할 노트 제목');
    else if (action === 'hr') gridInsertBlock('---');
    else if (action === 'timestamp') gridInsertText(formatKoreanDailyTitle(new Date()) + ' ');
    else if (action === 'bgm') insertNowPlayingBGMStamp();
  }

  /* ---- 원고지(칸) 입력 이벤트 ---- */
  elGridInput.addEventListener('focus', function () {
    gridFocused = true;
    state.selectionTargetType = 'note';
    applyGridPaperClass();
    scheduleGridRender(false);
  }, false);

  elGridInput.addEventListener('blur', function () {
    gridFocused = false;
    applyGridPaperClass();
  }, false);

  elGridInput.addEventListener('compositionstart', function () {
    state.isComposing = true;
    gridCompLen = 0;
  }, false);

  elGridInput.addEventListener('compositionupdate', function (e) {
    gridCompLen = (e && e.data) ? String(e.data).length : 0;
    markTypingActivity();
    scheduleGridRender(true);
  }, false);

  elGridInput.addEventListener('compositionend', function () {
    state.isComposing = false;
    gridCompLen = 0;
    syncEditorToDisk();
    scheduleGridRender(true);
  }, false);

  elGridInput.addEventListener('input', function () {
    markTypingActivity();
    if (!state.isComposing) syncEditorToDisk();
    renderGrid(true);   /* 입력 직후 바로 그린다 (값이 이미 바뀐 뒤이므로 지연할 필요 없음) */
  }, false);

  elGridInput.addEventListener('keydown', function (e) {
    var key = e.keyCode || e.which;
    var mod = e.metaKey || e.ctrlKey;

    /* Command + Delete 는 document.onkeydown 에서 파일/폴더 삭제로 처리 */
    if (mod && (key === 8 || key === 46)) return;

    /* 시그니처 5: 무후회 초고 모드 */
    if (!mod && state.noBackspaceMode && (key === 8 || key === 46)) {
      e.preventDefault();
      updateSaveStatus('🔒 무후회 초고 모드 작동 중: 지우기 대신 생각을 앞으로 밀고 나가세요!');
      return;
    }

    /* 시그니처 1: 타건음 / 엔터 벨소리 */
    if (!mod) triggerTypewriterSound(key);

    /* Tab: 문단 첫 칸 비우기(들여쓰기 한 칸) */
    if (key === 9) {
      e.preventDefault();
      gridInsertText(' ');
      return;
    }

    if ((key === 38 || key === 40) && !mod && !e.altKey && !state.isComposing) {
      e.preventDefault();
      gridMoveVertical(key === 38 ? -1 : 1, e.shiftKey);
      scheduleGridRender(true);
      return;
    }

    scheduleGridRender(true);
  }, false);

  elGridInput.addEventListener('keyup', function () { scheduleGridRender(false); }, false);
  elGridInput.addEventListener('select', function () { scheduleGridRender(false); }, false);

  document.addEventListener('selectionchange', function () {
    if (isGridMode() && document.activeElement === elGridInput) scheduleGridRender(false);
  }, false);

  /* ---- 원고지(칸) 마우스: 칸 클릭으로 커서 이동, 드래그로 선택 ---- */
  elGridSurface.addEventListener('mousedown', function (e) {
    if (e.button && e.button !== 0) return;
    var hit = e.target || e.srcElement;
    if (hit && hit.tagName && hit.tagName.toUpperCase() === 'INPUT') return;
    e.preventDefault();
    if (!gridLayout || gridLayoutText !== elGridInput.value) renderGrid(false);
    var idx = gridIndexFromEvent(e, false);
    var anchor = idx;
    if (e.shiftKey) {
      anchor = (elGridInput.selectionDirection === 'backward') ? elGridInput.selectionEnd : elGridInput.selectionStart;
    }
    gridDragAnchor = anchor;
    gridDragStartX = e.clientX;
    gridDragStartY = e.clientY;
    gridDragMoved = false;
    /* 포커스 전에 입력창을 클릭한 줄 근처로 먼저 옮긴다 (preventScroll 을 모르는 구형 엔진 대비) */
    elGridInput.style.top = Math.round(e.clientY - elGridSurface.getBoundingClientRect().top - 10) + 'px';
    gridFocusInput();
    gridSetRange(anchor, idx);
    scheduleGridRender(false);
  }, false);

  document.addEventListener('mousemove', function (e) {
    if (gridDragAnchor < 0) return;
    if (!gridDragMoved) {
      if (Math.abs(e.clientX - gridDragStartX) + Math.abs(e.clientY - gridDragStartY) < 5) return;
      gridDragMoved = true;
    }
    gridSetRange(gridDragAnchor, gridIndexFromEvent(e, true));
    scheduleGridRender(false);
  }, false);

  document.addEventListener('mouseup', function () {
    gridDragAnchor = -1;
  }, false);

  /* 원고지 바깥 여백을 클릭해도 입력 포커스를 유지 */
  elScrollContainer.addEventListener('mousedown', function (e) {
    if (!isGridMode()) return;
    if ((e.target || e.srcElement) === elScrollContainer) {
      e.preventDefault();
      gridFocusInput();
    }
  }, false);

  window.addEventListener('resize', function () {
    if (!isGridMode()) return;
    refreshGridMetrics();
    scheduleGridRender(false);
  }, false);

  /* ==========================================================================
     조판 엔진 (인쇄 · PDF) — v2.3 도입, v2.4 수정
     화면을 그대로 프린터에 넘기지 않고, 다음 순서로 '용지 크기 PDF'를 직접 만듭니다.
       1) 조판 레이아웃으로 전환 (화면 틀 제거, 흰 종이 · 검은 글씨, 고정 크기)
       2) 쪽마다 떠 갈 영역(조각)과 그 조각이 용지 위에 놓일 자리 · 배율을 계산
          - 원고지(칸): 한 장(제목 [· 날짜] + 400칸 + 꼬리말 20×20 · 쪽 번호 · ©TypeGrapher)을 통째로
            조각 하나로 떠서 한 쪽 가운데에, 여백 안에 맞춰 배치
          - 그 밖의 스타일: 글줄 사이에서만 쪽을 나누고, 폭은 항상 용지 여백 안에 맞춤
       3) 네이티브가 조각별 벡터 PDF 를 떠서 용지 크기 PDF 한 벌로 합성 (capturePagesPDF)
       4) 화면을 원래대로 되돌린 뒤 저장 창 또는 인쇄 창을 띄움 (deliverPDF)
     이렇게 하면 용지를 무엇으로 고르든 내용이 종이 밖으로 나가지 않습니다.

     v2.4: WebView 는 PDF 로 그리는 동안 문서를 '인쇄 매체'로 다시 배치합니다. 그때 배치가 2)에서 잰
     것과 달라지면 조각이 엉뚱한 곳을 뜨게 되므로(v2.3 의 원고지 PDF 오류), 조판 레이아웃은 매체와
     무관하게 같도록 만들고, 문서 끝의 표식(job.probe)으로 네이티브가 이를 확인합니다.
     ========================================================================== */
  var PRINT_PAPERS = {
    'A4': { w: 595.28, h: 841.89, name: 'A4' },
    'B5': { w: 515.91, h: 728.50, name: 'B5' },
    'Letter': { w: 612.00, h: 792.00, name: 'Letter' }
  };
  var PRINT_MARGIN_PT = 34.02;     /* 용지 여백 12mm */
  var PRINT_GRID_CELL = 40;        /* 조판용 원고지 칸 크기(px). 벡터로 뜨므로 용지에 맞춰 줄여도 선명 */
  var PRINT_STAMP_H = 18;          /* 자동 표기 띠 높이(px) */
  var printSaved = null;

  var elPrintModal = document.getElementById('printModalBackdrop');
  var elPrintPadCount = document.getElementById('printPadCount');
  var elPrintPaper = document.getElementById('printPaper');
  var elPrintAuto = document.getElementById('printAuto');
  var elPrintHint = document.getElementById('printModalHint');
  var elPrintPadSurface = document.getElementById('printPadSurface');
  var elPrintPadPaper = document.getElementById('printPadPaper');
  var elPrintStampBox = document.getElementById('printStampBox');
  var elPrintProbe = document.getElementById('printProbe');

  function printHasEngine() {
    return hasNative() &&
      typeof window.NativeBridge.capturePagesPDF !== 'undefined' &&
      typeof window.NativeBridge.deliverPDF !== 'undefined';
  }

  function printDateText() {
    var d = new Date();
    return d.getFullYear() + '. ' + (d.getMonth() + 1) + '. ' + d.getDate() + '.';
  }

  function printStampHtml(width, left, center, right) {
    return '<div class="tg-stamp" style="width:' + width + 'px">' +
      (left ? '<span class="sl">' + escapeHtml(left) + '</span>' : '') +
      (right ? '<span class="sr">' + escapeHtml(right) + '</span>' : '') +
      (center ? '<span class="sc">' + escapeHtml(center) + '</span>' : '') +
      '</div>';
  }

  /* 화면 좌표의 사각형 → 문서 좌표 조각(sx, sy, sw, sh) */
  function printSrcOf(rect, pad) {
    var ox = window.pageXOffset || 0, oy = window.pageYOffset || 0;
    pad = pad || 0;
    return { sx: rect.left + ox - pad, sy: rect.top + oy - pad, sw: (rect.right - rect.left) + pad * 2, sh: (rect.bottom - rect.top) + pad * 2 };
  }

  /* ---- 원고지(칸 · 빈 양식 공통): 한 장 = 조각 하나 = 한 쪽, 여백 안에 맞춰 가운데 ----
     제목 · 날짜(머리말)와 20×20 · 쪽 번호 · ©TypeGrapher(꼬리말)가 모두 그 장의 줄 요소 안에 있으므로,
     머리말 윗변부터 꼬리말 아랫변까지를 통째로 뜨면 한 쪽에 원고지 한 장만 들어간다. */
  function printBuildSheetPages(job, rowEls, headEls) {
    var sheets = Math.floor(rowEls.length / GRID_ROWS_PER_PAGE);
    var availW = job.paperW - job.margin * 2;
    var availH = job.paperH - job.margin * 2;
    var p, first, last, top, src, s;
    for (p = 0; p < sheets; p++) {
      first = rowEls[p * GRID_ROWS_PER_PAGE].getBoundingClientRect();
      last = rowEls[p * GRID_ROWS_PER_PAGE + GRID_ROWS_PER_PAGE - 1].getBoundingClientRect();
      top = headEls[p] ? headEls[p].getBoundingClientRect().top : first.top;
      /* 머리말 윗변 ~ 꼬리말(마지막 줄 아래 20px) 아랫변, 사방 3px 여유 */
      src = printSrcOf({ left: first.left, right: first.right, top: top, bottom: last.bottom + 22 }, 3);
      s = Math.min(availW / src.sw, availH / src.sh);
      src.dw = src.sw * s;
      src.dh = src.sh * s;
      src.dx = job.margin + (availW - src.dw) / 2;
      src.dy = job.margin + (availH - src.dh) / 2;
      job.pages.push([src]);
    }
  }

  /* 머리말 오른쪽 위의 날짜 자리를 채우거나 비운다 (조판 중에만 쓰임) */
  function printSetHeadDates(text) {
    var p, el;
    for (p = 0; p < gridHeadEls.length; p++) {
      el = gridHeadEls[p].lastChild;
      while (el.firstChild) el.removeChild(el.firstChild);
      if (text) el.appendChild(document.createTextNode(text));
    }
  }

  function printBuildGridPages(job, auto) {
    gridForcedCell = PRINT_GRID_CELL;
    refreshGridMetrics();
    renderGrid(false);
    var heads = gridHeadEls.slice(0);
    if (auto) {
      /* 자동 표기: 오른쪽 위에 날짜 (조판 중에만).
         제목칸에는 노트 제목이 항상 들어 있고(v2.7: 원고지 제목 = 노트 제목), 쪽 번호도 자동 표기와 상관없이
         꼬리말 가운데에 항상 찍힌다. */
      printSetHeadDates(printDateText());
    }
    printBuildSheetPages(job, gridRowEls, heads);
  }

  function printBuildPadPages(job, opts, auto) {
    var n = parseInt(opts.padCount, 10);
    if (!(n >= 1)) n = 1;
    if (n > 50) n = 50;
    gridForcedCell = PRINT_GRID_CELL;
    refreshGridMetrics();
    var html = [], p, r;
    for (p = 0; p < n; p++) {
      for (r = 0; r < GRID_ROWS_PER_PAGE; r++) {
        html.push('<div class="ms-row"><div class="ms-cells">' + GRID_EMPTY_ROW + '</div>' +
          (r === 0
            ? '<div class="ms-head"><span class="ms-pad-title"><span class="ms-pad-label">제목</span><span class="ms-blank-line"></span></span></div>'
            : '') +
          /* 빈 양식의 쪽 번호(꼬리말 가운데)는 자동 표기를 켰을 때만 찍는다 */
          ((auto && r === GRID_ROWS_PER_PAGE - 1) ? '<div class="ms-foot-no">' + escapeHtml(gridPageLabel(p + 1)) + '</div>' : '') +
          '</div>');
      }
    }
    elPrintPadPaper.innerHTML = html.join('');
    elPrintPadSurface.style.width = (PRINT_GRID_CELL * GRID_COLS + 2) + 'px';
    var rows = [], heads = [], kids = elPrintPadPaper.children, i;
    for (i = 0; i < kids.length; i++) {
      rows.push(kids[i]);
      if (i % GRID_ROWS_PER_PAGE === 0) heads.push(kids[i].lastChild);
    }
    printBuildSheetPages(job, rows, heads);
  }

  /* ---- 일반 노트: 글줄 사이에서만 쪽 나누기 ---- */

  /* 잘리면 안 되는 세로 구간(글줄, 구분선, 그림, 체크박스)을 위에서부터 모은다.
     각 항목: a~b = 몸통(줄을 서로 구분하는 기준), ft~fb = 글자 상자 전체(쪽에 온전히 들어가야 하는 범위) */
  function printCollectCores(rootEl, originTop) {
    var cores = [], rects, i, r, h, node;
    var walker = document.createTreeWalker(rootEl, NodeFilter.SHOW_TEXT, null, false);
    var range = document.createRange();
    while ((node = walker.nextNode())) {
      if (!node.nodeValue || !/\S/.test(node.nodeValue)) continue;
      range.selectNodeContents(node);
      rects = range.getClientRects();
      for (i = 0; i < rects.length; i++) {
        r = rects[i];
        h = r.bottom - r.top;
        if (h <= 0 || r.right - r.left <= 0) continue;
        /* 글자 상자의 가운데 60% 를 '몸통'으로 본다 (줄 간격이 좁아 위아래 줄 상자가 살짝 겹쳐도 줄 단위로 구분되도록) */
        cores.push({ a: r.top - originTop + h * 0.2, b: r.bottom - originTop - h * 0.2, ft: r.top - originTop, fb: r.bottom - originTop });
      }
    }
    var solid = rootEl.querySelectorAll('hr, img, input');
    for (i = 0; i < solid.length; i++) {
      r = solid[i].getBoundingClientRect();
      if (r.bottom > r.top) cores.push({ a: r.top - originTop, b: r.bottom - originTop, ft: r.top - originTop, fb: r.bottom - originTop });
    }
    cores.sort(function (x, y) { return x.a - y.a; });
    var merged = [], cur = null;
    for (i = 0; i < cores.length; i++) {
      if (cur && cores[i].a <= cur.b) {
        if (cores[i].b > cur.b) cur.b = cores[i].b;
        if (cores[i].ft < cur.ft) cur.ft = cores[i].ft;
        if (cores[i].fb > cur.fb) cur.fb = cores[i].fb;
      } else {
        cur = { a: cores[i].a, b: cores[i].b, ft: cores[i].ft, fb: cores[i].fb };
        merged.push(cur);
      }
    }
    return merged;
  }

  /* pageTop 에서 시작한 쪽이 limit 을 넘지 않도록, 온전히 들어가는 마지막 줄과 그다음 줄 사이의 한가운데를 찾는다 */
  function printFindBreak(cores, pageTop, limit) {
    var k, it, last = null;
    for (k = 0; k < cores.length; k++) {
      it = cores[k];
      if (it.b <= pageTop) continue;          /* 앞쪽에 이미 들어간 줄 */
      if (it.fb <= limit) {
        last = it;
        continue;
      }
      if (!last) return limit;                /* 한 쪽보다 큰 덩어리(큰 그림 등)는 어쩔 수 없이 자른다 */
      if (it.ft >= last.fb) return Math.min(limit, (last.fb + it.ft) / 2);
      return Math.min(limit, (last.b + it.a) / 2);
    }
    return limit;
  }

  function printHasLineBetween(cores, from, to) {
    var k;
    for (k = 0; k < cores.length; k++) {
      if (cores[k].a >= to) break;
      if (cores[k].b > from) return true;
    }
    return false;
  }

  function printBuildFlowPages(job, auto) {
    var canvas = elLiveEditor;
    var cr = canvas.getBoundingClientRect();
    var W = cr.right - cr.left;
    var contentH = cr.bottom - cr.top;
    if (W <= 0) return;
    var availW = job.paperW - job.margin * 2;
    var availH = job.paperH - job.margin * 2;
    var scale = availW / W;                                  /* px → pt. 폭은 항상 여백 안에 딱 맞음 */
    var bandPt = auto ? (PRINT_STAMP_H * scale + 6) : 0;     /* 머리말/꼬리말 띠 */
    var pageH = (availH - bandPt * 2) / scale;               /* 한 쪽에 들어가는 본문 높이(px) */
    var ruled = (state.paperStyle === 'manuscript');
    var rowBase = ruled ? (parseFloat(window.getComputedStyle(canvas, null).borderTopWidth) || 0) : 0;

    var cores = printCollectCores(canvas, cr.top);
    var blocks = [], kids = canvas.children, i, br;
    for (i = 0; i < kids.length; i++) {
      br = kids[i].getBoundingClientRect();
      blocks.push({ top: br.top - cr.top, bottom: br.bottom - cr.top, tag: kids[i].tagName.toUpperCase() });
    }

    var breaks = [0], y = 0, guard = 0, next, b, snapped;
    while (contentH - y > pageH + 0.5 && guard++ < 5000) {
      next = printFindBreak(cores, y, y + pageH);

      /* 원고지(줄): 쪽 경계를 36px 줄 경계에 맞춘다 (붉은 줄이 쪽 맨 아래에 온전히 남도록).
         아래의 '제목 넘기기'보다 먼저 해야 한다: 맞춤으로 본문 줄이 다음 쪽으로 밀리면 제목이 혼자 남을 수 있기 때문 */
      if (ruled) {
        snapped = rowBase + Math.round((next - rowBase) / 36) * 36;
        if (snapped > y + pageH) snapped -= 36;
        if (snapped > y + 1) next = snapped;
      }

      /* 제목이 쪽 맨 아래에 혼자 남으면(그 아래로 본문 줄이 하나도 못 들어가면) 제목부터 다음 쪽으로 넘긴다.
         쪽 끝에서 거꾸로 올라가며, 글자가 없는 빈 문단은 건너뛰고 제목이 연달아 있으면 함께 넘긴다. */
      for (b = blocks.length - 1; b >= 0; b--) {
        if (blocks[b].top >= next - 0.5) continue;            /* 다음 쪽에 놓일 블록 */
        if (blocks[b].top <= y + 1) break;                    /* 이 쪽의 첫 블록은 옮길 수 없다 */
        if (/^H[1-6]$/.test(blocks[b].tag)) {
          next = blocks[b].top - Math.min(8, Math.max(0, (blocks[b].top - (b > 0 ? blocks[b - 1].bottom : y)) / 2));
          continue;
        }
        if (printHasLineBetween(cores, blocks[b].top, Math.min(blocks[b].bottom, next))) break;   /* 쪽 끝에 본문 줄이 있음 */
      }

      if (!(next > y + 1)) next = y + pageH;    /* 진행이 없으면 강제로 나눈다 */
      breaks.push(next);
      y = next;
    }
    breaks.push(contentH);

    var pageCount = breaks.length - 1;
    var stampEls = null, note = getActiveNote();
    if (auto) {
      var html = printStampHtml(W, note ? note.title : '', '', printDateText());
      for (i = 0; i < pageCount; i++) html += printStampHtml(W, '', '– ' + (i + 1) + ' / ' + pageCount + ' –', '');
      elPrintStampBox.innerHTML = html;
      stampEls = elPrintStampBox.children;
    }

    var ox = window.pageXOffset || 0, oy = window.pageYOffset || 0, pieces, body, st;
    for (i = 0; i < pageCount; i++) {
      body = {
        sx: cr.left + ox, sy: cr.top + oy + breaks[i], sw: W, sh: breaks[i + 1] - breaks[i],
        dx: job.margin, dy: job.margin + bandPt, dw: availW, dh: (breaks[i + 1] - breaks[i]) * scale
      };
      if (body.sh < 1) continue;
      pieces = [body];
      if (stampEls) {
        st = printSrcOf(stampEls[0].getBoundingClientRect(), 0);
        st.dx = job.margin; st.dy = job.margin; st.dw = st.sw * scale; st.dh = st.sh * scale;
        pieces.push(st);
        st = printSrcOf(stampEls[i + 1].getBoundingClientRect(), 0);
        st.dw = st.sw * scale; st.dh = st.sh * scale;
        st.dx = job.margin; st.dy = job.paperH - job.margin - st.dh;
        pieces.push(st);
      }
      job.pages.push(pieces);
    }
  }

  /* ---- 조판 레이아웃 들어가기 / 나오기 ---- */
  function printEnter(opts, target) {
    var paper = PRINT_PAPERS[opts.paper] || PRINT_PAPERS.A4;
    var root = document.documentElement;
    printSaved = {
      rootCls: root.className || '',
      bodyCls: document.body.className || '',
      scrollTop: elScrollContainer.scrollTop,
      focusEl: document.activeElement,
      range: null
    };
    /* 일반 편집기에서 글자를 선택해 둔 상태라면 선택 표시가 PDF 에 찍히지 않게 잠시 풀어 둔다 (끝나면 복원) */
    if (printSaved.focusEl !== elGridInput && window.getSelection) {
      var selNow = window.getSelection();
      if (selNow && selNow.rangeCount > 0) {
        try { printSaved.range = selNow.getRangeAt(0).cloneRange(); } catch (errSel) { printSaved.range = null; }
        try { selNow.removeAllRanges(); } catch (errSel2) {}
      }
    }
    /* 입력 중이던 한글 조합을 끝내고 저장되게 한다 */
    if (printSaved.focusEl && printSaved.focusEl !== document.body && printSaved.focusEl.blur) {
      try { printSaved.focusEl.blur(); } catch (errBlur) {}
    }
    root.className = (printSaved.rootCls ? printSaved.rootCls + ' ' : '') + 'tg-print-root' +
      (opts.ink === 'mono' ? ' tg-print-mono' : '') + (target === 'pad' ? ' tg-print-pad' : '');
    document.body.className = 'theme-light';
    /* 집중 모드의 흐림 · 글로우는 종이에 찍지 않는다 */
    setCls(elLiveEditor, 'focus-mode-active', false);
    setCls(elLiveEditor, 'typing-now', false);
    elGridPaper.className = 'ms-grid';
    window.scrollTo(0, 0);

    var job = { paperW: paper.w, paperH: paper.h, margin: PRINT_MARGIN_PT, pages: [] };
    if (target === 'pad') printBuildPadPages(job, opts, !!opts.auto);
    else if (isGridMode()) printBuildGridPages(job, !!opts.auto);
    else printBuildFlowPages(job, !!opts.auto);
    /* 배치 검증용 표식의 자리(문서 맨 끝). 네이티브가 이 자리를 떠 보아 표식이 그대로 있는지 확인한다 */
    if (elPrintProbe && job.pages.length > 0) {
      var pr = elPrintProbe.getBoundingClientRect();
      if (pr.right - pr.left >= 8 && pr.bottom - pr.top >= 8) {
        job.probe = printSrcOf({ left: Math.round(pr.left), top: Math.round(pr.top), right: Math.round(pr.right), bottom: Math.round(pr.bottom) }, 0);
      }
    }
    return job;
  }

  function printExit() {
    if (!printSaved) return;
    var saved = printSaved;
    printSaved = null;
    document.documentElement.className = saved.rootCls;
    document.body.className = saved.bodyCls;
    elPrintPadPaper.innerHTML = '';
    elPrintStampBox.innerHTML = '';
    printSetHeadDates('');
    gridForcedCell = 0;
    gridCellPx = 0;
    updateSignatureUIStates();       /* 집중 모드 클래스와 원고지 칸 크기를 화면 상태로 되돌림 */
    if (isGridMode()) {
      renderGrid(false);
      gridSyncHeadFields(null);      /* 조판용으로 줄였던 제목칸 너비를 화면용으로 되돌림 */
    }
    elScrollContainer.scrollTop = saved.scrollTop;
    if (saved.focusEl === elGridInput) {
      gridFocusInput();
    } else if (saved.focusEl === elLiveEditor) {
      try { elLiveEditor.focus(); } catch (errFocus) {}
    }
    if (saved.range && window.getSelection) {
      try {
        var selBack = window.getSelection();
        selBack.removeAllRanges();
        selBack.addRange(saved.range);
      } catch (errSel3) {}
    }
  }

  function printFileName(target) {
    if (target === 'pad') return '빈 원고지 20x20';
    var note = getActiveNote();
    var name = note ? note.title : 'TypeGrapher';
    return String(name).replace(/[\/:\\]/g, '_');
  }

  function printLegacy(reason) {
    updateSaveStatus('🖨️ ' + reason + ' 기존 방식의 인쇄 창을 엽니다');
    if (hasNative()) window.NativeBridge.printCurrentNote();
    else window.print();
  }

  /* action: 'save'(PDF 로 저장) | 'print'(인쇄), target: 'note'(현재 노트) | 'pad'(빈 원고지 양식) */
  function runPrintJob(action, target) {
    var opts = state.printOpts;
    if (!printHasEngine()) {
      if (target === 'pad') {
        showModal('빈 원고지를 만들 수 없습니다', '이 빌드에는 새 조판 엔진이 포함되지 않아 빈 원고지 양식을 만들 수 없습니다.\n빌드할 때 터미널에 나온 경고 내용을 확인해 주세요.', null, true);
        return;
      }
      printLegacy('새 조판 엔진을 쓸 수 없어');
      return;
    }
    if (target !== 'pad' && !getActiveNote()) {
      showModal('내보낼 노트가 없습니다', '먼저 노트를 하나 열어 주세요.', null, true);
      return;
    }

    var job = null, res = '';
    try {
      job = printEnter(opts, target);
      if (job && job.pages.length > 0) {
        res = String(window.NativeBridge.capturePagesPDF(JSON.stringify(job)));
      }
    } catch (err) {
      res = 'err:script ' + err;
    }
    printExit();     /* 성공하든 실패하든 화면은 반드시 원래대로 */

    if (!job || job.pages.length === 0) {
      showModal('내보낼 내용이 없습니다', '조판할 쪽을 만들지 못했습니다.', null, true);
      return;
    }
    if (res.indexOf('ok:') !== 0) {
      if (target === 'pad') {
        showModal('PDF 를 만들지 못했습니다', '조판 엔진 오류: ' + res, null, true);
      } else {
        showModal('새 조판 엔진으로 PDF 를 만들지 못했습니다',
          '오류: ' + res + '\n\n기존 방식의 인쇄 창을 대신 열까요?\n(이 오류 문구를 알려 주시면 원인을 찾을 수 있습니다)',
          function () { printLegacy('요청에 따라'); }, false);
      }
      return;
    }

    var pageCount = parseInt(res.slice(3), 10) || job.pages.length;
    var fileName = printFileName(target);
    var deliver = function () {
      updateSaveStatus('🖨️ ' + pageCount + '쪽 조판 완료 (' + (PRINT_PAPERS[opts.paper] || PRINT_PAPERS.A4).name + ')');
      /* 화면이 원래대로 다시 그려진 다음에 저장 창 / 인쇄 창을 띄운다 */
      setTimeout(function () {
        var out = String(window.NativeBridge.deliverPDF(action === 'print' ? 'print' : 'save', fileName));
        if (out.indexOf('saved:') === 0) updateSaveStatus('📄 PDF 저장 완료 (' + pageCount + '쪽): ' + out.slice(6));
        else if (out === 'printed') updateSaveStatus('🖨️ 인쇄를 보냈습니다 (' + pageCount + '쪽)');
        else if (out === 'cancel') updateSaveStatus('취소했습니다');
        else if (out === 'err:no-pdfkit') {
          showModal('이 Mac 에서는 바로 인쇄할 수 없습니다',
            '조판한 내용을 인쇄 창으로 넘기는 기능(PDFKit)을 이 Mac 에서 찾지 못했습니다.\n상단의 「📄 PDF」 버튼으로 파일을 만든 뒤 미리보기에서 인쇄해 주세요.', null, true);
        }
        else showModal('내보내기에 실패했습니다', '오류: ' + out, null, true);
      }, 60);
    };
    /* 네이티브가 문서 끝의 표식을 제자리에서 찾지 못했다 = 캡처하는 동안 배치가 달라졌다 */
    if (res.indexOf(':shift') !== -1) {
      showModal('조판 위치가 어긋났을 수 있습니다',
        'PDF 를 뜨는 동안 문서 배치가 화면에서 잰 것과 달라졌습니다 (' + res + ').\n쪽이 잘리거나 밀려 있을 수 있습니다. 그래도 내보낼까요?\n(이 문구를 알려 주시면 원인을 찾을 수 있습니다)',
        deliver, false);
      return;
    }
    deliver();
  }

  /* ---- 조판 설정 창 ---- */
  function printRadioValue(name, fallback) {
    var els = document.getElementsByName(name), i;
    for (i = 0; i < els.length; i++) {
      if (els[i].checked) return els[i].value;
    }
    return fallback;
  }

  function printSetRadio(name, value) {
    var els = document.getElementsByName(name), i;
    for (i = 0; i < els.length; i++) els[i].checked = (els[i].value === value);
  }

  function printUpdateHint() {
    var target = printRadioValue('printTarget', 'note');
    var msg;
    if (target === 'pad') {
      msg = '글자 없이 제목 줄 · 20×20 격자 · ©TypeGrapher 만 찍힌 빈 원고지를 원하는 장수만큼 만듭니다.\n자동 표기를 켜면 꼬리말 가운데에 쪽 번호(- 1 -)가 찍힙니다.';
    } else if (isGridMode()) {
      msg = '원고지 한 장(제목 + 400칸 + 꼬리말)이 종이 한 쪽 가운데에, 여백 안에 꼭 맞게 들어갑니다.\n제목(= 노트 제목)과 쪽 번호는 항상 찍히고, 자동 표기를 켜면 오른쪽 위에 날짜가 들어갑니다.';
    } else {
      msg = '지금 스타일 그대로 용지 폭에 맞추고, 글줄 사이에서만 쪽을 나눕니다.\n(칸 원고지로 뽑으려면 스타일을 원고지(칸)으로 바꾼 뒤 인쇄하세요)';
    }
    msg += '\n용지 · 잉크 · 자동 표기는 고르는 즉시 저장되고, 상단의 「📄 PDF」 버튼에도 똑같이 적용됩니다.';
    elPrintHint.innerHTML = escapeHtml(msg);
  }

  function openPrintModal() {
    if (state.isModalOpen || state.isPrintModalOpen) return;
    var o = state.printOpts;
    printSetRadio('printTarget', 'note');
    printSetRadio('printInk', o.ink === 'mono' ? 'mono' : 'red');
    elPrintPaper.value = PRINT_PAPERS[o.paper] ? o.paper : 'A4';
    elPrintAuto.checked = !!o.auto;
    elPrintPadCount.value = String(o.padCount || 2);
    printUpdateHint();
    state.isPrintModalOpen = true;
    elPrintModal.className = 'modal-backdrop show';
  }

  function closePrintModal() {
    state.isPrintModalOpen = false;
    elPrintModal.className = 'modal-backdrop';
  }

  /* 창에서 고른 값을 읽어 저장한다. 값을 바꿀 때마다 저장하므로, 창을 그냥 닫아도 다음 인쇄와
     상단 「📄 PDF」 버튼(같은 용지 · 잉크 · 자동 표기를 씀)에 그대로 적용된다 */
  function printStoreOpts() {
    var n = parseInt(elPrintPadCount.value, 10);
    if (!(n >= 1)) n = 1;
    if (n > 50) n = 50;
    state.printOpts = {
      ink: printRadioValue('printInk', 'red') === 'mono' ? 'mono' : 'red',
      auto: !!elPrintAuto.checked,
      paper: PRINT_PAPERS[elPrintPaper.value] ? elPrintPaper.value : 'A4',
      padCount: n
    };
    saveOrderConfigToNative();
  }

  /* 인쇄 설정 창의 「인쇄…」: 설정을 저장하고 조판해서 인쇄 창을 연다 (v2.7: 이 창은 인쇄 전용) */
  function confirmPrintModal() {
    var target = printRadioValue('printTarget', 'note');
    printStoreOpts();
    closePrintModal();
    runPrintJob('print', target === 'pad' ? 'pad' : 'note');
  }

  /* 「📄 PDF」 버튼: 인쇄 설정 창에서 고른 용지 · 잉크 · 자동 표기 그대로, 현재 노트를 바로 PDF 저장 창까지 */
  function quickExportPDF() {
    if (state.isModalOpen || state.isPrintModalOpen) return;
    runPrintJob('save', 'note');
  }

  document.getElementById('printBtnCancel').onclick = closePrintModal;
  document.getElementById('printBtnPrint').onclick = function () { confirmPrintModal(); };
  document.getElementById('btnExportPDF').onclick = quickExportPDF;
  (function () {
    var els = document.getElementsByName('printTarget'), i;
    for (i = 0; i < els.length; i++) els[i].onclick = printUpdateHint;
    /* 용지 · 잉크 · 자동 표기 · 장수는 바꾸는 즉시 저장한다 (이 창에서 인쇄하지 않고 닫아도 「📄 PDF」 버튼에 적용되도록) */
    els = document.getElementsByName('printInk');
    for (i = 0; i < els.length; i++) els[i].onclick = printStoreOpts;
  })();
  elPrintPaper.onchange = printStoreOpts;
  elPrintAuto.onclick = printStoreOpts;
  elPrintPadCount.onchange = printStoreOpts;
  elPrintPadCount.onfocus = function () {
    printSetRadio('printTarget', 'pad');
    printUpdateHint();
  };

  /* 5. Interactive Live Editor Events */
  elLiveEditor.addEventListener('compositionstart', function () {
    state.isComposing = true;
  }, false);

  elLiveEditor.addEventListener('compositionend', function () {
    state.isComposing = false;
    checkInlineMarkdownShortcuts();
    syncEditorToDisk();
    updateFocusAndTypewriterScroll();
  }, false);

  elLiveEditor.addEventListener('compositionupdate', function () {
    markTypingActivity();
  }, false);

  elLiveEditor.onfocus = function () {
    state.selectionTargetType = 'note';
  };

  elLiveEditor.onclick = function (e) {
    state.selectionTargetType = 'note';
    updateFocusAndTypewriterScroll();
    var target = e.target || e.srcElement;
    if (!target) return;

    if (target.tagName && target.tagName.toUpperCase() === 'INPUT' && target.type === 'checkbox') {
      var li = target.parentNode;
      if (li && li.tagName && li.tagName.toUpperCase() === 'LI') {
        if (target.checked) {
          if (li.className.indexOf('task-done') === -1) li.className += ' task-done';
        } else {
          li.className = li.className.replace(/\btask-done\b/g, '').trim();
        }
      }
      syncEditorToDisk();
      return;
    }

    if (target.className && target.className.indexOf('wiki-tag') !== -1) {
      var linkTitle = target.getAttribute('data-wikilink') || target.textContent.replace(/^\[\[|\]\]$/g, '');
      if (!linkTitle) return;
      for (var i = 0; i < state.notes.length; i++) {
        if (state.notes[i].title.toLowerCase() === linkTitle.toLowerCase()) {
          selectNote(state.notes[i].relPath);
          return;
        }
      }
      createNewNote(linkTitle, '');
    }
  };

  elLiveEditor.onkeydown = function (e) {
    var key = e.keyCode || e.which;

    // Command + Delete: 파일 삭제
    if ((e.metaKey || e.ctrlKey) && (key === 8 || key === 46)) {
      e.preventDefault();
      e.stopPropagation();
      deleteSelectedItemOrNote();
      return;
    }

    // 시그니처 5: 무후회 초고 모드 (Backspace/Delete 잠금)
    if (!e.metaKey && !e.ctrlKey && state.noBackspaceMode && (key === 8 || key === 46)) {
      e.preventDefault();
      updateSaveStatus('🔒 무후회 초고 모드 작동 중: 지우기 대신 생각을 앞으로 밀고 나가세요!');
      return;
    }

    // 시그니처 1: 리얼 수동 타자기 타건음 & 엔터 벨소리 재생
    if (!e.metaKey && !e.ctrlKey) {
      triggerTypewriterSound(key);
    }

    if (key === 9) {
      e.preventDefault();
      document.execCommand('insertText', false, '    ');
      syncEditorToDisk();
      return;
    }

    if (key === 13 && !e.shiftKey && !state.isComposing) {
      var block = getActiveBlockElement();
      if (block) {
        var raw = (block.innerText || block.textContent || '').replace(/\u00A0/g, ' ').trim();
        if (raw === '---' || raw === '***') {
          e.preventDefault();
          var hr = document.createElement('hr');
          var nextP = document.createElement('p');
          nextP.innerHTML = '<br>';
          block.parentNode.insertBefore(hr, block);
          block.parentNode.replaceChild(nextP, block);
          placeCaretAtStart(nextP);
          syncEditorToDisk();
          updateFocusAndTypewriterScroll();
          return;
        }

        if (block.tagName.toUpperCase() === 'LI' && block.className.indexOf('task-item') !== -1) {
          e.preventDefault();
          if (raw === '') {
            var ulParent = block.parentNode;
            var outP = document.createElement('p');
            outP.innerHTML = '<br>';
            ulParent.parentNode.insertBefore(outP, ulParent.nextSibling);
            ulParent.removeChild(block);
            if (ulParent.children.length === 0) ulParent.parentNode.removeChild(ulParent);
            placeCaretAtStart(outP);
          } else {
            var newLi = document.createElement('li');
            newLi.className = 'task-item';
            var newCb = document.createElement('input');
            newCb.type = 'checkbox';
            newCb.setAttribute('contenteditable', 'false');
            var newSp = document.createElement('span');
            newSp.innerHTML = '<br>';
            newLi.appendChild(newCb);
            newLi.appendChild(newSp);
            block.parentNode.insertBefore(newLi, block.nextSibling);
            placeCaretAtStart(newSp);
          }
          syncEditorToDisk();
          updateFocusAndTypewriterScroll();
          return;
        }
      }
    }
  };

  elLiveEditor.onkeyup = function (e) {
    if (state.isComposing) return;
    var key = e.keyCode || e.which;
    if (key === 32) {
      if (checkBlockMarkdownShortcutOnSpace()) {
        updateFocusAndTypewriterScroll();
        return;
      }
    }
    checkInlineMarkdownShortcuts();
    syncEditorToDisk();
    updateFocusAndTypewriterScroll();
  };

  elLiveEditor.oninput = function () {
    markTypingActivity();
    if (state.isComposing) return;
    syncEditorToDisk();
    updateFocusAndTypewriterScroll();
  };

  elFormatToolbar.onclick = function (e) {
    var target = e.target || e.srcElement;
    while (target && target !== elFormatToolbar && !target.getAttribute('data-Action')) {
      target = target.parentNode;
    }
    if (!target || target === elFormatToolbar) return;

    var action = target.getAttribute('data-Action');
    if (isGridMode()) {
      gridApplyToolbarAction(action);
      return;
    }
    elLiveEditor.focus();

    if (action === 'h1') document.execCommand('formatBlock', false, 'H1');
    else if (action === 'h2') document.execCommand('formatBlock', false, 'H2');
    else if (action === 'h3') document.execCommand('formatBlock', false, 'H3');
    else if (action === 'p') document.execCommand('formatBlock', false, 'P');
    else if (action === 'bold') document.execCommand('bold', false, null);
    else if (action === 'italic') document.execCommand('italic', false, null);
    else if (action === 'strike') document.execCommand('strikeThrough', false, null);
    else if (action === 'quote') document.execCommand('formatBlock', false, 'BLOCKQUOTE');
    else if (action === 'ul') document.execCommand('insertUnorderedList', false, null);
    else if (action === 'task') {
      document.execCommand('insertHTML', false, '<ul><li class="task-item"><input type="checkbox" contenteditable="false"><span>할 일 항목</span></li></ul>');
    } else if (action === 'code') {
      document.execCommand('insertHTML', false, '<pre><code>코드를 입력하세요</code></pre><p><br></p>');
    } else if (action === 'wikilink') {
      var selText = window.getSelection ? String(window.getSelection()) : '';
      var wkTitle = selText.trim() || '연결할 노트 제목';
      document.execCommand('insertHTML', false, '<span class="wiki-tag" contenteditable="false" data-wikilink="' + escapeHtml(wkTitle) + '">[[' + escapeHtml(wkTitle) + ']]</span>&nbsp;');
    } else if (action === 'hr') {
      document.execCommand('insertHTML', false, '<hr><p><br></p>');
    } else if (action === 'timestamp') {
      document.execCommand('insertText', false, formatKoreanDailyTitle(new Date()) + ' ');
    } else if (action === 'bgm') {
      insertNowPlayingBGMStamp();
      return;
    }
    syncEditorToDisk();
  };

  /* v2.7: 칸보다 긴 제목을 고치는 동안에는 상단 줄 전체를 제목칸으로 쓴다 (오른쪽 단추들을 잠시 숨김) */
  var elTopbar = elTitleInput.parentNode.parentNode;
  function titleUpdateWide() {
    if (document.activeElement === elTitleInput && elTitleInput.scrollWidth > elTitleInput.clientWidth + 1 &&
        elTopbar.className.indexOf('title-wide') === -1) {
      elTopbar.className = 'topbar title-wide';
    }
  }
  /* 상단 제목칸에 입력하는 대로 원고지 제목란(모든 장)에 비춘다. 노트 이름은 입력을 마칠 때 바뀐다. */
  elTitleInput.oninput = function () {
    elTitleInput.title = elTitleInput.value;
    gridSyncHeadFields(null);
    titleUpdateWide();
  };
  elTitleInput.onfocus = titleUpdateWide;
  elTitleInput.onchange = commitTitleRename;
  elTitleInput.onblur = function () {
    elTopbar.className = 'topbar';
    commitTitleRename();
  };
  elTitleInput.onkeydown = function (e) {
    var key = e.keyCode || e.which;
    if (key === 13) {
      e.preventDefault();
      /* 이 Enter 가 문서 전체 단축키 처리로 올라가지 않게 한다 (이름을 바꿀 수 없어 알림창이 뜬 경우,
         같은 Enter 가 그 알림창의 '확인'까지 눌러 버려 알림을 볼 수 없던 문제) */
      if (e.stopPropagation) e.stopPropagation();
      commitTitleRename();
      if (!state.isModalOpen) elLiveEditor.focus();
    } else if (key === 27) {
      /* Esc: 고치던 제목을 버리고 원래 제목으로 되돌린다 */
      var escNote = getActiveNote();
      if (escNote) titleShow(escNote.title);
    }
  };

  function toggleSidebar() {
    if (elSidebar.className.indexOf('collapsed') !== -1) {
      elSidebar.className = 'sidebar';
      elSidebarResizer.className = 'sidebar-resizer';
    } else {
      elSidebar.className = 'sidebar collapsed';
      elSidebarResizer.className = 'sidebar-resizer hidden';
    }
    if (isGridMode()) {
      refreshGridMetrics();
      scheduleGridRender(false);
    }
  }

  document.getElementById('btnToggleSidebar').onclick = toggleSidebar;

  document.getElementById('btnZenMode').onclick = function () {
    state.zenMode = !state.zenMode;
    if (state.zenMode) {
      elSidebar.className = 'sidebar collapsed';
      elSidebarResizer.className = 'sidebar-resizer hidden';
      elFormatToolbar.className = 'toolbar hidden';
    } else {
      elSidebar.className = 'sidebar';
      elSidebarResizer.className = 'sidebar-resizer';
      elFormatToolbar.className = 'toolbar';
    }
    updateSignatureUIStates();
  };

  /* 시그니처 버튼 이벤트 연결 */
  function toggleKeySound() {
    state.keySoundEnabled = !state.keySoundEnabled;
    updateSignatureUIStates();
    saveOrderConfigToNative();
    if (state.keySoundEnabled && hasNative()) {
      window.NativeBridge.playTypeSound('key');
    }
    updateSaveStatus(state.keySoundEnabled ? '🔊 타건음이 켜졌습니다' : '🔇 타건음이 꺼졌습니다 (엔터 벨소리는 🔔 버튼으로 따로 조절)');
  }

  function toggleBellSound() {
    state.bellSoundEnabled = !state.bellSoundEnabled;
    updateSignatureUIStates();
    saveOrderConfigToNative();
    if (state.bellSoundEnabled && hasNative()) {
      window.NativeBridge.playTypeSound('bell');
    }
    updateSaveStatus(state.bellSoundEnabled ? '🔔 엔터 벨소리가 켜졌습니다' : '🔕 엔터 벨소리가 꺼졌습니다 (타건음은 🔊 버튼으로 따로 조절)');
  }

  function toggleFocusLightMode() {
    state.focusMode = !state.focusMode;
    updateSignatureUIStates();
    saveOrderConfigToNative();
    updateFocusAndTypewriterScroll();
    updateSaveStatus(state.focusMode ? '🎯 타자기 중앙 고정 스크롤 & 문장 집중 조명이 켜졌습니다' : '🎯 일반 스크롤 모드로 전환되었습니다');
  }

  function toggleNoBackspaceMode() {
    state.noBackspaceMode = !state.noBackspaceMode;
    updateSignatureUIStates();
    saveOrderConfigToNative();
    updateSaveStatus(state.noBackspaceMode ? '🔒 무후회 초고 모드 켜짐 (Backspace/Delete 키가 일시 잠금됩니다)' : '🔓 무후회 초고 모드가 해제되었습니다');
  }

  function cyclePaperStyle() {
    if (state.paperStyle === 'default') state.paperStyle = 'typewriter';
    else if (state.paperStyle === 'typewriter') state.paperStyle = 'manuscript';
    else if (state.paperStyle === 'manuscript') state.paperStyle = 'grid';
    else state.paperStyle = 'default';
    updateSignatureUIStates();
    saveOrderConfigToNative();
    // 일반 편집기 <-> 원고지(칸) 편집기 사이를 오갈 때 현재 노트 내용을 해당 편집기에 다시 채운다
    renderActiveNote();
    var msg = '📜 기본 모던 스타일이 적용되었습니다';
    if (state.paperStyle === 'typewriter') msg = '📜 클래식 영문/명조 타자기 폰트 스타일이 적용되었습니다';
    else if (state.paperStyle === 'manuscript') msg = '📜 원고지(줄) 스타일이 적용되었습니다 (모든 글줄이 붉은 줄에 맞춰집니다)';
    else if (state.paperStyle === 'grid') {
      msg = '📜 원고지(칸) 스타일이 적용되었습니다 (20×20, 한 칸에 한 글자 · 이어지는 숫자/영문 소문자는 한 칸에 두 자)';
      placeCaretAtEnd(elLiveEditor);
    }
    updateSaveStatus(msg);
  }

  /* 인쇄 버튼 · Cmd+P: 인쇄 설정 창을 연다 (네이티브가 없는 환경에서는 브라우저 인쇄) */
  function triggerPrintOrPDF() {
    if (hasNative()) {
      openPrintModal();
    } else {
      window.print();
    }
  }

  elBtnToggleSound.onclick = toggleKeySound;
  elBtnToggleBell.onclick = toggleBellSound;
  elBtnToggleFocus.onclick = toggleFocusLightMode;
  elBtnToolbarFocus.onclick = toggleFocusLightMode;
  elBtnNoBackspace.onclick = toggleNoBackspaceMode;
  elBtnPaperStyle.onclick = cyclePaperStyle;
  document.getElementById('btnOpenStats').onclick = openPunchCardStatsModal;
  document.getElementById('btnPrintNote').onclick = triggerPrintOrPDF;

  (function setupSidebarResizer() {
    var isResizing = false;

    elSidebarResizer.onmousedown = function (e) {
      e.preventDefault();
      isResizing = true;
      elSidebarResizer.className = 'sidebar-resizer active';
      if (document.body.className.indexOf('resizing-sidebar') === -1) {
        document.body.className += ' resizing-sidebar';
      }
    };

    document.addEventListener('mousemove', function (e) {
      if (!isResizing) return;
      var newWidth = e.clientX - 42;
      applySidebarWidth(newWidth);
    }, false);

    document.addEventListener('mouseup', function () {
      if (!isResizing) return;
      isResizing = false;
      elSidebarResizer.className = 'sidebar-resizer';
      document.body.className = document.body.className.replace(/\bresizing-sidebar\b/g, '').trim();
      saveOrderConfigToNative();
    }, false);
  })();

  function toggleTheme() {
    var isDark = document.body.className.indexOf('theme-dark') !== -1;
    var nextTheme = isDark ? 'light' : 'dark';
    document.body.className = 'theme-' + nextTheme;
    if (hasNative()) {
      window.NativeBridge.saveTheme(nextTheme);
    }
  }

  document.getElementById('btnToggleTheme').onclick = toggleTheme;
  document.getElementById('btnNewNote').onclick = function () { createNewNote(); };
  document.getElementById('btnRibbonNew').onclick = function () { createNewNote(); };
  document.getElementById('btnDailyNote').onclick = openOrCreateDailyNote;
  document.getElementById('btnRibbonDaily').onclick = openOrCreateDailyNote;
  document.getElementById('btnAddSubfolder').onclick = function () { promptCreateSubfolder(); };
  document.getElementById('btnDeleteItem').onclick = deleteSelectedItemOrNote;

  function resetToRootLocation() {
    if (state.selectedFolder !== '' || state.selectionTargetType !== 'note') {
      state.selectedFolder = '';
      state.selectionTargetType = 'note';
      updateSelectedFolderUI();
      renderSidebar();
      updateSaveStatus('루트 폴더(기본 보관함) 위치로 복귀됨');
    }
  }

  elActiveFolderLabel.onclick = resetToRootLocation;
  document.getElementById('btnRootReset').onclick = resetToRootLocation;
  document.getElementById('btnAutoSort').onclick = openAutoSortModal;

  elNoteList.onclick = function (e) {
    var target = e.target || e.srcElement;
    if (target === elNoteList) {
      resetToRootLocation();
    }
  };

  elNoteList.ondragover = function (e) {
    if (!state.dragPayload) return;
    var target = e.target || e.srcElement;
    if (target === elNoteList) {
      e.preventDefault();
      if (e.dataTransfer) e.dataTransfer.dropEffect = 'move';
    }
  };

  elNoteList.ondrop = function (e) {
    var target = e.target || e.srcElement;
    if (target === elNoteList && state.dragPayload) {
      e.preventDefault();
      e.stopPropagation();
      executeDropMove('');
    }
  };

  elActiveFolderBar.ondragover = function (e) {
    if (!state.dragPayload) return;
    e.preventDefault();
    if (e.dataTransfer) e.dataTransfer.dropEffect = 'move';
    if (this.className.indexOf('drag-over-target') === -1) {
      this.className += ' drag-over-target';
    }
  };

  elActiveFolderBar.ondragleave = function () {
    this.className = this.className.replace(/\bdrag-over-target\b/g, '').trim();
  };

  elActiveFolderBar.ondrop = function (e) {
    e.preventDefault();
    e.stopPropagation();
    this.className = this.className.replace(/\bdrag-over-target\b/g, '').trim();
    executeDropMove('');
  };

  function triggerVaultChange() {
    if (hasNative()) {
      var changed = window.NativeBridge.chooseVaultFolder();
      if (changed) {
        state.activeRelPath = null;
        state.selectedFolder = '';
        state.folderOrder = [];
        state.noteOrder = [];
        loadVaultFromNative(false);
      }
    }
  }

  document.getElementById('vaultHeaderBtn').onclick = triggerVaultChange;

  document.getElementById('btnRefreshVault').onclick = function () {
    loadVaultFromNative(true);
  };

  document.getElementById('btnRevealFinder').onclick = function () {
    var note = getActiveNote();
    if (note && hasNative()) {
      window.NativeBridge.revealInFinder(note.relPath);
    } else if (state.selectedFolder && hasNative()) {
      window.NativeBridge.revealInFinder(state.selectedFolder);
    } else if (hasNative()) {
      window.NativeBridge.revealInFinder('');
    }
  };

  document.getElementById('btnSyncVault').onclick = function () {
    if (hasNative()) {
      window.NativeBridge.syncVault();
      loadVaultFromNative(true);
    }
  };

  elSearchInput.oninput = function () {
    state.searchQuery = elSearchInput.value;
    renderSidebar();
  };
  elSearchInput.onkeyup = elSearchInput.oninput;

  document.onkeydown = function (e) {
    var key = (e.keyCode || e.which);

    /* 인쇄 설정 창이 떠 있을 때: Esc = 닫기, Enter = 인쇄 (다른 단축키는 막음) */
    if (state.isPrintModalOpen) {
      if (key === 27) {
        e.preventDefault();
        closePrintModal();
      } else if (key === 13) {
        e.preventDefault();
        confirmPrintModal();
      }
      return;
    }

    if (state.isModalOpen) {
      if (key === 13 && elModalInput.style.display === 'none') {
        e.preventDefault();
        elModalConfirm.click();
        return;
      } else if (key === 27) {
        e.preventDefault();
        closeModal();
        return;
      }
    }

    var isMod = e.metaKey || e.ctrlKey;
    if (!isMod) return;

    if (key === 8 || key === 46) {
      e.preventDefault();
      deleteSelectedItemOrNote();
    } else if (key === 83) { // Cmd + S
      e.preventDefault();
      syncEditorToDisk();
    } else if (key === 80) { // Cmd + P (인쇄 / PDF 저장)
      e.preventDefault();
      triggerPrintOrPDF();
    } else if (key === 77) { // Cmd + M (BGM 스탬프)
      e.preventDefault();
      insertNowPlayingBGMStamp();
    } else if (key === 71) { // Cmd + G (집필 천공 히트맵)
      e.preventDefault();
      openPunchCardStatsModal();
    } else if (key === 66) { // Cmd + B
      if (document.activeElement === elLiveEditor) {
        e.preventDefault();
        document.execCommand('bold', false, null);
        syncEditorToDisk();
      } else if (isGridMode() && document.activeElement === elGridInput) {
        e.preventDefault();
        gridWrapSelection('**', '**', '굵게');
      } else {
        e.preventDefault();
        toggleSidebar();
      }
    } else if (key === 73) { // Cmd + I
      if (document.activeElement === elLiveEditor) {
        e.preventDefault();
        document.execCommand('italic', false, null);
        syncEditorToDisk();
      } else if (isGridMode() && document.activeElement === elGridInput) {
        e.preventDefault();
        gridWrapSelection('*', '*', '기울임');
      }
    } else if (key === 220) { // Cmd + \
      e.preventDefault();
      toggleSidebar();
    }
  };

  /* ==========================================================================
     v2.8 사이드바 항목 메뉴 — 우클릭 · Control+클릭 · 길게 누르기
     · 폴더 / 노트 / 빈 곳에서 메뉴를 연다. 여는 방법은 세 가지:
         (1) 우클릭(두 손가락 클릭 포함)  (2) Control + 클릭  (3) 마우스(트랙패드) 단추를 길게 누르기
     · 길게 눌러 연 경우에는 단추를 누른 채 항목 위로 옮겨서 떼면 바로 실행된다. 그냥 떼면 메뉴가 열린 채로 남는다.
     · 항목은 끌어서 옮기기(drag)도 되므로, 길게 누르는 동안 포인터가 움직이면 메뉴를 열지 않는다.
     ========================================================================== */
  var CTX_PRESS_MS = 550;       /* 이만큼 누르고 있으면 메뉴를 연다 */
  var CTX_PRESS_SLOP = 6;       /* 누르는 동안 이 거리(px)보다 많이 움직이면 길게 누르기가 아니다(끌기) */
  var CTX_GESTURE_MS = 250;     /* 메뉴를 연 바로 그 클릭에 딸려 오는 mousedown 으로 보는 시간 (같은 자리에서 온 것만) */

  var elCtxMenu = document.createElement('div');
  elCtxMenu.id = 'ctxMenu';
  elCtxMenu.className = 'ctx-menu';
  document.body.appendChild(elCtxMenu);

  var ctx = {
    open: false,
    openedAt: 0,
    pressHold: false,       /* 길게 눌러서 열었고, 아직 단추를 떼지 않았다 */
    downSinceOpen: false,   /* 메뉴가 열린 뒤에 단추가 (새로) 눌린 적이 있다 */
    gestureTail: false,     /* 메뉴를 연 그 클릭의 mouseup · click 이 아직 남아 있다 (삼켜야 함) */
    swallowClick: false,    /* 바로 다음 click 한 번을 삼킨다 */
    targetEl: null,
    items: [],
    hotIdx: -1,
    openX: 0,
    openY: 0,
    pressTimer: null,
    pressX: 0,
    pressY: 0,
    pressLi: null
  };

  function ctxNow() { return new Date().getTime(); }

  function ctxInside(node, container) {
    while (node) {
      if (node === container) return true;
      node = node.parentNode;
    }
    return false;
  }

  /* 눌린 곳이 속한 사이드바 항목(li)을 찾는다. 항목 밖(목록의 빈 곳)이면 null */
  function ctxItemFromTarget(node) {
    while (node && node !== elNoteList && node !== document.body) {
      if (node.nodeType === 1 && node.hasAttribute && node.hasAttribute('data-tg-kind')) return node;
      node = node.parentNode;
    }
    return null;
  }

  /* 포인터 아래에 있는 메뉴 항목의 번호 (없으면 -1) */
  function ctxIndexFromNode(node) {
    while (node && node !== elCtxMenu && node !== document.body) {
      if (node.nodeType === 1 && node.hasAttribute && node.hasAttribute('data-ctx-idx')) {
        return parseInt(node.getAttribute('data-ctx-idx'), 10);
      }
      node = node.parentNode;
    }
    return -1;
  }

  function ctxFolderExists(path) {
    return state.folders.indexOf(path) !== -1;
  }

  function ctxFindNote(relPath) {
    for (var i = 0; i < state.notes.length; i++) {
      if (state.notes[i].relPath === relPath) return state.notes[i];
    }
    return null;
  }

  function ctxSwallow(e) {
    if (e.stopPropagation) e.stopPropagation();
    if (e.preventDefault) e.preventDefault();
  }

  /* ---------- 메뉴에서 실행하는 동작 ---------- */
  function ctxRefresh() {
    loadVaultFromNative(true);
    updateSaveStatus('보관함을 다시 읽었습니다 (새로고침)');
  }

  function ctxReveal(path) {
    if (hasNative()) window.NativeBridge.revealInFinder(path || '');
  }

  function ctxNewNoteIn(folderPath) {
    if (folderPath && !ctxFolderExists(folderPath)) { ctxRefresh(); return; }
    state.selectedFolder = folderPath || '';
    state.selectionTargetType = folderPath ? 'folder' : 'note';
    updateSelectedFolderUI();
    createNewNote();
  }

  function ctxNewSubfolderIn(folderPath) {
    if (folderPath) {
      if (!ctxFolderExists(folderPath)) { ctxRefresh(); return; }
      state.selectedFolder = folderPath;
      state.selectionTargetType = 'folder';
      state.collapsedFolders[folderPath] = false;
      updateSelectedFolderUI();
      renderSidebar();
    }
    promptCreateSubfolder(folderPath || '');
  }

  function ctxMoveToRoot(kind, path) {
    state.dragPayload = { type: kind, path: path, name: path.split('/').pop() };
    executeDropMove('');
  }

  function ctxOpenNote(relPath) {
    var note = ctxFindNote(relPath);
    if (!note) { ctxRefresh(); return; }
    state.selectionTargetType = 'note';
    state.selectedFolder = note.folder || '';
    updateSelectedFolderUI();
    selectNote(relPath);
  }

  /* 이름을 바꾸는 중에만 잠깐 쓰는 임시 이름 (눈에 보이는 이름이라, 도중에 문제가 생겨도 항목이 숨지 않는다) */
  function ctxTempRel(rel) {
    var tag = ' (이름 바꾸는 중 ' + ctxNow() + ')';
    if (/\.md$/i.test(rel)) return rel.slice(0, rel.length - 3) + tag + rel.slice(rel.length - 3);
    return rel + tag;
  }

  /* 같은 폴더 안에서 이름만 바꾼다 (노트 · 폴더 공통, 네이티브의 moveItem 사용).
     대소문자만 다른 이름으로 바꾸는 경우(예: diary → Diary)에는, 대소문자를 구분하지 않는 Mac 디스크에서
     '이미 있는 이름'으로 보여 거절되므로 임시 이름을 한 번 거쳐서 바꾼다. 둘째 단계가 실패하면 원래 이름으로 되돌린다. */
  function moveItemRenaming(oldRel, newRel) {
    if (!hasNative()) return false;
    if (oldRel === newRel) return true;
    if (oldRel.toLowerCase() === newRel.toLowerCase()) {
      var tmpRel = ctxTempRel(oldRel);
      if (!window.NativeBridge.moveItem(oldRel, tmpRel)) return false;
      if (window.NativeBridge.moveItem(tmpRel, newRel)) return true;
      window.NativeBridge.moveItem(tmpRel, oldRel);
      return false;
    }
    return !!window.NativeBridge.moveItem(oldRel, newRel);
  }

  /* 폴더 이름 한 마디로 쓸 수 있게 다듬는다 (쓸 수 없는 글자는 _ 로, 맨 앞의 점은 뺀다: 점으로 시작하면 숨김 폴더가 된다) */
  function sanitizeFolderSegment(raw) {
    return String(raw || '').replace(/[\\/:*?"<>|]/g, '_').replace(/^[.\s]+/, '').replace(/\s+$/, '');
  }

  /* 폴더 이름이 바뀐 뒤: 순서 · 펼침 상태 · 선택 · 열려 있는 노트의 경로를 새 이름으로 고친다 (자리는 그대로) */
  function renameFolderInState(oldPath, newPath) {
    var prefix = oldPath + '/';
    function swap(p) {
      if (p === oldPath) return newPath;
      if (p.indexOf(prefix) === 0) return newPath + p.slice(oldPath.length);
      return p;
    }
    var i, k, nextCollapsed = {};
    for (i = 0; i < state.folderOrder.length; i++) state.folderOrder[i] = swap(state.folderOrder[i]);
    for (i = 0; i < state.noteOrder.length; i++) state.noteOrder[i] = swap(state.noteOrder[i]);
    for (k in state.collapsedFolders) {
      if (state.collapsedFolders.hasOwnProperty(k)) nextCollapsed[swap(k)] = state.collapsedFolders[k];
    }
    state.collapsedFolders = nextCollapsed;
    if (state.selectedFolder) state.selectedFolder = swap(state.selectedFolder);
    if (state.activeRelPath) state.activeRelPath = swap(state.activeRelPath);
    sheetMetaMove(oldPath, newPath, true);
  }

  function renameFolderTo(folderPath, rawName) {
    if (!hasNative()) return;
    if (!ctxFolderExists(folderPath)) { ctxRefresh(); return; }
    var parts = folderPath.split('/');
    var oldName = parts.pop();
    var parent = parts.join('/');
    var newName = sanitizeFolderSegment(rawName);
    if (!newName || newName === oldName) return;             /* 빈 입력 · 같은 이름: 아무것도 바꾸지 않는다 */
    var newPath = parent ? (parent + '/' + newName) : newName;
    var i, f;
    for (i = 0; i < state.folders.length; i++) {
      f = state.folders[i];
      if (f !== folderPath && f.toLowerCase() === newPath.toLowerCase()) {
        showModal('이름 변경 불가', '같은 위치에 "' + newName + '" 폴더가 이미 있습니다.', null, true);
        return;
      }
    }
    if (!moveItemRenaming(folderPath, newPath)) {
      showModal('이름 변경 불가', '폴더 이름을 바꿀 수 없습니다.\n같은 이름의 항목이 이미 있거나, 폴더 이름으로 쓸 수 없는 이름입니다 (너무 긴 이름 포함).', null, true);
      return;
    }
    renameFolderInState(folderPath, newPath);
    saveOrderConfigToNative();
    loadVaultFromNative(true);
    updateSaveStatus('폴더 이름 변경됨: ' + folderPath + ' → ' + newPath);
  }

  function promptRenameFolder(folderPath) {
    if (!ctxFolderExists(folderPath)) { ctxRefresh(); return; }
    var oldName = folderPath.split('/').pop();
    showPromptModal(
      '✏️ 폴더 이름 바꾸기',
      '📁 ' + folderPath + '\n새 이름을 입력하세요. 폴더 안의 노트와 하위 폴더는 그대로 따라갑니다.',
      '새 폴더 이름...',
      oldName,
      function (raw) { renameFolderTo(folderPath, raw); }
    );
  }

  function renameNoteTo(relPath, rawTitle) {
    var note = ctxFindNote(relPath);
    if (!hasNative()) return;
    if (!note) { ctxRefresh(); return; }
    if (!String(rawTitle || '').replace(/^\s+|\s+$/g, '')) return;   /* 빈 입력: 아무것도 바꾸지 않는다 */
    if (relPath === state.activeRelPath) {
      /* 열려 있는 노트: 상단 제목칸에서 고친 것과 똑같이 처리한다 (원고지 제목란도 함께 바뀜) */
      elTitleInput.value = rawTitle;
      commitTitleRename();
      return;
    }
    var newTitle = sanitizeSingleName(rawTitle);
    if (newTitle === note.title) return;
    var newRel = buildRelPath(note.folder, newTitle + '.md');
    var i, other;
    for (i = 0; i < state.notes.length; i++) {
      other = state.notes[i];
      if (other !== note && other.relPath.toLowerCase() === newRel.toLowerCase()) {
        showModal('이름 변경 불가', '같은 이름의 노트가 이미 이 폴더에 있습니다.', null, true);
        return;
      }
    }
    if (!moveItemRenaming(relPath, newRel)) {
      showModal('이름 변경 불가', '같은 이름의 노트가 이미 이 폴더에 있거나, 파일 이름으로 쓸 수 없는 제목입니다 (너무 긴 제목 포함).', null, true);
      return;
    }
    var idx = state.noteOrder.indexOf(relPath);
    if (idx !== -1) state.noteOrder[idx] = newRel;
    sheetMetaMove(relPath, newRel, false);
    note.title = newTitle;
    note.filename = newTitle + '.md';
    note.relPath = newRel;
    saveOrderConfigToNative();
    renderSidebar();
    updateSaveStatus('파일 이름 변경됨: ' + newRel);
  }

  function promptRenameNote(relPath) {
    var note = ctxFindNote(relPath);
    if (!note) { ctxRefresh(); return; }
    showPromptModal(
      '✏️ 노트 이름 바꾸기',
      '📄 ' + relPath + '\n새 제목을 입력하세요 (.md 는 자동으로 붙습니다).',
      '새 노트 제목...',
      note.title,
      function (raw) { renameNoteTo(relPath, raw); }
    );
  }

  /* 메뉴에서 고른 노트 하나를 지운다 (열려 있는 노트가 아니어도 된다) */
  function confirmDeleteNote(relPath) {
    var note = ctxFindNote(relPath);
    if (!note) { ctxRefresh(); return; }
    showModal(
      '노트 삭제 확인',
      '실제 파인더 폴더에서 "' + relPath + '" 파일을 삭제하시겠습니까?\n(Enter를 누르면 즉시 삭제됩니다)',
      function () {
        if (!hasNative()) return;
        var target = ctxFindNote(relPath);
        if (!target) { ctxRefresh(); return; }
        if (state.activeRelPath === relPath) {
          window.NativeBridge.deleteNote(relPath);
          sheetMetaDelete(relPath, false);
          state.activeRelPath = null;
          loadVaultFromNative(false);
        } else {
          /* 열려 있지 않은 노트: 편집 중인 화면은 건드리지 않고 목록에서만 뺀다 */
          window.NativeBridge.deleteNote(relPath);
          sheetMetaDelete(relPath, false);
          var i = state.notes.indexOf(target);
          if (i !== -1) state.notes.splice(i, 1);
          i = state.noteOrder.indexOf(relPath);
          if (i !== -1) state.noteOrder.splice(i, 1);
          saveOrderConfigToNative();
          renderSidebar();
        }
        updateSaveStatus('파일 삭제 완료: ' + relPath);
      },
      false
    );
  }

  /* ---------- 메뉴 만들기 · 열기 · 닫기 ---------- */
  function ctxBuildItems(kind, path) {
    var list = [];
    function add(label, fn, danger, disabled) {
      list.push({ label: label, fn: fn, danger: !!danger, disabled: !!disabled });
    }
    function sep() {
      if (list.length && !list[list.length - 1].sep) list.push({ sep: true });
    }
    if (kind === 'folder') {
      add('✏️ 이름 바꾸기…', function () { promptRenameFolder(path); });
      add('＋ 이 폴더에 새 노트', function () { ctxNewNoteIn(path); });
      add('📁 하위 폴더 추가…', function () { ctxNewSubfolderIn(path); });
      if (path.indexOf('/') !== -1) add('⤴ 최상위(루트)로 옮기기', function () { ctxMoveToRoot('folder', path); });
      sep();
      add('🔍 Finder에서 보기', function () { ctxReveal(path); });
      add('⇅ 자동 정렬…', function () { openAutoSortModal(); });
      add('🔄 새로고침', ctxRefresh);
      sep();
      add('✖ 폴더 삭제…', function () { confirmDeleteFolder(path); }, true);
    } else if (kind === 'note') {
      var note = ctxFindNote(path);
      add('📖 열기', function () { ctxOpenNote(path); }, false, path === state.activeRelPath);
      add('✏️ 이름 바꾸기…', function () { promptRenameNote(path); });
      if (note && note.folder) add('⤴ 최상위(루트)로 옮기기', function () { ctxMoveToRoot('note', path); });
      sep();
      add('🔍 Finder에서 보기', function () { ctxReveal(path); });
      add('⇅ 자동 정렬…', function () { openAutoSortModal(); });
      add('🔄 새로고침', ctxRefresh);
      sep();
      add('✖ 노트 삭제…', function () { confirmDeleteNote(path); }, true);
    } else {
      add('＋ 새 노트', function () { ctxNewNoteIn(''); });
      add('📁 새 폴더…', function () { ctxNewSubfolderIn(''); });
      sep();
      add('🔍 Finder에서 보관함 보기', function () { ctxReveal(''); });
      add('⇅ 자동 정렬…', function () { openAutoSortModal(); });
      add('🔄 새로고침', ctxRefresh);
    }
    return list;
  }

  function ctxSetHot(idx) {
    if (idx === ctx.hotIdx) return;
    var nodes = elCtxMenu.childNodes, i, n;
    for (i = 0; i < nodes.length; i++) {
      n = nodes[i];
      if (n.nodeType !== 1 || !n.hasAttribute('data-ctx-idx')) continue;
      setCls(n, 'hot', parseInt(n.getAttribute('data-ctx-idx'), 10) === idx);
    }
    ctx.hotIdx = idx;
  }

  function ctxClose() {
    if (!ctx || !ctx.open) return;
    ctx.open = false;
    ctx.pressHold = false;
    ctx.hotIdx = -1;
    ctx.items = [];
    elCtxMenu.className = 'ctx-menu';
    elCtxMenu.innerHTML = '';
    if (ctx.targetEl) {
      setCls(ctx.targetEl, 'ctx-target', false);
      ctx.targetEl = null;
    }
  }

  function ctxOpen(li, x, y, byPress) {
    ctxClose();
    var kind = li ? li.getAttribute('data-tg-kind') : 'blank';
    var path = li ? li.getAttribute('data-tg-path') : '';
    var items = ctxBuildItems(kind, path);
    var head = (kind === 'folder') ? ('📁 ' + path.split('/').pop())
      : (kind === 'note') ? ('📄 ' + path.split('/').pop().replace(/\.md$/i, ''))
      : '📕 보관함';
    var html = '<div class="ctx-head">' + escapeHtml(head) + '</div>', i, it, cls;
    for (i = 0; i < items.length; i++) {
      it = items[i];
      if (it.sep) { html += '<div class="ctx-sep"></div>'; continue; }
      cls = 'ctx-item' + (it.danger ? ' danger' : '') + (it.disabled ? ' disabled' : '');
      html += '<div class="' + cls + '" data-ctx-idx="' + i + '">' + escapeHtml(it.label) + '</div>';
    }
    elCtxMenu.innerHTML = html;
    elCtxMenu.className = 'ctx-menu show';
    elCtxMenu.setAttribute('data-ctx-kind', kind);

    /* 포인터 바로 옆에 연다. 창 밖으로 나가면 반대쪽(왼쪽 · 위쪽)으로 뒤집어, 되도록 포인터 밑에 항목이 오지 않게 한다 */
    var w = elCtxMenu.offsetWidth, h = elCtxMenu.offsetHeight;
    var vw = window.innerWidth || document.documentElement.clientWidth;
    var vh = window.innerHeight || document.documentElement.clientHeight;
    var left = x + 2, top = y + 2;
    if (left + w > vw - 6) left = x - w - 2;
    if (left < 6) left = Math.max(6, Math.min(x + 2, vw - w - 6));
    if (top + h > vh - 6) top = y - h - 2;
    if (top < 6) top = Math.max(6, vh - h - 6);
    elCtxMenu.style.left = left + 'px';
    elCtxMenu.style.top = top + 'px';

    ctx.items = items;
    ctx.open = true;
    ctx.openedAt = ctxNow();
    ctx.openX = x;
    ctx.openY = y;
    ctx.pressHold = !!byPress;
    ctx.downSinceOpen = false;
    ctx.gestureTail = false;
    ctx.hotIdx = -1;
    if (li) {
      ctx.targetEl = li;
      setCls(li, 'ctx-target', true);
    }
  }

  function ctxActivate(idx) {
    var it = ctx.items[idx];
    if (!it || it.sep || it.disabled) return;
    ctxClose();
    it.fn();
  }

  function ctxCancelPress() {
    if (ctx.pressTimer) {
      clearTimeout(ctx.pressTimer);
      ctx.pressTimer = null;
    }
    ctx.pressLi = null;
  }

  /* ---------- 여는 방법 1 · 2: 우클릭 / Control+클릭 (브라우저가 contextmenu 이벤트로 알려 준다) ---------- */
  elNoteList.addEventListener('contextmenu', function (e) {
    ctxSwallow(e);                      /* 기본 메뉴(새로 고침 등) 대신 우리 메뉴를 연다 */
    ctxCancelPress();
    if (state.isModalOpen) return;
    var t = e.target || e.srcElement;
    ctxOpen(ctxItemFromTarget(t), e.clientX, e.clientY, false);
  }, false);

  /* ---------- 여는 방법 3: 길게 누르기 ---------- */
  elNoteList.addEventListener('mousedown', function (e) {
    ctxCancelPress();
    if (e.button !== 0 || e.ctrlKey || state.isModalOpen) return;
    var t = e.target || e.srcElement, n = t;
    while (n && n !== elNoteList) {
      if (n.tagName === 'BUTTON') return;          /* 폴더 줄의 작은 단추(+ · ×)는 제외 */
      n = n.parentNode;
    }
    var li = ctxItemFromTarget(t);
    if (!li && t !== elNoteList) return;
    ctx.pressX = e.clientX;
    ctx.pressY = e.clientY;
    ctx.pressLi = li;
    ctx.pressTimer = setTimeout(function () {
      var target = ctx.pressLi;
      ctx.pressTimer = null;
      ctx.pressLi = null;
      if (state.isModalOpen) return;
      if (target && target.parentNode !== elNoteList) return;      /* 그 사이에 목록이 다시 그려졌다 */
      ctxOpen(target, ctx.pressX, ctx.pressY, true);
    }, CTX_PRESS_MS);
  }, false);

  /* 끌기가 시작되면 길게 누르기가 아니다. 메뉴가 열려 있는 동안에는 끌기를 시작하지 않는다 */
  elNoteList.addEventListener('dragstart', function (e) {
    ctxCancelPress();
    if (ctx.open) ctxSwallow(e);
  }, true);

  elNoteList.addEventListener('scroll', function () {
    ctxCancelPress();
    ctxClose();
  }, false);

  /* ---------- 문서 전체: 메뉴가 열려 있을 때의 마우스 · 키 처리 (다른 처리보다 먼저 받는다) ---------- */
  document.addEventListener('mousemove', function (e) {
    if (ctx.pressTimer) {
      var dx = e.clientX - ctx.pressX, dy = e.clientY - ctx.pressY;
      if (dx * dx + dy * dy > CTX_PRESS_SLOP * CTX_PRESS_SLOP) ctxCancelPress();
    }
    if (ctx.open && ctx.pressHold) {
      /* 단추를 누른 채 움직이는 동안: 포인터 아래 항목을 밝힌다 */
      ctxSetHot(ctxIndexFromNode(document.elementFromPoint(e.clientX, e.clientY)));
    }
  }, true);

  document.addEventListener('mousedown', function (e) {
    if (!ctx.open) return;
    var t = e.target || e.srcElement;
    if (!ctx.pressHold && !ctx.downSinceOpen && (ctxNow() - ctx.openedAt) < CTX_GESTURE_MS &&
        Math.abs(e.clientX - ctx.openX) <= 3 && Math.abs(e.clientY - ctx.openY) <= 3) {
      /* 메뉴를 연 바로 그 클릭의 mousedown 이 (같은 자리에서) 뒤늦게 온 것 — Control+클릭을 이렇게 전달하는 경우가 있다.
         메뉴는 그대로 두고 이 클릭(mousedown · mouseup · click)은 삼킨다 */
      ctx.downSinceOpen = true;
      ctx.gestureTail = true;
      ctxSwallow(e);
      return;
    }
    ctx.downSinceOpen = true;
    if (ctxInside(t, elCtxMenu)) {
      if (e.preventDefault) e.preventDefault();    /* 편집기의 커서 · 선택을 건드리지 않는다 */
      return;
    }
    ctxClose();                                    /* 메뉴 밖을 누르면 닫는다 (그 클릭은 평소대로 동작) */
  }, true);

  document.addEventListener('mouseup', function (e) {
    ctxCancelPress();
    if (ctx.gestureTail) {
      ctx.gestureTail = false;
      ctx.swallowClick = true;
      setTimeout(function () { ctx.swallowClick = false; }, 0);
      ctxSwallow(e);
      return;
    }
    if (ctx.open && ctx.pressHold) {
      /* 길게 눌러 연 뒤 단추를 뗐다: 항목 위로 옮겨서 뗐으면 실행, 제자리에서 뗐으면 메뉴를 열어 둔다 */
      var dx = e.clientX - ctx.pressX, dy = e.clientY - ctx.pressY;
      var idx = (dx * dx + dy * dy > CTX_PRESS_SLOP * CTX_PRESS_SLOP)
        ? ctxIndexFromNode(document.elementFromPoint(e.clientX, e.clientY)) : -1;
      ctx.pressHold = false;
      ctx.downSinceOpen = true;
      ctxSetHot(-1);
      ctx.swallowClick = true;                     /* 이 누름에 딸려 오는 click 은 항목(노트 열기 · 폴더 접기)에 전달하지 않는다 */
      setTimeout(function () { ctx.swallowClick = false; }, 0);
      ctxSwallow(e);
      if (idx !== -1) ctxActivate(idx);
    }
  }, true);

  document.addEventListener('click', function (e) {
    if (ctx.swallowClick) {
      ctx.swallowClick = false;
      ctxSwallow(e);
      return;
    }
    if (!ctx.open) return;
    if (!ctx.downSinceOpen) {
      /* 메뉴가 열린 뒤 새로 누른 적이 없는데 온 click = 메뉴를 연 그 클릭의 꼬리(Control+클릭): 삼킨다 */
      ctx.downSinceOpen = true;
      ctxSwallow(e);
      return;
    }
    var t = e.target || e.srcElement;
    if (ctxInside(t, elCtxMenu)) {
      ctxSwallow(e);
      ctxActivate(ctxIndexFromNode(t));
    }
  }, true);

  document.addEventListener('keydown', function (e) {
    if (!ctx.open) return;
    if ((e.keyCode || e.which) === 27) {           /* Esc: 메뉴만 닫는다 */
      ctxSwallow(e);
      ctxClose();
    }
  }, true);

  window.addEventListener('blur', function () {
    ctxCancelPress();
    ctxClose();
  }, false);
  window.addEventListener('resize', function () {
    ctxClose();
  }, false);

  window.TypeGrapherApp = {
    reloadVault: function () { loadVaultFromNative(true); },
    showStatus: function (msg) { updateSaveStatus(String(msg)); },
    newNote: function () { createNewNote(); },
    dailyNote: function () { openOrCreateDailyNote(); },
    newSubfolder: function () { promptCreateSubfolder(); },
    autoSort: function () { openAutoSortModal(); },
    deleteNote: function () { deleteSelectedItemOrNote(); },
    changeVault: function () { triggerVaultChange(); },
    toggleTheme: function () { toggleTheme(); },
    toggleSound: function () { toggleKeySound(); },
    toggleBell: function () { toggleBellSound(); },
    toggleFocus: function () { toggleFocusLightMode(); },
    stampBGM: function () { insertNowPlayingBGMStamp(); },
    openStats: function () { openPunchCardStatsModal(); },
    printNote: function () { triggerPrintOrPDF(); },
    exportPDF: function () { quickExportPDF(); },
    /* 진단용: 조판 레이아웃으로 바꾸고 조판 작업(JSON)을 돌려준다. 확인 후 반드시 printLayoutEnd() 호출 */
    printLayoutBegin: function (target) { return JSON.stringify(printEnter(state.printOpts, target === 'pad' ? 'pad' : 'note')); },
    printLayoutEnd: function () { printExit(); },
    syncVault: function () { document.getElementById('btnSyncVault').click(); }
  };

  window.onload = function () {
    loadVaultFromNative(false);
  };
})();
</script>
</body>
</html>
'''

html_file = os.path.join(res_dir, "typegrapher.html")
with open(html_file, "w", encoding="utf-8") as f:
    f.write(html_content)

# 3. Objective-C Cocoa + WebKit 브릿지 (절차적 WAV 타건음/벨 합성기 + iTunes/Music BGM 스탬프 + 네이티브 Print/PDF 통합)
objc_source = r'''
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

/* 조판 엔진(PDF 합성 · PDF 인쇄, v2.3 도입). 빌더가 먼저 1 로 컴파일하고, 실패하면 0 으로 다시 컴파일합니다. */
#ifndef TG_PDF_ENGINE
#define TG_PDF_ENGINE 1
#endif
#if TG_PDF_ENGINE
/* PDFKit 은 링크하지 않고 실행 중에 찾아 씁니다 (구형 Mac 에서 앱이 열리지 않는 문제를 피하기 위해).
   그래서 <Quartz/Quartz.h> 를 가져오지 않고, 필요한 메서드 하나와 상수 하나만 여기에 적어 둡니다.
   printOperationForPrintInfo:scalingMode:autoRotate: 는 PDFDocument 의 메서드(10.7 이후)입니다. */
#include <dlfcn.h>
@interface NSObject (TGPDFKitAtRuntime)
- (NSPrintOperation *)printOperationForPrintInfo:(NSPrintInfo *)printInfo scalingMode:(NSInteger)scalingMode autoRotate:(BOOL)autoRotate;
@end
enum { TGPDFPrintPageScaleToFit = 1 };   /* PDFKit 의 kPDFPrintPageScaleToFit 과 같은 값 */
#endif
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* ===== TGSYNC CORE BEGIN =====================================================================
   양방향 동기화의 '삭제 전파' (v2.7)

   rsync 두 번(보내기 · 가져오기)만으로는 한쪽에서 지운 파일이 반대쪽에서 되살아납니다. 지운 것인지,
   반대쪽에서 새로 만든 것인지 구별할 정보가 없기 때문입니다. 그래서 동기화가 성공할 때마다 그때의
   파일 목록(스냅샷)을 두 폴더 안의 숨김 폴더 .typegrapher-sync 에 적어 두고, 다음 동기화 때 스냅샷과
   양쪽의 현재 목록을 비교합니다. 기록이 폴더와 함께 있으므로, 두 Mac 중 어느 쪽에서 동기화를 실행해도
   (내 보관함과 대상이 서로 뒤바뀌어도) 같은 기록을 봅니다.

     · 스냅샷에 있고, 한쪽에는 없고, 반대쪽에는 '지난 동기화 때 그대로' 있다  → 지운 것 → 반대쪽에서도 치움
     · 스냅샷에 있고, 한쪽에는 없는데, 반대쪽에서는 그 뒤에 수정되었다        → 지우지 않음 (수정이 이김)
     · 스냅샷에 없다                                                          → 새 파일 → rsync 가 복사

   안전장치
     · 치운 항목은 지우지 않고 같은 폴더의 숨김 폴더 .typegrapher-trash/날짜-시각/ 로 옮깁니다 (되돌릴 수 있음).
     · 각 폴더에 표식 파일 .typegrapher-sync-id 를 둡니다. 스냅샷은 '표식 값의 짝'으로 찾으므로, 대상이
       비어 있는 엉뚱한 폴더로 바뀌었거나 볼륨이 풀려 빈 폴더만 남은 경우에는 스냅샷이 맞지 않아
       아무것도 지우지 않습니다.
     · 스냅샷은 두 폴더에 같은 내용으로 적고 세대 번호를 붙입니다. 한쪽 사본이 없거나 깨졌으면 다른 쪽을,
       둘이 다르면 세대 번호가 큰 쪽을 씁니다. 둘 다 쓸 수 없으면 '기록 없음'으로 보고 아무것도 지우지 않습니다.
     · 지우기 직전마다 '반대쪽에 정말 없는지'(ENOENT)와 '반대쪽 표식이 그대로인지'를 다시 확인하고,
       확인할 수 없으면(입출력 오류 등) 삭제 전파 전체를 멈춥니다.
     · 목록을 끝까지 읽지 못했으면 삭제 전파를 하지 않습니다.
     · 이름이 '.' 으로 시작하는 항목은 rsync 의 --exclude=.* 와 똑같이 건드리지 않습니다.

   이 구역은 순수 C(POSIX) 입니다. Objective-C 를 쓰지 않으므로 다른 유닉스에서도 같은 소스를 그대로
   컴파일해 시험할 수 있습니다.
   ============================================================================================ */
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#define TGS_MARKER_NAME  ".typegrapher-sync-id"
#define TGS_TRASH_NAME   ".typegrapher-trash"
#define TGS_STATE_NAME   ".typegrapher-sync"
#define TGS_PATH_MAX     4096
#define TGS_ID_LEN       32
#define TGS_MTIME_SLACK  2      /* 초. 파일 시스템마다 시각을 적는 정밀도가 달라서 두는 여유 */
#define TGS_MAX_DEPTH    64

/* 상대 경로를 비교용 표준형으로 바꾸는 함수 (앱에서는 한글 자모 분리형(NFD)/조합형(NFC) 차이를 없애기 위해 NFC 로 바꿈).
   성공하면 0. out 에 다 들어가지 않으면 0 이 아닌 값을 돌려준다. */
typedef int (*tgs_norm_fn)(const char *raw, char *out, size_t outSize);

typedef struct {
    char *key;          /* 비교용 상대 경로 (표준형) */
    char *raw;          /* 디스크에 적힌 그대로의 상대 경로 */
    int isDir;
    long long mtime;    /* 초 */
    long long size;
    int dup;            /* 같은 key 가 둘 이상 (표준형만 같은 다른 이름이 같이 있음) → 삭제 판단에서 제외 */
} tgs_entry;

typedef struct {
    tgs_entry *items;
    size_t count, cap;
    int failed;         /* 목록을 끝까지 읽지 못함 → 이 목록으로는 '없다'고 판단하면 안 됨 */
} tgs_list;

typedef struct {
    char *key;
    int isDir;
    long long mtimeA, sizeA, mtimeB, sizeB;
} tgs_snap_entry;

typedef struct {
    tgs_snap_entry *items;
    size_t count, cap;
} tgs_snapshot;

typedef struct {
    int firstSync;      /* 이 짝(보관함 ↔ 대상)의 지난 동기화 기록이 없어 삭제 전파를 하지 않았음 */
    int skipped;        /* 안전을 위해 삭제 전파를 건너뜀 (목록을 끝까지 읽지 못함) */
    int aborted;        /* 삭제 전파 도중 멈춤 (반대쪽을 더 이상 확인할 수 없음) */
    int deletedA;       /* 대상에서 지워져서 내 보관함(A)에서 치운 항목 수 */
    int deletedB;       /* 내 보관함에서 지워져서 대상(B)에서 치운 항목 수 */
    int keptModified;   /* 한쪽에서 지워졌지만 반대쪽에서 수정되어 지우지 않은 파일 수 */
    int moveFailed;     /* 치우려 했으나 옮기지 못한 항목 수 */
    char trashBatch[32];/* 이번에 쓴 .typegrapher-trash 아래 폴더 이름 */
} tgs_report;

#ifdef TGS_TESTING
static void (*tgs_test_hook_before_apply)(void) = NULL;    /* 시험 전용: 계획을 세운 뒤, 치우기 직전에 호출 */
#endif

/* ---------- 작은 도구 ---------- */
static int tgs_join(char *out, size_t outSize, const char *a, const char *b) {
    int n;
    if (!b || !b[0]) n = snprintf(out, outSize, "%s", a);
    else if (!a || !a[0]) n = snprintf(out, outSize, "%s", b);
    else n = snprintf(out, outSize, "%s/%s", a, b);
    return (n < 0 || (size_t)n >= outSize) ? -1 : 0;
}

static void tgs_list_free(tgs_list *l) {
    size_t i;
    for (i = 0; i < l->count; i++) { free(l->items[i].key); free(l->items[i].raw); }
    free(l->items);
    l->items = NULL; l->count = l->cap = 0;
}

static void tgs_snapshot_free(tgs_snapshot *s) {
    size_t i;
    for (i = 0; i < s->count; i++) free(s->items[i].key);
    free(s->items);
    s->items = NULL; s->count = s->cap = 0;
}

static int tgs_entry_cmp(const void *x, const void *y) {
    return strcmp(((const tgs_entry *)x)->key, ((const tgs_entry *)y)->key);
}

static int tgs_snap_cmp(const void *x, const void *y) {
    return strcmp(((const tgs_snap_entry *)x)->key, ((const tgs_snap_entry *)y)->key);
}

static tgs_entry *tgs_find(tgs_list *l, const char *key) {
    tgs_entry probe;
    if (l->count == 0) return NULL;
    probe.key = (char *)key;
    return (tgs_entry *)bsearch(&probe, l->items, l->count, sizeof(tgs_entry), tgs_entry_cmp);
}

static int tgs_depth_of(const char *key) {
    int d = 0;
    const char *p;
    for (p = key; *p; p++) if (*p == '/') d++;
    return d;
}

static int tgs_snap_depth_desc(const void *x, const void *y) {
    int dx = tgs_depth_of(((const tgs_snap_entry *)x)->key), dy = tgs_depth_of(((const tgs_snap_entry *)y)->key);
    if (dx != dy) return dy - dx;
    return strcmp(((const tgs_snap_entry *)x)->key, ((const tgs_snap_entry *)y)->key);
}

static int tgs_unchanged(long long mtimeNow, long long sizeNow, long long mtimeThen, long long sizeThen) {
    long long d = mtimeNow - mtimeThen;
    if (d < 0) d = -d;
    return d <= TGS_MTIME_SLACK && sizeNow == sizeThen;
}

/* ---------- 폴더 목록 ---------- */
static void tgs_list_add(tgs_list *l, const char *raw, int isDir, long long mtime, long long size, tgs_norm_fn norm) {
    char key[TGS_PATH_MAX];
    tgs_entry *e;
    if (norm(raw, key, sizeof(key)) != 0) { l->failed = 1; return; }
    if (l->count == l->cap) {
        size_t ncap = l->cap ? l->cap * 2 : 256;
        tgs_entry *n = (tgs_entry *)realloc(l->items, ncap * sizeof(tgs_entry));
        if (!n) { l->failed = 1; return; }
        l->items = n; l->cap = ncap;
    }
    e = &l->items[l->count];
    e->key = strdup(key);
    e->raw = strdup(raw);
    if (!e->key || !e->raw) { free(e->key); free(e->raw); l->failed = 1; return; }
    e->isDir = isDir; e->mtime = mtime; e->size = size; e->dup = 0;
    l->count++;
}

static void tgs_walk(const char *root, const char *rel, tgs_list *l, tgs_norm_fn norm, int depth) {
    /* 경로 버퍼 셋은 힙에 둔다. 이 함수는 폴더 깊이만큼 재귀하는데, 앱에서는 스택이 작은 백그라운드 스레드에서
       실행되므로 단계마다 스택에 큰 버퍼를 잡으면 깊은 폴더에서 스택이 넘칠 수 있다. */
    char *buf = (char *)malloc(3 * (size_t)TGS_PATH_MAX);
    char *dirPath, *childRel, *childPath;
    DIR *d;
    struct dirent *e;
    struct stat st;
    if (!buf) { l->failed = 1; return; }
    dirPath = buf; childRel = buf + TGS_PATH_MAX; childPath = buf + 2 * TGS_PATH_MAX;
    if (tgs_join(dirPath, TGS_PATH_MAX, root, rel) != 0) { l->failed = 1; free(buf); return; }
    d = opendir(dirPath);
    if (!d) { l->failed = 1; free(buf); return; }
    for (;;) {
        errno = 0;
        e = readdir(d);
        if (!e) { if (errno != 0) l->failed = 1; break; }
        if (e->d_name[0] == '.') continue;                       /* 숨김 이름('.', '..' 포함)은 동기화 대상이 아님 */
        if (strchr(e->d_name, '\n') || strchr(e->d_name, '\r')) continue;   /* 줄바꿈이 든 이름은 기록할 수 없으므로 추적하지 않음(절대 지우지 않음) */
        if (tgs_join(childRel, TGS_PATH_MAX, rel, e->d_name) != 0 ||
            tgs_join(childPath, TGS_PATH_MAX, root, childRel) != 0) { l->failed = 1; continue; }
        if (lstat(childPath, &st) != 0) { l->failed = 1; continue; }
        if (S_ISDIR(st.st_mode)) {
            tgs_list_add(l, childRel, 1, 0, 0, norm);
            if (depth < TGS_MAX_DEPTH) tgs_walk(root, childRel, l, norm, depth + 1);
            else l->failed = 1;
        } else {
            tgs_list_add(l, childRel, 0, (long long)st.st_mtime, (long long)st.st_size, norm);
        }
    }
    closedir(d);
    free(buf);
}

static void tgs_list_tree(const char *root, tgs_norm_fn norm, tgs_list *l) {
    size_t i;
    memset(l, 0, sizeof(*l));
    tgs_walk(root, "", l, norm, 0);
    if (l->count > 1) qsort(l->items, l->count, sizeof(tgs_entry), tgs_entry_cmp);
    for (i = 1; i < l->count; i++) {
        if (strcmp(l->items[i - 1].key, l->items[i].key) == 0) { l->items[i - 1].dup = 1; l->items[i].dup = 1; }
    }
}

/* ---------- 표식 파일 ---------- */
static int tgs_valid_id(const char *text) {
    int i;
    for (i = 0; i < TGS_ID_LEN; i++) {
        char c = text[i];
        if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f'))) return 0;
    }
    return text[TGS_ID_LEN] == '\0';
}

/* 1: 읽음, 0: 표식 파일이 없음(ENOENT), -1: 읽을 수 없거나 내용이 올바르지 않음 */
static int tgs_read_marker(const char *root, char *idOut) {
    char path[TGS_PATH_MAX], buf[TGS_ID_LEN + 8];
    FILE *f;
    size_t n;
    if (tgs_join(path, sizeof(path), root, TGS_MARKER_NAME) != 0) return -1;
    f = fopen(path, "r");
    if (!f) return (errno == ENOENT) ? 0 : -1;
    n = fread(buf, 1, sizeof(buf) - 1, f);
    fclose(f);
    buf[n] = '\0';
    while (n > 0 && (buf[n - 1] == '\n' || buf[n - 1] == '\r' || buf[n - 1] == ' ')) buf[--n] = '\0';
    if (n != TGS_ID_LEN || !tgs_valid_id(buf)) return -1;
    memcpy(idOut, buf, TGS_ID_LEN + 1);
    return 1;
}

static void tgs_make_id(char *idOut) {
    static const char hex[] = "0123456789abcdef";
    unsigned char bytes[TGS_ID_LEN / 2];
    size_t got = 0, i;
    FILE *f = fopen("/dev/urandom", "r");
    if (f) { got = fread(bytes, 1, sizeof(bytes), f); fclose(f); }
    if (got != sizeof(bytes)) {
        unsigned long seed = (unsigned long)time(NULL) ^ ((unsigned long)getpid() << 16) ^ (unsigned long)clock();
        for (i = 0; i < sizeof(bytes); i++) { seed = seed * 1103515245UL + 12345UL; bytes[i] = (unsigned char)(seed >> 16); }
    }
    for (i = 0; i < sizeof(bytes); i++) { idOut[i * 2] = hex[bytes[i] >> 4]; idOut[i * 2 + 1] = hex[bytes[i] & 15]; }
    idOut[TGS_ID_LEN] = '\0';
}

/* 표식을 읽고, 없으면 새로 만든다. 0: 성공, -1: 실패 */
static int tgs_ensure_marker(const char *root, char *idOut) {
    char path[TGS_PATH_MAX];
    int r = tgs_read_marker(root, idOut), fd;
    if (r == 1) return 0;
    if (r < 0) return -1;
    if (tgs_join(path, sizeof(path), root, TGS_MARKER_NAME) != 0) return -1;
    tgs_make_id(idOut);
    fd = open(path, O_WRONLY | O_CREAT | O_EXCL, 0644);
    if (fd < 0) return (tgs_read_marker(root, idOut) == 1) ? 0 : -1;   /* 그 사이 다른 쪽에서 만들었으면 그것을 쓴다 */
    if (write(fd, idOut, TGS_ID_LEN) != TGS_ID_LEN || write(fd, "\n", 1) != 1) { close(fd); unlink(path); return -1; }
    close(fd);
    return 0;
}

/* 표식이 같은 두 폴더가 '사실은 같은 폴더'(다른 경로 · 다른 마운트로 보이는 것)인지 확인한다.
   A 에 숨김 임시 파일을 만들고 B 에서 보이는지 본다. 1: 같은 폴더, 0: 다른 폴더, -1: 알 수 없음 */
static int tgs_same_folder_probe(const char *rootA, const char *rootB) {
    char token[TGS_ID_LEN + 1], name[TGS_ID_LEN + 32], pa[TGS_PATH_MAX], pb[TGS_PATH_MAX];
    struct stat st;
    int fd, r;
    tgs_make_id(token);
    snprintf(name, sizeof(name), ".typegrapher-probe-%s", token);
    if (tgs_join(pa, sizeof(pa), rootA, name) != 0 || tgs_join(pb, sizeof(pb), rootB, name) != 0) return -1;
    fd = open(pa, O_WRONLY | O_CREAT | O_EXCL, 0644);
    if (fd < 0) return -1;
    close(fd);
    if (lstat(pb, &st) == 0) r = 1;
    else r = (errno == ENOENT) ? 0 : -1;
    unlink(pa);
    return r;
}

/* 표식을 새 값으로 바꾼다 (다른 폴더를 숨김 파일까지 통째로 복사해서 만든 폴더에 쓴다). 0: 성공 */
static int tgs_renew_marker(const char *root, char *idOut) {
    char path[TGS_PATH_MAX], tmp[TGS_PATH_MAX];
    int fd, n;
    if (tgs_join(path, sizeof(path), root, TGS_MARKER_NAME) != 0) return -1;
    n = snprintf(tmp, sizeof(tmp), "%s.tmp", path);
    if (n < 0 || (size_t)n >= sizeof(tmp)) return -1;
    tgs_make_id(idOut);
    fd = open(tmp, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) return -1;
    if (write(fd, idOut, TGS_ID_LEN) != TGS_ID_LEN || write(fd, "\n", 1) != 1) { close(fd); unlink(tmp); return -1; }
    close(fd);
    if (rename(tmp, path) != 0) { unlink(tmp); return -1; }
    return 0;
}

/* ---------- 스냅샷 (지난 동기화 때의 목록) ----------
   짝(A ↔ B)의 스냅샷은 두 폴더 모두에 같은 내용으로 적는다:
       <A>/.typegrapher-sync/<B 의 표식>.snapshot
       <B>/.typegrapher-sync/<A 의 표식>.snapshot
   파일 안에는 어느 열이 어느 폴더의 값인지(A/B 표식)와 세대 번호(G)가 들어 있다. */
static int tgs_snapshot_path(char *out, size_t outSize, const char *root, const char *partnerId) {
    int n = snprintf(out, outSize, "%s/%s/%s.snapshot", root, TGS_STATE_NAME, partnerId);
    return (n < 0 || (size_t)n >= outSize) ? -1 : 0;
}

/* 돌려주는 값: 세대 번호(1 이상) = 읽음, 0 = 없음 또는 쓸 수 없는 내용(= 지난 기록 없음으로 취급).
   파일에 적힌 A/B 가 지금의 A/B 와 뒤바뀌어 있으면(반대쪽 Mac 이 적은 기록) 열을 맞바꿔서 돌려준다. */
static long long tgs_load_snapshot(const char *path, const char *idA, const char *idB, tgs_snapshot *s) {
    FILE *f = fopen(path, "r");
    char *line = NULL, *endp = NULL;
    char headA[TGS_ID_LEN + 1];
    size_t cap = TGS_PATH_MAX + 128, len;
    long declared = -1;
    long long generation = 0;
    int ok = 0, stage = 0, swapped = 0;
    memset(s, 0, sizeof(*s));
    headA[0] = '\0';
    if (!f) return 0;
    line = (char *)malloc(cap);
    if (!line) { fclose(f); return 0; }
    while (fgets(line, (int)cap, f)) {
        len = strlen(line);
        if (len == 0 || line[len - 1] != '\n') { stage = -1; break; }          /* 줄이 잘렸으면 전체를 믿지 않는다 */
        line[--len] = '\0';
        if (stage == 0) { if (strcmp(line, "TGSYNC 2") != 0) { stage = -1; break; } stage = 1; continue; }
        if (stage == 1) {
            if (strncmp(line, "G ", 2) != 0 || line[2] < '0' || line[2] > '9') { stage = -1; break; }
            generation = strtoll(line + 2, &endp, 10);
            if (!endp || *endp != '\0' || generation < 1) { stage = -1; break; }
            stage = 2; continue;
        }
        if (stage == 2) {
            if (strncmp(line, "A ", 2) != 0 || !tgs_valid_id(line + 2)) { stage = -1; break; }
            memcpy(headA, line + 2, TGS_ID_LEN + 1);
            stage = 3; continue;
        }
        if (stage == 3) {
            if (strncmp(line, "B ", 2) != 0 || !tgs_valid_id(line + 2)) { stage = -1; break; }
            if (strcmp(headA, idA) == 0 && strcmp(line + 2, idB) == 0) swapped = 0;
            else if (strcmp(headA, idB) == 0 && strcmp(line + 2, idA) == 0) swapped = 1;
            else { stage = -1; break; }                                          /* 다른 짝의 기록 */
            stage = 4; continue;
        }
        if (stage == 4) {
            tgs_snap_entry e;
            int used = 0;
            memset(&e, 0, sizeof(e));
            if (strncmp(line, "END ", 4) == 0) { declared = strtol(line + 4, NULL, 10); stage = 5; continue; }
            if (line[0] == 'F' && line[1] == ' ') {
                if (sscanf(line + 2, "%lld %lld %lld %lld%n", &e.mtimeA, &e.sizeA, &e.mtimeB, &e.sizeB, &used) != 4 || used <= 0 || line[2 + used] != ' ') { stage = -1; break; }
                if (swapped) {
                    long long t;
                    t = e.mtimeA; e.mtimeA = e.mtimeB; e.mtimeB = t;
                    t = e.sizeA; e.sizeA = e.sizeB; e.sizeB = t;
                }
                e.key = strdup(line + 2 + used + 1);                /* 숫자 네 개 뒤의 공백 한 칸 다음부터가 이름(앞 공백 보존) */
            } else if (line[0] == 'D' && line[1] == ' ') {
                e.isDir = 1;
                e.key = strdup(line + 2);
            } else { stage = -1; break; }
            if (!e.key || !e.key[0]) { free(e.key); stage = -1; break; }
            if (s->count == s->cap) {
                size_t ncap = s->cap ? s->cap * 2 : 256;
                tgs_snap_entry *n = (tgs_snap_entry *)realloc(s->items, ncap * sizeof(tgs_snap_entry));
                if (!n) { free(e.key); stage = -1; break; }
                s->items = n; s->cap = ncap;
            }
            s->items[s->count++] = e;
            continue;
        }
        stage = -1; break;                                                       /* END 뒤에 내용이 더 있으면 믿지 않는다 */
    }
    fclose(f);
    free(line);
    if (stage == 5 && declared == (long)s->count) ok = 1;
    if (!ok) { tgs_snapshot_free(s); return 0; }
    return generation;
}

/* 두 폴더에 있는 사본 가운데 쓸 수 있고 세대 번호가 큰 것을 고른다. 돌려주는 값: 그 세대 번호, 둘 다 없으면 0 */
static long long tgs_load_best(const char *rootA, const char *rootB, const char *idA, const char *idB, tgs_snapshot *out) {
    char pa[TGS_PATH_MAX], pb[TGS_PATH_MAX];
    tgs_snapshot sa, sb;
    long long ga = 0, gb = 0;
    memset(&sa, 0, sizeof(sa));
    memset(&sb, 0, sizeof(sb));
    memset(out, 0, sizeof(*out));
    if (tgs_snapshot_path(pa, sizeof(pa), rootA, idB) == 0) ga = tgs_load_snapshot(pa, idA, idB, &sa);
    if (tgs_snapshot_path(pb, sizeof(pb), rootB, idA) == 0) gb = tgs_load_snapshot(pb, idA, idB, &sb);
    if (ga == 0 && gb == 0) return 0;
    if (ga >= gb) { *out = sa; tgs_snapshot_free(&sb); return ga; }
    *out = sb; tgs_snapshot_free(&sa);
    return gb;
}

/* root 안의 숨김 폴더에 스냅샷 사본 하나를 적는다 (임시 파일에 다 적은 뒤 이름을 바꿔 넣음). 0: 성공 */
static int tgs_write_snapshot(const char *root, const char *partnerId, long long generation,
                              const char *idA, const char *idB, tgs_list *la, tgs_list *lb) {
    char dir[TGS_PATH_MAX], path[TGS_PATH_MAX], tmp[TGS_PATH_MAX];
    struct stat st;
    FILE *f;
    size_t i;
    long written = 0;
    int n;
    if (tgs_join(dir, sizeof(dir), root, TGS_STATE_NAME) != 0) return -1;
    if (mkdir(dir, 0755) != 0 && !(stat(dir, &st) == 0 && S_ISDIR(st.st_mode))) return -1;
    if (tgs_snapshot_path(path, sizeof(path), root, partnerId) != 0) return -1;
    n = snprintf(tmp, sizeof(tmp), "%s.tmp", path);
    if (n < 0 || (size_t)n >= sizeof(tmp)) return -1;
    f = fopen(tmp, "w");
    if (!f) return -1;
    fprintf(f, "TGSYNC 2\nG %lld\nA %s\nB %s\n", generation, idA, idB);
    for (i = 0; i < la->count; i++) {
        tgs_entry *a = &la->items[i], *b;
        if (a->dup) continue;
        b = tgs_find(lb, a->key);
        if (!b || b->dup || b->isDir != a->isDir) continue;         /* 양쪽에 똑같이 있는 것만 '동기화된 상태'로 적는다 */
        if (a->isDir) fprintf(f, "D %s\n", a->key);
        else fprintf(f, "F %lld %lld %lld %lld %s\n", a->mtime, a->size, b->mtime, b->size, a->key);
        written++;
    }
    fprintf(f, "END %ld\n", written);
    if (fflush(f) != 0 || ferror(f)) { fclose(f); unlink(tmp); return -1; }
    if (fclose(f) != 0) { unlink(tmp); return -1; }
    if (rename(tmp, path) != 0) { unlink(tmp); return -1; }
    return 0;
}

/* ---------- 치우기 (숨김 보관 폴더로 옮김) ---------- */
static int tgs_is_dir(const char *path) {
    struct stat st;
    return stat(path, &st) == 0 && S_ISDIR(st.st_mode);
}

/* root(이미 있는 폴더) 아래에 rel 의 각 단계를 차례로 만든다 */
static int tgs_mkdirs_under(const char *root, const char *rel) {
    char buf[TGS_PATH_MAX];
    size_t base;
    char *p;
    if (tgs_join(buf, sizeof(buf), root, rel) != 0) return -1;
    base = strlen(root);
    for (p = buf + base + 1; ; p++) {
        if (*p == '/' || *p == '\0') {
            char saved = *p;
            *p = '\0';
            if (mkdir(buf, 0755) != 0 && !tgs_is_dir(buf)) return -1;
            *p = saved;
            if (saved == '\0') break;
        }
    }
    return 0;
}

static int tgs_trash_move(const char *root, const char *batch, const char *raw) {
    char src[TGS_PATH_MAX], rel[TGS_PATH_MAX], dst[TGS_PATH_MAX], parentRel[TGS_PATH_MAX], cand[TGS_PATH_MAX];
    struct stat st;
    char *slash;
    int i, n;
    if (tgs_join(src, sizeof(src), root, raw) != 0) return -1;
    n = snprintf(rel, sizeof(rel), "%s/%s/%s", TGS_TRASH_NAME, batch, raw);
    if (n < 0 || (size_t)n >= sizeof(rel)) return -1;
    if (tgs_join(dst, sizeof(dst), root, rel) != 0) return -1;
    snprintf(parentRel, sizeof(parentRel), "%s", rel);
    slash = strrchr(parentRel, '/');
    if (!slash) return -1;
    *slash = '\0';
    if (tgs_mkdirs_under(root, parentRel) != 0) return -1;
    snprintf(cand, sizeof(cand), "%s", dst);
    for (i = 1; lstat(cand, &st) == 0; i++) {                    /* 같은 이름이 이미 보관돼 있으면 뒤에 번호를 붙인다 */
        if (i > 99) return -1;
        n = snprintf(cand, sizeof(cand), "%s.%d", dst, i);
        if (n < 0 || (size_t)n >= sizeof(cand)) return -1;
    }
    return rename(src, cand) == 0 ? 0 : -1;
}

/* '반대쪽(otherRoot)에는 이 항목이 없다'를 치우기 직전에 다시 확인한다.
   1: 확실히 없음 (두 이름 모두 ENOENT/ENOTDIR 이고, 반대쪽 표식이 여전히 같은 값으로 읽힘)
   0: 있음 (치우면 안 됨)
  -1: 판단할 수 없음 (입출력 오류, 반대쪽 폴더가 사라졌거나 바뀜) → 삭제 전파 전체를 멈춘다 */
static int tgs_confirm_missing(const char *otherRoot, const char *otherId, const char *relKey, const char *relRaw) {
    char path[TGS_PATH_MAX], markerNow[TGS_ID_LEN + 1];
    struct stat st;
    const char *names[2];
    int i;
    names[0] = relKey; names[1] = relRaw;
    for (i = 0; i < 2; i++) {
        if (tgs_join(path, sizeof(path), otherRoot, names[i]) != 0) return -1;
        if (lstat(path, &st) == 0) return 0;
        if (errno != ENOENT && errno != ENOTDIR) return -1;
    }
    if (tgs_read_marker(otherRoot, markerNow) != 1 || strcmp(markerNow, otherId) != 0) return -1;
    return 1;
}

/* 1: 보이는(숨김이 아닌) 항목이 있음, 0: 없음, -1: 읽을 수 없음 */
static int tgs_dir_has_visible(const char *path) {
    DIR *d = opendir(path);
    struct dirent *e;
    int found = 0;
    if (!d) return -1;
    for (;;) {
        errno = 0;
        e = readdir(d);
        if (!e) { if (errno != 0) found = -1; break; }
        if (e->d_name[0] != '.') { found = 1; break; }
    }
    closedir(d);
    return found;
}

/* 두 폴더가 같거나 한쪽이 다른 쪽 안에 들어 있으면 1 (이런 짝에서는 삭제 전파를 하지 않는다) */
static int tgs_same_or_nested(const char *a, const char *b) {
    char *ra = realpath(a, NULL), *rb = realpath(b, NULL);
    int r = 1;
    if (ra && rb) {
        size_t la = strlen(ra), lb = strlen(rb);
        if (la == lb) r = (strcmp(ra, rb) == 0);
        else if (la < lb) r = (strncmp(ra, rb, la) == 0 && rb[la] == '/');
        else r = (strncmp(ra, rb, lb) == 0 && ra[lb] == '/');
    }
    free(ra); free(rb);
    return r;
}

/* ---------- 1단계: rsync 전에 — 한쪽에서 지워진 항목을 반대쪽에서 치운다 ----------
   rootA = 내 보관함, rootB = 동기화 대상.
   돌려주는 값: 0 = 정상(치운 것이 없을 수도 있음), -1 = 준비 실패(표식을 만들 수 없음 등 → 삭제 전파 없이 진행) */
static int tgs_prepare(const char *rootA, const char *rootB, tgs_norm_fn norm, tgs_report *rep) {
    char idA[TGS_ID_LEN + 1], idB[TGS_ID_LEN + 1], full[TGS_PATH_MAX];
    tgs_snapshot snap;
    tgs_list la, lb;
    size_t i;
    time_t now = time(NULL);
    struct tm tmv;
    int stop = 0;

    memset(rep, 0, sizeof(*rep));
    memset(&snap, 0, sizeof(snap));
    memset(&la, 0, sizeof(la));
    memset(&lb, 0, sizeof(lb));
    localtime_r(&now, &tmv);
    strftime(rep->trashBatch, sizeof(rep->trashBatch), "%Y%m%d-%H%M%S", &tmv);

    if (!tgs_is_dir(rootA) || !tgs_is_dir(rootB)) return -1;
    if (tgs_same_or_nested(rootA, rootB)) return -1;
    if (tgs_ensure_marker(rootA, idA) != 0 || tgs_ensure_marker(rootB, idB) != 0) return -1;
    if (strcmp(idA, idB) == 0) {
        /* 표식이 같다: (가) 같은 폴더를 다른 경로로 보고 있거나, (나) 한쪽이 다른 쪽을 숨김 파일까지 통째로 복사한 폴더다.
           (가)이면 삭제 전파를 하지 않는다. (나)이면 대상 쪽에 새 표식을 주고 '첫 동기화'부터 다시 시작한다. */
        if (tgs_same_folder_probe(rootA, rootB) != 0) return -1;
        if (tgs_renew_marker(rootB, idB) != 0 || strcmp(idA, idB) == 0) return -1;
    }
    if (tgs_load_best(rootA, rootB, idA, idB, &snap) == 0) { rep->firstSync = 1; return 0; }

    tgs_list_tree(rootA, norm, &la);
    tgs_list_tree(rootB, norm, &lb);
    if (la.failed || lb.failed) {
        rep->skipped = 1;
        tgs_list_free(&la); tgs_list_free(&lb); tgs_snapshot_free(&snap);
        return 0;
    }

#ifdef TGS_TESTING
    if (tgs_test_hook_before_apply) tgs_test_hook_before_apply();
#endif

    /* (1) 파일 */
    if (snap.count > 1) qsort(snap.items, snap.count, sizeof(tgs_snap_entry), tgs_snap_cmp);
    for (i = 0; i < snap.count && !stop; i++) {
        tgs_snap_entry *s = &snap.items[i];
        tgs_entry *a, *b;
        int side;                                   /* 0: A 에서 지워짐 → B 에서 치움, 1: B 에서 지워짐 → A 에서 치움 */
        if (s->isDir) continue;
        a = tgs_find(&la, s->key);
        b = tgs_find(&lb, s->key);
        if ((a && b) || (!a && !b)) continue;
        side = a ? 1 : 0;
        {
            tgs_entry *keep = side ? a : b;         /* 남아 있는 쪽의 항목 */
            const char *keepRoot = side ? rootA : rootB;
            const char *goneRoot = side ? rootB : rootA;
            const char *goneId = side ? idB : idA;
            int c;
            if (keep->isDir || keep->dup) continue;
            if (!tgs_unchanged(keep->mtime, keep->size, side ? s->mtimeA : s->mtimeB, side ? s->sizeA : s->sizeB)) { rep->keptModified++; continue; }
            c = tgs_confirm_missing(goneRoot, goneId, s->key, keep->raw);
            if (c < 0) { rep->aborted = 1; stop = 1; break; }
            if (c == 0) continue;
            if (tgs_trash_move(keepRoot, rep->trashBatch, keep->raw) == 0) { if (side) rep->deletedA++; else rep->deletedB++; }
            else rep->moveFailed++;
        }
    }

    /* (2) 폴더: 깊은 것부터. 한쪽에서 없어졌고, 반대쪽에서는 (방금 파일을 치운 뒤) 보이는 내용이 하나도 없을 때만 치운다 */
    if (!stop && snap.count > 1) qsort(snap.items, snap.count, sizeof(tgs_snap_entry), tgs_snap_depth_desc);
    for (i = 0; i < snap.count && !stop; i++) {
        tgs_snap_entry *s = &snap.items[i];
        tgs_entry *a, *b;
        int side;
        if (!s->isDir) continue;
        a = tgs_find(&la, s->key);
        b = tgs_find(&lb, s->key);
        if ((a && b) || (!a && !b)) continue;
        side = a ? 1 : 0;
        {
            tgs_entry *keep = side ? a : b;
            const char *keepRoot = side ? rootA : rootB;
            const char *goneRoot = side ? rootB : rootA;
            const char *goneId = side ? idB : idA;
            int c, vis;
            if (!keep->isDir || keep->dup) continue;
            if (tgs_join(full, sizeof(full), keepRoot, keep->raw) != 0) continue;
            vis = tgs_dir_has_visible(full);
            if (vis != 0) continue;                 /* 새 파일이 들어 있거나 읽을 수 없으면 그대로 둔다 */
            c = tgs_confirm_missing(goneRoot, goneId, s->key, keep->raw);
            if (c < 0) { rep->aborted = 1; stop = 1; break; }
            if (c == 0) continue;
            if (tgs_trash_move(keepRoot, rep->trashBatch, keep->raw) == 0) { if (side) rep->deletedA++; else rep->deletedB++; }
            else rep->moveFailed++;
        }
    }

    tgs_list_free(&la); tgs_list_free(&lb); tgs_snapshot_free(&snap);
    return 0;
}

/* ---------- 2단계: rsync 두 번이 모두 성공한 뒤 — 지금 상태를 스냅샷으로 적는다 ----------
   0 = 두 폴더 모두에 적음, 1 = 한쪽에만 적음(다음 동기화는 그 사본을 씀), -1 = 적지 못함(이전 스냅샷은 그대로 남음) */
static int tgs_commit(const char *rootA, const char *rootB, tgs_norm_fn norm) {
    char idA[TGS_ID_LEN + 1], idB[TGS_ID_LEN + 1];
    tgs_snapshot previous;
    tgs_list la, lb;
    long long generation;
    int r = -1;
    if (tgs_same_or_nested(rootA, rootB)) return -1;
    if (tgs_read_marker(rootA, idA) != 1 || tgs_read_marker(rootB, idB) != 1) return -1;
    if (strcmp(idA, idB) == 0) return -1;
    tgs_list_tree(rootA, norm, &la);
    tgs_list_tree(rootB, norm, &lb);
    if (!la.failed && !lb.failed) {
        int wa, wb;
        generation = tgs_load_best(rootA, rootB, idA, idB, &previous) + 1;     /* 지금 있는 어느 사본보다도 큰 번호 */
        tgs_snapshot_free(&previous);
        wa = tgs_write_snapshot(rootA, idB, generation, idA, idB, &la, &lb);
        wb = tgs_write_snapshot(rootB, idA, generation, idA, idB, &la, &lb);
        r = (wa == 0 && wb == 0) ? 0 : ((wa == 0 || wb == 0) ? 1 : -1);
    }
    tgs_list_free(&la); tgs_list_free(&lb);
    return r;
}
/* ===== TGSYNC CORE END ===== */

/* 삭제 전파 코어가 쓰는 '이름 표준형' 함수: 한글 자모 분리형(NFD)과 조합형(NFC)을 같은 이름으로 보도록 NFC 로 바꿉니다.
   (HFS+ 디스크와 SMB 공유 폴더는 이름을 분리형으로 돌려주고 앱은 조합형으로 다루므로, 그대로 비교하면 같은 파일을
    서로 다른 파일로 보게 됩니다.) 성공하면 0. */
static int TGSyncNormalize(const char *raw, char *out, size_t outSize) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *name = [NSString stringWithUTF8String:raw];
    const char *normalized = name ? [[name precomposedStringWithCanonicalMapping] UTF8String] : NULL;
    int result = -1;
    if (!normalized) normalized = raw;          /* UTF-8 로 읽을 수 없는 이름은 있는 그대로 비교합니다 */
    size_t length = strlen(normalized);
    if (length + 1 <= outSize) {
        memcpy(out, normalized, length + 1);
        result = 0;
    }
    [pool drain];
    return result;
}

#ifndef NSWindowStyleMaskTitled
#define NSWindowStyleMaskTitled (1 << 0)
#define NSWindowStyleMaskClosable (1 << 1)
#define NSWindowStyleMaskMiniaturizable (1 << 2)
#define NSWindowStyleMaskResizable (1 << 3)
#endif

// C언어 인메모리 44.1kHz 16-bit PCM WAV 헤더 생성 헬퍼
static NSMutableData* createWAVDataWithSamples(const int16_t *samples, uint32_t numSamples, uint32_t sampleRate) {
    uint32_t dataSize = numSamples * sizeof(int16_t);
    uint32_t riffSize = 36 + dataSize;
    uint32_t byteRate = sampleRate * sizeof(int16_t);
    uint16_t blockAlign = sizeof(int16_t);
    uint16_t bitsPerSample = 16;
    uint16_t audioFormat = 1; // PCM
    uint16_t numChannels = 1;
    uint32_t fmtChunkSize = 16;

    NSMutableData *wav = [NSMutableData dataWithCapacity:(44 + dataSize)];
    [wav appendBytes:"RIFF" length:4];
    [wav appendBytes:&riffSize length:4];
    [wav appendBytes:"WAVE" length:4];
    [wav appendBytes:"fmt " length:4];
    [wav appendBytes:&fmtChunkSize length:4];
    [wav appendBytes:&audioFormat length:2];
    [wav appendBytes:&numChannels length:2];
    [wav appendBytes:&sampleRate length:4];
    [wav appendBytes:&byteRate length:4];
    [wav appendBytes:&blockAlign length:2];
    [wav appendBytes:&bitsPerSample length:2];
    [wav appendBytes:"data" length:4];
    [wav appendBytes:&dataSize length:4];
    [wav appendBytes:samples length:dataSize];
    return wav;
}

@interface TypeGrapherController : NSObject <NSApplicationDelegate, NSWindowDelegate> {
    NSWindow *window;
    WebView *webView;
    NSString *vaultPath;
    NSString *syncTargetPath;
    BOOL vaultInitialized;
    BOOL syncInProgress;        /* 동기화(rsync)가 백그라운드에서 진행 중인지 (메인 스레드에서만 읽고 씀) */
    NSData *pendingPDFData;     /* 방금 조판한 PDF (저장 창 / 인쇄 창으로 넘기기 전까지 보관) */
    NSSize pendingPaperSize;

    NSSound *keyClickSound;
    NSSound *spaceThudSound;
    NSSound *carriageBellSound;
}
@end

@implementation TypeGrapherController

- (void)initSynthesizedTypewriterSounds {
    uint32_t sr = 44100;

    // 1. 활자 타격음 (Crisp Mechanical Typebar Strike: 45ms)
    uint32_t clickLen = (uint32_t)(sr * 0.045);
    int16_t *clickBuf = (int16_t *)calloc(clickLen, sizeof(int16_t));
    for (uint32_t i = 0; i < clickLen; i++) {
        double t = (double)i / (double)sr;
        double env = exp(-t * 145.0);
        double noise = ((double)(arc4random_uniform(20000)) / 10000.0) - 1.0;
        double woody = sin(2.0 * M_PI * 240.0 * t) * 0.45 + sin(2.0 * M_PI * 1150.0 * t) * 0.35;
        double val = (noise * 0.65 + woody) * env;
        if (val > 1.0) val = 1.0;
        if (val < -1.0) val = -1.0;
        clickBuf[i] = (int16_t)(val * 16000.0);
    }
    keyClickSound = [[NSSound alloc] initWithData:createWAVDataWithSamples(clickBuf, clickLen, sr)];
    free(clickBuf);

    // 2. 스페이스바 묵직한 타격음 (Deep Spacebar Thud: 55ms)
    uint32_t spaceLen = (uint32_t)(sr * 0.055);
    int16_t *spaceBuf = (int16_t *)calloc(spaceLen, sizeof(int16_t));
    for (uint32_t i = 0; i < spaceLen; i++) {
        double t = (double)i / (double)sr;
        double env = exp(-t * 110.0);
        double noise = ((double)(arc4random_uniform(20000)) / 10000.0) - 1.0;
        double thud = sin(2.0 * M_PI * 140.0 * t) * 0.65 + sin(2.0 * M_PI * 520.0 * t) * 0.25;
        double val = (noise * 0.45 + thud) * env;
        if (val > 1.0) val = 1.0;
        if (val < -1.0) val = -1.0;
        spaceBuf[i] = (int16_t)(val * 17500.0);
    }
    spaceThudSound = [[NSSound alloc] initWithData:createWAVDataWithSamples(spaceBuf, spaceLen, sr)];
    free(spaceBuf);

    // 3. 엔터키 황동 캐리지 리턴 벨소리 (Classic Brass Carriage Return Bell 'Ding!': 420ms)
    uint32_t bellLen = (uint32_t)(sr * 0.42);
    int16_t *bellBuf = (int16_t *)calloc(bellLen, sizeof(int16_t));
    for (uint32_t i = 0; i < bellLen; i++) {
        double t = (double)i / (double)sr;
        double env = exp(-t * 10.5);
        double strikeEnv = exp(-t * 180.0);
        double bell = sin(2.0 * M_PI * 2380.0 * t) * 0.55
                    + sin(2.0 * M_PI * 4760.0 * t) * 0.28
                    + sin(2.0 * M_PI * 6620.0 * t) * 0.17 * strikeEnv;
        double val = bell * env;
        if (val > 1.0) val = 1.0;
        if (val < -1.0) val = -1.0;
        bellBuf[i] = (int16_t)(val * 18000.0);
    }
    carriageBellSound = [[NSSound alloc] initWithData:createWAVDataWithSamples(bellBuf, bellLen, sr)];
    free(bellBuf);
}

- (id)init {
    self = [super init];
    if (self) {
        vaultInitialized = NO;
        [self initSynthesizedTypewriterSounds];

        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        NSString *savedVault = [defs stringForKey:@"TypeGrapherDocsVaultPath"];

        if (savedVault && [savedVault length] > 0) {
            vaultPath = [savedVault retain];
        } else {
            NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *defaultVault = [docsDir stringByAppendingPathComponent:@"TypeGrapher"];
            vaultPath = [defaultVault retain];
            [defs setObject:vaultPath forKey:@"TypeGrapherDocsVaultPath"];
        }

        NSString *savedSync = [defs stringForKey:@"TypeGrapherSyncPath"];
        syncTargetPath = savedSync ? [savedSync retain] : nil;
    }
    return self;
}

- (NSString *)sanitizeRelativePath:(NSString *)relPath {
    if (!relPath) return @"";
    NSString *norm = [relPath precomposedStringWithCanonicalMapping];
    norm = [norm stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    norm = [norm stringByReplacingOccurrencesOfString:@".." withString:@"_"];
    norm = [norm stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    while ([norm hasPrefix:@"/"]) {
        norm = [norm substringFromIndex:1];
    }
    return norm;
}

- (void)initializeVaultOnceIfNeeded {
    if (vaultInitialized) return;
    vaultInitialized = YES;

    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:vaultPath withIntermediateDirectories:YES attributes:nil error:nil];

    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    if (![defs boolForKey:@"TypeGrapherWelcomeCreatedV1"]) {
        [defs setBool:YES forKey:@"TypeGrapherWelcomeCreatedV1"];
        NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:vaultPath];
        NSString *item = nil;
        BOOL hasMd = NO;
        while ((item = [enumerator nextObject])) {
            if ([[[item pathExtension] lowercaseString] isEqualToString:@"md"]) {
                hasMd = YES;
                break;
            }
        }
        if (!hasMd) {
            NSString *welcomePath = [vaultPath stringByAppendingPathComponent:@"TypeGrapher 시작 가이드.md"];
            NSString *welcomeMd =
                @"# 📕 TypeGrapher\n\n"
                @"5대 시그니처 기능이 모두 탑재된 **TypeGrapher**에 오신 것을 환영합니다.\n\n"
                @"---\n\n"
                @"## ✨ TypeGrapher 5대 시그니처 기능 안내\n"
                @"- **🔊 리얼 타자기 타건음 & 엔터 벨**: 타이핑할 때마다 경쾌한 수동 타자기 소리와 엔터(`Enter`) 입력 시 황동 벨소리가 울립니다 (좌측 리본 `🔊` 타건음, `🔔` 벨소리를 각각 On/Off).\n"
                @"- **🎯 타자기 롤러 중앙 고정 스크롤 & 집중 조명**: 현재 작성 중인 문장에만 조명을 비추고 줄 높이를 화면 중앙에 고정하며, 타이핑하는 순간 글자가 네온처럼 빛납니다 (`🎯 집중` 버튼).\n"
                @"- **🎵 지금 흐르는 음악(BGM) 스탬프**: 상단 툴바의 `[🎵 BGM]` 버튼(`Cmd + M`)을 누르면 현재 재생 중인 `Music` 또는 `iTunes` 곡명이 각인됩니다.\n"
                @"- **📊 월간 집필 천공 카드 히트맵**: 좌측 리본의 `📊` 버튼(`Cmd + G`)을 누르면 이번 달 집필 잔디와 연속 스트릭 통계를 확인할 수 있습니다.\n"
                @"- **📜 무후회 초고 모드 & 원고지(줄·칸) / 인쇄**: `[🔒 무후회]`, `[📜 스타일]`(기본 → 타자기체 → 원고지(줄) → 한 칸에 한 글자씩 쓰는 20×20 원고지(칸)), `[🖨️ 인쇄]`(`Cmd + P`) · `[📄 PDF]`로 집필과 출력을 자유롭게 즐겨보세요.\n";
            [welcomeMd writeToFile:welcomePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector {
#if TG_PDF_ENGINE
    if (selector == @selector(capturePagesPDF:) || selector == @selector(deliverPDF:fileName:)) return NO;
#endif
    if (selector == @selector(getVaultStateJSON) ||
        selector == @selector(saveNoteWithRelPath:content:) ||
        selector == @selector(renameNoteFrom:to:content:) ||
        selector == @selector(moveItemFrom:to:) ||
        selector == @selector(deleteNoteWithRelPath:) ||
        selector == @selector(deleteFolderWithRelPath:) ||
        selector == @selector(createSubfolder:) ||
        selector == @selector(chooseVaultFolder) ||
        selector == @selector(revealInFinder:) ||
        selector == @selector(saveTheme:) ||
        selector == @selector(saveOrderConfig:) ||
        selector == @selector(playTypeSound:) ||
        selector == @selector(getCurrentBGM) ||
        selector == @selector(printCurrentNote) ||
        selector == @selector(syncVault)) {
        return NO;
    }
    return YES;
}

+ (NSString *)webScriptNameForSelector:(SEL)selector {
#if TG_PDF_ENGINE
    if (selector == @selector(capturePagesPDF:)) return @"capturePagesPDF";
    if (selector == @selector(deliverPDF:fileName:)) return @"deliverPDF";
#endif
    if (selector == @selector(getVaultStateJSON)) return @"getVaultStateJSON";
    if (selector == @selector(saveNoteWithRelPath:content:)) return @"saveNote";
    if (selector == @selector(renameNoteFrom:to:content:)) return @"renameNote";
    if (selector == @selector(moveItemFrom:to:)) return @"moveItem";
    if (selector == @selector(deleteNoteWithRelPath:)) return @"deleteNote";
    if (selector == @selector(deleteFolderWithRelPath:)) return @"deleteFolder";
    if (selector == @selector(createSubfolder:)) return @"createSubfolder";
    if (selector == @selector(chooseVaultFolder)) return @"chooseVaultFolder";
    if (selector == @selector(revealInFinder:)) return @"revealInFinder";
    if (selector == @selector(saveTheme:)) return @"saveTheme";
    if (selector == @selector(saveOrderConfig:)) return @"saveOrderConfig";
    if (selector == @selector(playTypeSound:)) return @"playTypeSound";
    if (selector == @selector(getCurrentBGM)) return @"getCurrentBGM";
    if (selector == @selector(printCurrentNote)) return @"printCurrentNote";
    if (selector == @selector(syncVault)) return @"syncVault";
    return nil;
}

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame {
    [windowObject setValue:self forKey:@"NativeBridge"];
}

/* 시그니처 1: 다중 채널 비동기 타건음 재생 */
- (void)playTypeSound:(NSString *)soundType {
    NSSound *base = keyClickSound;
    if ([soundType isEqualToString:@"bell"]) {
        base = carriageBellSound;
    } else if ([soundType isEqualToString:@"space"]) {
        base = spaceThudSound;
    }
    if (base) {
        NSSound *inst = [[base copy] autorelease];
        [inst play];
    }
}

/* 시그니처 3: 현재 재생 중인 음악(Music.app 또는 iTunes.app) 트랙 정보 가져오기 */
- (NSString *)getCurrentBGM {
    NSArray *musicApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.Music"];
    if (musicApps && [musicApps count] > 0) {
        NSAppleScript *sc = [[[NSAppleScript alloc] initWithSource:
            @"tell application \"Music\"\n"
            @"  if player state is playing then\n"
            @"    return (artist of current track as string) & \" — \" & (name of current track as string) & \" (\" & (album of current track as string) & \")\"\n"
            @"  end if\n"
            @"end tell\n"
            @"return \"\""] autorelease];
        NSAppleEventDescriptor *res = [sc executeAndReturnError:nil];
        if (res && [res stringValue] && [[res stringValue] length] > 0) {
            return [res stringValue];
        }
    }

    NSArray *itunesApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iTunes"];
    if (itunesApps && [itunesApps count] > 0) {
        NSAppleScript *scOld = [[[NSAppleScript alloc] initWithSource:
            @"tell application \"iTunes\"\n"
            @"  if player state is playing then\n"
            @"    return (artist of current track as string) & \" — \" & (name of current track as string) & \" (\" & (album of current track as string) & \")\"\n"
            @"  end if\n"
            @"end tell\n"
            @"return \"\""] autorelease];
        NSAppleEventDescriptor *resOld = [scOld executeAndReturnError:nil];
        if (resOld && [resOld stringValue] && [[resOld stringValue] length] > 0) {
            return [resOld stringValue];
        }
    }
    return @"";
}

/* 시그니처 5: 네이티브 macOS 프린트 및 PDF 내보내기 패널 실행 */
/* ==========================================================================
   인쇄 / PDF (v2.3 도입, v2.4 수정)
   - 새 조판 엔진(TG_PDF_ENGINE): 스크립트가 넘겨준 '조각'(문서 안의 사각 영역)을 하나씩 벡터 PDF 로 떠서,
     용지 크기 PDF 의 지정된 자리에 지정된 배율로 그려 넣습니다. 쪽 나눔과 배율을 WebKit 인쇄 기능에
     맡기지 않으므로 내용이 종이 밖으로 나가지 않습니다.
   - 빌드할 때 이 부분의 컴파일이 실패하면 빌더가 TG_PDF_ENGINE=0 으로 다시 빌드하고,
     그때는 아래 #else 쪽의 기존 인쇄 방식만 남습니다.
   - v2.4: WebView 는 PDF 로 그리는 동안 문서를 인쇄 매체로 다시 배치합니다. 스크립트가 잰 자리와
     어긋나지 않도록 캡처하는 동안 매체를 screen 으로 고정하고(setMediaStyle:), 문서 끝의 검증용
     표식(job.probe)을 떠 보아 배치가 그대로였는지 확인합니다.
   - v2.5: PDFKit(Quartz) 을 링크하지 않습니다. 최신 SDK 에서 배포 대상을 10.8 이하로 잡고 Quartz 를
     링크하면 실행 파일에 /System/Library/Frameworks/PDFKit.framework 경로가 박히는데, 이 경로는
     macOS 10.15 부터만 있어서 그보다 오래된 Mac 에서는 앱이 아예 열리지 않았습니다 (v2.3 · v2.4).
     PDF 합성은 Cocoa 에 원래 들어 있는 CoreGraphics 만 쓰고, 인쇄에 필요한 PDFDocument 클래스는
     실행 중에 찾아 씁니다 (TGPDFDocumentClass).
   ========================================================================== */
#if TG_PDF_ENGINE

static CGFloat TGNumber(id value) {
    return (value && [value respondsToSelector:@selector(doubleValue)]) ? (CGFloat)[value doubleValue] : 0.0;
}

/* PDFKit 의 PDFDocument 클래스를 실행 중에 찾습니다. 아직 올라와 있지 않으면 차례로 올려 봅니다:
   Quartz(모든 버전에 있는 우산 프레임워크) → 최상위 PDFKit(10.15 이후) → Quartz 안의 PDFKit(10.14 이전).
   어느 것도 없으면 Nil 을 돌려주고, 그때는 인쇄 대신 안내 문구를 보여 줍니다 (앱은 정상 동작). */
static Class TGPDFDocumentClass(void) {
    Class cls = NSClassFromString(@"PDFDocument");
    if (cls) return cls;
    const char *candidates[] = {
        "/System/Library/Frameworks/Quartz.framework/Versions/A/Quartz",
        "/System/Library/Frameworks/PDFKit.framework/Versions/A/PDFKit",
        "/System/Library/Frameworks/Quartz.framework/Versions/A/Frameworks/PDFKit.framework/Versions/A/PDFKit"
    };
    int i;
    for (i = 0; i < 3 && !cls; i++) {
        if (dlopen(candidates[i], RTLD_LAZY | RTLD_GLOBAL)) cls = NSClassFromString(@"PDFDocument");
    }
    return cls;
}

/* 조각 PDF 를 8×8 비트맵에 그려 평균 밝기를 돌려줍니다 (0 = 검정, 1 = 흰색). 그릴 수 없으면 -1. */
static CGFloat TGAverageBrightness(NSData *pdfData) {
    CGFloat result = -1.0;
    if (!pdfData || [pdfData length] == 0) return result;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)pdfData);
    CGPDFDocumentRef doc = provider ? CGPDFDocumentCreateWithProvider(provider) : NULL;
    CGPDFPageRef page = doc ? CGPDFDocumentGetPage(doc, 1) : NULL;
    if (page) {
        CGRect box = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        unsigned char pixels[8 * 8 * 4];
        int k;
        for (k = 0; k < 8 * 8 * 4; k++) pixels[k] = 255;
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGContextRef bitmap = space ? CGBitmapContextCreate(pixels, 8, 8, 8, 8 * 4, space, kCGImageAlphaPremultipliedLast) : NULL;
        if (bitmap && box.size.width > 0.0 && box.size.height > 0.0) {
            CGContextSetRGBFillColor(bitmap, 1.0, 1.0, 1.0, 1.0);
            CGContextFillRect(bitmap, CGRectMake(0, 0, 8, 8));
            CGContextScaleCTM(bitmap, 8.0 / box.size.width, 8.0 / box.size.height);
            CGContextTranslateCTM(bitmap, -box.origin.x, -box.origin.y);
            CGContextDrawPDFPage(bitmap, page);
            CGContextFlush(bitmap);
            unsigned long sum = 0;
            int i;
            for (i = 0; i < 8 * 8; i++) {
                sum += (unsigned long)pixels[i * 4] + (unsigned long)pixels[i * 4 + 1] + (unsigned long)pixels[i * 4 + 2];
            }
            result = (CGFloat)sum / (CGFloat)(8 * 8 * 3 * 255);
        }
        if (bitmap) CGContextRelease(bitmap);
        if (space) CGColorSpaceRelease(space);
    }
    if (doc) CGPDFDocumentRelease(doc);
    if (provider) CGDataProviderRelease(provider);
    return result;
}

/* jobJSON: { "paperW": pt, "paperH": pt, "pages": [ [ {sx,sy,sw,sh, dx,dy,dw,dh}, ... ], ... ], "probe": {sx,sy,sw,sh} }
   sx..sh = 문서 좌표(px)의 원본 영역, dx..dh = 용지 왼쪽 위 기준(pt)의 놓일 자리.
   probe = 문서 끝에 놓인 검은 표식의 자리(선택). 그 자리를 떠 보아 표식이 없으면 배치가 달라진 것입니다.
   성공하면 "ok:<쪽수>", 표식을 제자리에서 찾지 못했으면 "ok:<쪽수>:shift", 실패하면 "err:<이유>" 를 돌려줍니다. */
- (NSString *)capturePagesPDF:(NSString *)jobJSON {
    if (!webView || !jobJSON) return @"err:no-view";
    NSData *jobData = [jobJSON dataUsingEncoding:NSUTF8StringEncoding];
    id job = jobData ? [NSJSONSerialization JSONObjectWithData:jobData options:0 error:nil] : nil;
    if (![job isKindOfClass:[NSDictionary class]]) return @"err:bad-job";
    NSArray *pages = [job objectForKey:@"pages"];
    if (![pages isKindOfClass:[NSArray class]] || [pages count] == 0) return @"err:no-pages";

    CGFloat paperW = TGNumber([job objectForKey:@"paperW"]);
    CGFloat paperH = TGNumber([job objectForKey:@"paperH"]);
    if (paperW < 100.0 || paperH < 100.0) {
        paperW = 595.28;
        paperH = 841.89;
    }

    NSView *docView = [[[webView mainFrame] frameView] documentView];
    if (!docView) return @"err:no-docview";
    NSRect docBounds = [docView bounds];

    NSMutableData *pdfData = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)pdfData);
    if (!consumer) return @"err:consumer";
    CGRect mediaBox = CGRectMake(0, 0, paperW, paperH);
    CGContextRef ctx = CGPDFContextCreate(consumer, &mediaBox, NULL);
    CGDataConsumerRelease(consumer);
    if (!ctx) return @"err:context";

    /* 캡처하는 동안 CSS 매체를 screen 으로 고정 (끝나면 원래 값으로 되돌림) */
    NSString *savedMediaStyle = [[webView mediaStyle] copy];
    [webView setMediaStyle:@"screen"];

    NSString *failure = nil;
    NSUInteger pageIndex, pageCount = [pages count];
    for (pageIndex = 0; pageIndex < pageCount && !failure; pageIndex++) {
        id pieces = [pages objectAtIndex:pageIndex];
        CGContextBeginPage(ctx, &mediaBox);
        if ([pieces isKindOfClass:[NSArray class]]) {
            NSUInteger pieceIndex, pieceCount = [pieces count];
            for (pieceIndex = 0; pieceIndex < pieceCount && !failure; pieceIndex++) {
                id piece = [pieces objectAtIndex:pieceIndex];
                if (![piece isKindOfClass:[NSDictionary class]]) continue;

                NSRect src = NSMakeRect(TGNumber([piece objectForKey:@"sx"]), TGNumber([piece objectForKey:@"sy"]),
                                        TGNumber([piece objectForKey:@"sw"]), TGNumber([piece objectForKey:@"sh"]));
                CGFloat dx = TGNumber([piece objectForKey:@"dx"]);
                CGFloat dy = TGNumber([piece objectForKey:@"dy"]);
                CGFloat dw = TGNumber([piece objectForKey:@"dw"]);
                CGFloat dh = TGNumber([piece objectForKey:@"dh"]);
                if (src.size.width < 1.0 || src.size.height < 1.0 || dw <= 0.0 || dh <= 0.0) continue;

                /* 떠 갈 영역이 문서 뷰 안에 있는지 확인 (밖이면 빈 그림이 되므로 이유를 알려 주고 중단) */
                if (NSMinX(src) < NSMinX(docBounds) - 2.0 || NSMinY(src) < NSMinY(docBounds) - 2.0 ||
                    NSMaxX(src) > NSMaxX(docBounds) + 2.0 || NSMaxY(src) > NSMaxY(docBounds) + 2.0) {
                    failure = [NSString stringWithFormat:@"err:bounds view=%.0fx%.0f piece=%.0f,%.0f,%.0f,%.0f",
                               NSWidth(docBounds), NSHeight(docBounds), NSMinX(src), NSMinY(src), NSWidth(src), NSHeight(src)];
                    break;
                }

                NSData *piecePDF = [docView dataWithPDFInsideRect:src];
                if (!piecePDF || [piecePDF length] == 0) {
                    failure = @"err:capture";
                    break;
                }
                CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)piecePDF);
                CGPDFDocumentRef pieceDoc = provider ? CGPDFDocumentCreateWithProvider(provider) : NULL;
                CGPDFPageRef piecePage = pieceDoc ? CGPDFDocumentGetPage(pieceDoc, 1) : NULL;
                if (piecePage) {
                    CGRect box = CGPDFPageGetBoxRect(piecePage, kCGPDFMediaBox);
                    if (box.size.width > 0.0 && box.size.height > 0.0) {
                        CGContextSaveGState(ctx);
                        /* PDF 좌표는 왼쪽 아래가 원점이므로, 위에서부터 잰 dy 를 뒤집어 놓는다 */
                        CGContextTranslateCTM(ctx, dx, paperH - dy - dh);
                        CGContextScaleCTM(ctx, dw / box.size.width, dh / box.size.height);
                        CGContextTranslateCTM(ctx, -box.origin.x, -box.origin.y);
                        CGContextDrawPDFPage(ctx, piecePage);
                        CGContextRestoreGState(ctx);
                    }
                } else {
                    failure = @"err:piece";
                }
                if (pieceDoc) CGPDFDocumentRelease(pieceDoc);
                if (provider) CGDataProviderRelease(provider);
            }
        }
        CGContextEndPage(ctx);
    }
    CGPDFContextClose(ctx);
    CGContextRelease(ctx);

    /* 배치 검증: 스크립트가 잰 표식 자리를 같은 방법으로 떠서, 검은 표식이 그 자리에 있는지 본다 */
    BOOL layoutShifted = NO;
    id probe = [job objectForKey:@"probe"];
    if (!failure && [probe isKindOfClass:[NSDictionary class]]) {
        NSRect probeRect = NSMakeRect(TGNumber([probe objectForKey:@"sx"]), TGNumber([probe objectForKey:@"sy"]),
                                      TGNumber([probe objectForKey:@"sw"]), TGNumber([probe objectForKey:@"sh"]));
        if (probeRect.size.width >= 4.0 && probeRect.size.height >= 4.0 &&
            NSMinX(probeRect) >= NSMinX(docBounds) && NSMinY(probeRect) >= NSMinY(docBounds) &&
            NSMaxX(probeRect) <= NSMaxX(docBounds) && NSMaxY(probeRect) <= NSMaxY(docBounds)) {
            CGFloat brightness = TGAverageBrightness([docView dataWithPDFInsideRect:probeRect]);
            if (brightness > 0.5) layoutShifted = YES;     /* 표식(검정)이 있어야 할 자리가 밝다 */
        }
    }

    [webView setMediaStyle:savedMediaStyle];
    [savedMediaStyle release];
    if (failure) return failure;

    [pendingPDFData release];
    pendingPDFData = [pdfData retain];
    pendingPaperSize = NSMakeSize(paperW, paperH);
    if (layoutShifted) return [NSString stringWithFormat:@"ok:%lu:shift", (unsigned long)pageCount];
    return [NSString stringWithFormat:@"ok:%lu", (unsigned long)pageCount];
}

/* 방금 만든 PDF 를 내보냅니다. action = "save": 저장 창 → 파일로 저장 / "print": 인쇄 창
   결과: "saved:<경로>", "printed", "cancel", "err:<이유>"
   (인쇄에 필요한 PDFKit 을 이 Mac 에서 쓸 수 없으면 "err:no-pdfkit") */
- (NSString *)deliverPDF:(NSString *)action fileName:(NSString *)fileName {
    if (!pendingPDFData || [pendingPDFData length] == 0) return @"err:no-pdf";

    if ([action isEqualToString:@"save"]) {
        NSSavePanel *panel = [NSSavePanel savePanel];
        [panel setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
        [panel setCanCreateDirectories:YES];
        NSString *baseName = (fileName && [fileName length] > 0) ? fileName : @"TypeGrapher";
        [panel setNameFieldStringValue:[baseName stringByAppendingPathExtension:@"pdf"]];
        if ([panel runModal] != NSOKButton) return @"cancel";
        NSURL *url = [panel URL];
        if (!url) return @"cancel";
        if (![pendingPDFData writeToURL:url atomically:YES]) return @"err:write";
        return [@"saved:" stringByAppendingString:[url path]];
    }

    /* 인쇄: 이미 용지 크기로 조판된 PDF 를 그대로 보냅니다. 인쇄 창에서 다른 용지를 골라도
       쪽 전체가 그 용지에 맞게 줄거나 늘어납니다 (PDFKit 의 용지에 맞춤 + NSFitPagination). */
    Class pdfDocumentClass = TGPDFDocumentClass();
    if (!pdfDocumentClass) return @"err:no-pdfkit";
    id pdfDoc = [[[pdfDocumentClass alloc] initWithData:pendingPDFData] autorelease];
    if (!pdfDoc) return @"err:pdf-open";
    if (![pdfDoc respondsToSelector:@selector(printOperationForPrintInfo:scalingMode:autoRotate:)]) return @"err:no-pdfkit";
    NSPrintInfo *printInfo = [[[NSPrintInfo sharedPrintInfo] copy] autorelease];
    [printInfo setTopMargin:0.0];
    [printInfo setBottomMargin:0.0];
    [printInfo setLeftMargin:0.0];
    [printInfo setRightMargin:0.0];
    [printInfo setHorizontalPagination:NSFitPagination];
    [printInfo setVerticalPagination:NSFitPagination];
    [printInfo setHorizontallyCentered:YES];
    [printInfo setVerticallyCentered:YES];
    if (pendingPaperSize.width > 100.0 && pendingPaperSize.height > 100.0) {
        [printInfo setPaperSize:pendingPaperSize];
    }
    NSPrintOperation *op = [pdfDoc printOperationForPrintInfo:printInfo scalingMode:TGPDFPrintPageScaleToFit autoRotate:YES];
    if (!op) return @"err:print-op";
    [op setShowsPrintPanel:YES];
    [op setShowsProgressPanel:YES];
    return [op runOperation] ? @"printed" : @"cancel";
}

/* 새 엔진을 쓸 수 없을 때의 대체 경로: WebKit 이 제공하는 프레임 인쇄 작업 + 여백 36pt + 가로 맞춤 */
- (void)printCurrentNote {
    if (!webView) return;
    WebFrameView *frameView = [[webView mainFrame] frameView];
    NSView *docView = [frameView documentView];
    if (!frameView || !docView) return;
    NSPrintInfo *printInfo = [[[NSPrintInfo sharedPrintInfo] copy] autorelease];
    [printInfo setTopMargin:36.0];
    [printInfo setBottomMargin:36.0];
    [printInfo setLeftMargin:36.0];
    [printInfo setRightMargin:36.0];
    [printInfo setHorizontalPagination:NSFitPagination];
    [printInfo setVerticalPagination:NSAutoPagination];
    [printInfo setHorizontallyCentered:YES];
    [printInfo setVerticallyCentered:NO];
    NSPrintOperation *op = [frameView printOperationWithPrintInfo:printInfo];
    if (!op) op = [NSPrintOperation printOperationWithView:docView printInfo:printInfo];
    if (!op) return;
    [op setShowsPrintPanel:YES];
    [op setShowsProgressPanel:YES];
    [op runOperation];
}

#else

- (void)printCurrentNote {
    if (!webView) return;
    NSView *docView = [[[webView mainFrame] frameView] documentView];
    if (docView) {
        NSPrintOperation *op = [NSPrintOperation printOperationWithView:docView];
        [op setShowsPrintPanel:YES];
        [op setShowsProgressPanel:YES];
        [op runOperation];
    }
}

#endif

- (NSString *)getVaultStateJSON {
    [self initializeVaultOnceIfNeeded];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:vaultPath];

    NSMutableArray *folderDicts = [NSMutableArray array];
    NSMutableSet *seenFolders = [NSMutableSet set];
    NSMutableArray *notesArray = [NSMutableArray array];

    NSString *rawRelPath = nil;
    while ((rawRelPath = [enumerator nextObject])) {
        NSArray *parts = [rawRelPath pathComponents];
        BOOL isHidden = NO;
        NSUInteger pIdx, pCount = [parts count];
        for (pIdx = 0; pIdx < pCount; pIdx++) {
            if ([[parts objectAtIndex:pIdx] hasPrefix:@"."]) {
                isHidden = YES;
                break;
            }
        }
        if (isHidden) continue;

        NSString *fullPath = [vaultPath stringByAppendingPathComponent:rawRelPath];
        BOOL isDir = NO;
        if (![fm fileExistsAtPath:fullPath isDirectory:&isDir]) continue;

        NSDictionary *attrs = [fm attributesOfItemAtPath:fullPath error:nil];
        NSDate *createDate = attrs ? [attrs fileCreationDate] : [NSDate date];
        NSDate *modDate = attrs ? [attrs fileModificationDate] : [NSDate date];
        if (!createDate) createDate = modDate ? modDate : [NSDate date];
        double createdMillis = [createDate timeIntervalSince1970] * 1000.0;
        double updatedMillis = [modDate timeIntervalSince1970] * 1000.0;

        NSString *normRel = [rawRelPath precomposedStringWithCanonicalMapping];
        if (isDir) {
            if (![seenFolders containsObject:normRel]) {
                [seenFolders addObject:normRel];
                [folderDicts addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                    normRel, @"path",
                    [NSNumber numberWithDouble:createdMillis], @"createdAt", nil]];
            }
            continue;
        }

        NSString *ext = [[normRel pathExtension] lowercaseString];
        if ([ext isEqualToString:@"md"] || [ext isEqualToString:@"markdown"] || [ext isEqualToString:@"txt"]) {
            NSString *content = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
            if (!content) content = @"";

            NSString *fname = [normRel lastPathComponent];
            NSString *folderPart = [[normRel stringByDeletingLastPathComponent] precomposedStringWithCanonicalMapping];
            if ([folderPart isEqualToString:@"."]) folderPart = @"";

            if ([folderPart length] > 0 && ![seenFolders containsObject:folderPart]) {
                [seenFolders addObject:folderPart];
                [folderDicts addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                    folderPart, @"path",
                    [NSNumber numberWithDouble:createdMillis], @"createdAt", nil]];
            }

            NSMutableDictionary *noteDict = [NSMutableDictionary dictionary];
            [noteDict setObject:normRel forKey:@"relPath"];
            [noteDict setObject:folderPart forKey:@"folder"];
            [noteDict setObject:fname forKey:@"filename"];
            [noteDict setObject:[[fname stringByDeletingPathExtension] precomposedStringWithCanonicalMapping] forKey:@"title"];
            [noteDict setObject:content forKey:@"content"];
            [noteDict setObject:[NSNumber numberWithDouble:createdMillis] forKey:@"createdAt"];
            [noteDict setObject:[NSNumber numberWithDouble:updatedMillis] forKey:@"updatedAt"];
            [notesArray addObject:noteDict];
        }
    }

    [folderDicts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        double c1 = [[obj1 objectForKey:@"createdAt"] doubleValue];
        double c2 = [[obj2 objectForKey:@"createdAt"] doubleValue];
        if (c1 < c2) return NSOrderedAscending;
        if (c1 > c2) return NSOrderedDescending;
        return NSOrderedSame;
    }];

    NSMutableArray *foldersArray = [NSMutableArray array];
    NSUInteger fIdx, fLen = [folderDicts count];
    for (fIdx = 0; fIdx < fLen; fIdx++) {
        [foldersArray addObject:[[folderDicts objectAtIndex:fIdx] objectForKey:@"path"]];
    }

    [notesArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        double c1 = [[obj1 objectForKey:@"createdAt"] doubleValue];
        double c2 = [[obj2 objectForKey:@"createdAt"] doubleValue];
        if (c1 < c2) return NSOrderedAscending;
        if (c1 > c2) return NSOrderedDescending;
        return NSOrderedSame;
    }];

    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *theme = [defs stringForKey:@"TypeGrapherTheme"];
    if (!theme) theme = @"dark";
    NSString *orderConfigJSON = [defs stringForKey:@"TypeGrapherOrderConfig"];
    if (!orderConfigJSON) orderConfigJSON = @"";

    NSMutableDictionary *root = [NSMutableDictionary dictionary];
    [root setObject:[vaultPath precomposedStringWithCanonicalMapping] forKey:@"vaultPath"];
    [root setObject:[[vaultPath lastPathComponent] precomposedStringWithCanonicalMapping] forKey:@"vaultName"];
    [root setObject:theme forKey:@"theme"];
    [root setObject:orderConfigJSON forKey:@"orderConfigJSON"];
    [root setObject:foldersArray forKey:@"folders"];
    [root setObject:notesArray forKey:@"notes"];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:root options:0 error:nil];
    if (!jsonData) return @"{}";
    return [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
}

- (void)saveOrderConfig:(NSString *)jsonStr {
    if (!jsonStr) return;
    [[NSUserDefaults standardUserDefaults] setObject:jsonStr forKey:@"TypeGrapherOrderConfig"];
}

- (BOOL)createSubfolder:(NSString *)folderName {
    NSString *safeFolder = [self sanitizeRelativePath:folderName];
    if ([safeFolder length] == 0) return NO;
    NSString *fullDir = [vaultPath stringByAppendingPathComponent:safeFolder];
    return [[NSFileManager defaultManager] createDirectoryAtPath:fullDir withIntermediateDirectories:YES attributes:nil error:nil];
}

- (BOOL)saveNoteWithRelPath:(NSString *)relPath content:(NSString *)content {
    NSString *safeRel = [self sanitizeRelativePath:relPath];
    if ([safeRel length] == 0) return NO;
    NSString *fullPath = [vaultPath stringByAppendingPathComponent:safeRel];
    NSString *parentDir = [fullPath stringByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtPath:parentDir withIntermediateDirectories:YES attributes:nil error:nil];
    if (!content) content = @"";
    return [content writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL)renameNoteFrom:(NSString *)oldRel to:(NSString *)newRel content:(NSString *)content {
    NSString *safeOld = [self sanitizeRelativePath:oldRel];
    NSString *safeNew = [self sanitizeRelativePath:newRel];
    if ([safeOld length] == 0 || [safeNew length] == 0) return NO;

    NSString *oldPath = [vaultPath stringByAppendingPathComponent:safeOld];
    NSString *newPath = [vaultPath stringByAppendingPathComponent:safeNew];
    if ([[oldPath lowercaseString] isEqualToString:[newPath lowercaseString]] && [oldPath isEqualToString:newPath]) {
        return [self saveNoteWithRelPath:safeNew content:content];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:newPath]) {
        return NO;
    }
    [fm createDirectoryAtPath:[newPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    if ([fm fileExistsAtPath:oldPath]) {
        if (![fm moveItemAtPath:oldPath toPath:newPath error:nil]) {
            return NO;
        }
    }
    return [self saveNoteWithRelPath:safeNew content:content];
}

- (BOOL)moveItemFrom:(NSString *)srcRel to:(NSString *)dstRel {
    NSString *safeSrc = [self sanitizeRelativePath:srcRel];
    NSString *safeDst = [self sanitizeRelativePath:dstRel];
    if ([safeSrc length] == 0 || [safeDst length] == 0) return NO;
    if ([safeSrc isEqualToString:safeDst]) return YES;

    NSString *srcFull = [vaultPath stringByAppendingPathComponent:safeSrc];
    NSString *dstFull = [vaultPath stringByAppendingPathComponent:safeDst];

    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:srcFull] || [fm fileExistsAtPath:dstFull]) {
        return NO;
    }
    NSString *dstParent = [dstFull stringByDeletingLastPathComponent];
    [fm createDirectoryAtPath:dstParent withIntermediateDirectories:YES attributes:nil error:nil];
    return [fm moveItemAtPath:srcFull toPath:dstFull error:nil];
}

- (BOOL)deleteNoteWithRelPath:(NSString *)relPath {
    NSString *safeRel = [self sanitizeRelativePath:relPath];
    if ([safeRel length] == 0) return NO;
    NSString *fullPath = [[vaultPath stringByAppendingPathComponent:safeRel] stringByStandardizingPath];
    NSString *stdVault = [vaultPath stringByStandardizingPath];
    if ([fullPath isEqualToString:stdVault]) return NO;
    return [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
}

- (BOOL)deleteFolderWithRelPath:(NSString *)relPath {
    NSString *safeRel = [self sanitizeRelativePath:relPath];
    if ([safeRel length] == 0) return NO;
    NSString *fullPath = [[vaultPath stringByAppendingPathComponent:safeRel] stringByStandardizingPath];
    NSString *stdVault = [vaultPath stringByStandardizingPath];
    if ([fullPath isEqualToString:stdVault] || ![fullPath hasPrefix:[stdVault stringByAppendingString:@"/"]]) {
        return NO;
    }
    return [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
}

- (BOOL)chooseVaultFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel setPrompt:@"이 폴더를 TypeGrapher 보관함으로 사용"];

    if ([panel runModal] == NSOKButton) {
        NSURL *url = [[panel URLs] objectAtIndex:0];
        if (url) {
            if (vaultPath) [vaultPath release];
            vaultPath = [[url path] retain];
            vaultInitialized = NO;
            [[NSUserDefaults standardUserDefaults] setObject:vaultPath forKey:@"TypeGrapherDocsVaultPath"];
            [window setTitle:@"TypeGrapher"];
            return YES;
        }
    }
    return NO;
}

- (void)revealInFinder:(NSString *)relPath {
    NSString *safeRel = [self sanitizeRelativePath:relPath];
    if ([safeRel length] == 0) {
        [[NSWorkspace sharedWorkspace] openFile:vaultPath];
        return;
    }
    NSString *fullPath = [vaultPath stringByAppendingPathComponent:safeRel];
    [[NSWorkspace sharedWorkspace] selectFile:fullPath inFileViewerRootedAtPath:vaultPath];
}

- (void)saveTheme:(NSString *)theme {
    if (!theme) return;
    [[NSUserDefaults standardUserDefaults] setObject:theme forKey:@"TypeGrapherTheme"];
}

- (void)syncVault {
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"🔄 외부 폴더 / iCloud 보관함 양방향 동기화 (rsync)"];
    [alert setInformativeText:@"동기화할 대상 폴더(USB 메모리 또는 네트워크 공유 폴더)를 선택하면 하위 폴더를 포함한 최신 .md 파일을 상호 동기화합니다.\n\n한쪽에서 지운 노트와 폴더는 다음 동기화 때 반대쪽에서도 지워집니다. 지워진 항목은 각 폴더의 숨김 폴더 .typegrapher-trash 에 보관되므로 되돌릴 수 있습니다."];
    [alert addButtonWithTitle:@"대상 폴더 선택 및 동기화"];
    if (syncTargetPath && [syncTargetPath length] > 0) {
        [alert addButtonWithTitle:[NSString stringWithFormat:@"기존 폴더로 즉시 동기화 (%@)", [syncTargetPath lastPathComponent]]];
    }
    [alert addButtonWithTitle:@"취소"];

    NSInteger resp = [alert runModal];
    if (resp == NSAlertFirstButtonReturn) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setCanChooseFiles:NO];
        [panel setCanChooseDirectories:YES];
        [panel setCanCreateDirectories:YES];
        [panel setPrompt:@"양방향 동기화 실행"];
        if ([panel runModal] == NSOKButton) {
            NSURL *url = [[panel URLs] objectAtIndex:0];
            if (url) {
                if (syncTargetPath) [syncTargetPath release];
                syncTargetPath = [[url path] retain];
                [[NSUserDefaults standardUserDefaults] setObject:syncTargetPath forKey:@"TypeGrapherSyncPath"];
                [self runRsyncWithTarget:syncTargetPath];
            }
        }
    } else if (resp == NSAlertSecondButtonReturn && syncTargetPath) {
        [self runRsyncWithTarget:syncTargetPath];
    }
}

/* ==========================================================================
   동기화 (rsync) — 백그라운드 실행 (v2.6.1) + 삭제 전파 (v2.7)
   예전에는 rsync 두 번(보내기 · 가져오기)을 메인 스레드에서 실행하고 끝날 때까지 기다렸습니다. 대상이
   네트워크 서버(SMB 공유 폴더)인데 서버가 잠들었거나 연결이 끊기면, 네트워크 타임아웃이 날 때까지
   앱 전체가 멈췄습니다.
   이제 대상 폴더 확인과 rsync 실행을 모두 백그라운드 큐에서 하고, 결과만 메인 스레드에서 알립니다.
   (대상 폴더 확인까지 백그라운드에서 하는 이유: 끊긴 네트워크 볼륨은 '폴더가 있는지 확인'하는 것만으로도
    응답이 올 때까지 멈출 수 있어서, 메인 스레드에서 하면 같은 멈춤이 다시 생깁니다.)

   v2.7: 삭제 전파. rsync 를 실행하기 전에, 지난 동기화 뒤로 한쪽에서 지워진 항목을 반대쪽에서도 치웁니다
   (파일 맨 위의 TGSYNC CORE 구역: tgs_prepare / tgs_commit). 치운 항목은 지우지 않고 각 폴더의 숨김 폴더
   .typegrapher-trash 로 옮깁니다. 지난 동기화의 기록은 두 폴더 안의 숨김 폴더 .typegrapher-sync 에 있으므로,
   두 Mac 중 어느 쪽에서 동기화를 실행해도 같은 기록을 씁니다.
   ========================================================================== */

/* rsync 를 한 번 실행하고 끝날 때까지 기다립니다. 반드시 백그라운드 스레드에서 부릅니다.
   돌려주는 값: rsync 의 종료 코드 (0 = 성공).
   실행 자체를 못 했거나 신호로 중단됐으면 -1 을 돌려주고 *problem 에 이유를 넣습니다. */
static int TGRunRsyncOnce(NSString *source, NSString *destination, NSString **problem) {
    NSString *rsyncPath = @"/usr/bin/rsync";
    if (![[NSFileManager defaultManager] isExecutableFileAtPath:rsyncPath]) {
        if (problem) *problem = @"이 Mac 에서 /usr/bin/rsync 를 찾을 수 없습니다.";
        return -1;
    }
    NSTask *task = [[[NSTask alloc] init] autorelease];
    [task setLaunchPath:rsyncPath];
    /* --timeout=5 : 5초 동안 데이터가 오가지 않으면 rsync 가 스스로 끝납니다 (종료 코드 30) */
    [task setArguments:[NSArray arrayWithObjects:@"-avu", @"--timeout=5", @"--exclude=.*", source, destination, nil]];
    @try {
        [task launch];
    }
    @catch (id exception) {
        /* launch 는 실행할 수 없을 때 예외를 던집니다. 백그라운드 스레드에서 잡지 않으면 앱이 종료되므로 여기서 잡습니다. */
        if (problem) *problem = [NSString stringWithFormat:@"rsync 를 시작하지 못했습니다: %@", exception];
        return -1;
    }
    [task waitUntilExit];
    if ([task terminationReason] != NSTaskTerminationReasonExit) {
        if (problem) *problem = [NSString stringWithFormat:@"rsync 가 신호 %d 로 중단되었습니다.", [task terminationStatus]];
        return -1;
    }
    return [task terminationStatus];
}

/* rsync 종료 코드를 설명 문장으로 바꿉니다 (rsync 설명서의 EXIT VALUES: 30 · 35 = 타임아웃, 23 · 24 = 일부만 전송) */
static NSString *TGRsyncFailureText(int code) {
    if (code == 30 || code == 35) {
        return [NSString stringWithFormat:@"서버가 5초 동안 응답하지 않아 중단했습니다 (타임아웃, rsync 종료 코드 %d).", code];
    }
    if (code == 23 || code == 24) {
        return [NSString stringWithFormat:@"일부 파일을 옮기지 못했습니다 (rsync 종료 코드 %d).", code];
    }
    return [NSString stringWithFormat:@"rsync 가 오류로 끝났습니다 (종료 코드 %d). 서버 연결 상태를 확인해 주세요.", code];
}

/* 상태 표시줄에 한 줄을 표시합니다 (메인 스레드 전용). message 에는 따옴표 · 역슬래시가 없는 고정 문구만 넘깁니다. */
- (void)showSyncStatus:(NSString *)message {
    if (!webView || !message) return;
    [webView stringByEvaluatingJavaScriptFromString:
        [NSString stringWithFormat:@"if (window.TypeGrapherApp && window.TypeGrapherApp.showStatus) { window.TypeGrapherApp.showStatus('%@'); }", message]];
}

- (void)runRsyncWithTarget:(NSString *)target {
    if (!target || [target length] == 0 || !vaultPath || [target isEqualToString:vaultPath]) return;

    /* 이미 진행 중이면 겹쳐 실행하지 않습니다 (같은 폴더에 rsync 두 벌이 동시에 쓰지 않도록) */
    if (syncInProgress) {
        NSAlert *busy = [[[NSAlert alloc] init] autorelease];
        [busy setMessageText:@"🔄 동기화가 이미 진행 중입니다"];
        [busy setInformativeText:@"진행 중인 동기화가 끝나면 결과를 알려 드립니다. 서버가 응답하지 않으면 시간이 걸릴 수 있습니다."];
        [busy runModal];
        return;
    }
    syncInProgress = YES;

    /* 백그라운드에서 쓸 값은 지금(메인 스레드에서) 복사해 둡니다. 블록이 복사될 때 이 객체들을 붙잡아(retain) 두므로,
       동기화 도중에 보관함이나 동기화 대상을 바꿔도 안전합니다. 백그라운드 블록은 인스턴스 변수를 건드리지 않습니다. */
    NSString *targetPath = [[target copy] autorelease];
    NSString *vaultCopy = [[vaultPath copy] autorelease];
    NSString *srcSlash = [vaultCopy hasSuffix:@"/"] ? vaultCopy : [vaultCopy stringByAppendingString:@"/"];
    NSString *dstSlash = [targetPath hasSuffix:@"/"] ? targetPath : [targetPath stringByAppendingString:@"/"];
    NSString *vaultName = [vaultCopy lastPathComponent];
    NSString *targetName = [targetPath lastPathComponent];

    /* 진행 중임을 상태 표시줄에 알립니다 (지금 실행 중인 화면 쪽 스크립트가 끝난 뒤에 표시되도록 한 박자 늦춥니다) */
    dispatch_async(dispatch_get_main_queue(), ^{
        if (syncInProgress) [self showSyncStatus:@"🔄 동기화 중… (백그라운드에서 진행)"];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString *title = nil;
        NSString *detail = nil;
        NSString *statusLine = nil;
        BOOL ranRsync = NO;

        /* 1) 사전 검증: 대상 폴더(마운트된 볼륨 안의 경로)가 실제로 있는지 확인 */
        BOOL isDirectory = NO;
        BOOL targetExists = [[NSFileManager defaultManager] fileExistsAtPath:targetPath isDirectory:&isDirectory];
        if (!targetExists || !isDirectory) {
            title = @"⚠️ 서버 연결이 끊겼거나 잠자기 상태입니다";
            detail = [NSString stringWithFormat:@"동기화 대상 폴더를 찾을 수 없어 동기화하지 않았습니다.\n\n%@\n\n서버(또는 외장 디스크)가 켜져 있고 연결되어 있는지 확인한 뒤 다시 시도해 주세요.", targetPath];
            statusLine = @"⚠️ 동기화 대상에 연결할 수 없습니다";
        } else {
            /* 2) 삭제 전파: 지난 동기화 뒤로 한쪽에서 지워진 항목을 반대쪽에서도 치웁니다 (숨김 보관 폴더로 옮김).
                  지난 동기화의 기록(스냅샷)은 두 폴더 안의 숨김 폴더 .typegrapher-sync 에 있습니다. */
            const char *rootA = [vaultCopy fileSystemRepresentation];
            const char *rootB = [targetPath fileSystemRepresentation];
            tgs_report report;
            int prepared = tgs_prepare(rootA, rootB, TGSyncNormalize, &report);
            int removedCount = report.deletedA + report.deletedB;

            /* 3) 보내기(내 보관함 → 대상) → 4) 가져오기(대상 → 내 보관함). 앞 단계가 실패하면 뒤 단계는 실행하지 않습니다. */
            NSString *problem = nil;
            NSString *stage = @"보내기 (내 보관함 → 대상 폴더)";
            ranRsync = YES;
            int code = TGRunRsyncOnce(srcSlash, dstSlash, &problem);
            if (code == 0) {
                stage = @"가져오기 (대상 폴더 → 내 보관함)";
                code = TGRunRsyncOnce(dstSlash, srcSlash, &problem);
            }

            /* 치운 항목에 대한 안내 (성공 · 실패 알림에 함께 붙입니다) */
            NSString *removedNote = @"";
            if (removedCount > 0) {
                removedNote = [NSString stringWithFormat:@"\n\n한쪽에서 지운 항목을 반대쪽에서도 치웠습니다: 내 보관함 %d개, 대상 폴더 %d개.\n치운 항목은 각 폴더의 숨김 폴더 .typegrapher-trash/%s 에 보관되어 있어 되돌릴 수 있습니다.",
                               report.deletedA, report.deletedB, report.trashBatch];
            }
            if (report.keptModified > 0) {
                removedNote = [removedNote stringByAppendingFormat:@"\n\n한쪽에서 지워졌지만 반대쪽에서 수정된 %d개는 지우지 않고 되살렸습니다.", report.keptModified];
            }
            if (report.moveFailed > 0) {
                removedNote = [removedNote stringByAppendingFormat:@"\n\n(%d개는 치우지 못해 그대로 두었습니다.)", report.moveFailed];
            }

            if (code == 0) {
                /* 5) 두 번 모두 성공했을 때만 지금 상태를 동기화 기록으로 남깁니다 */
                int committed = (prepared == 0) ? tgs_commit(rootA, rootB, TGSyncNormalize) : -1;   /* 0: 양쪽에 적음, 1: 한쪽에만 적음, -1: 못 적음 */
                NSString *trackNote = @"";
                if (prepared != 0) {
                    trackNote = @"\n\n(이 대상과는 삭제 전파를 하지 않았습니다: 폴더에 표식 파일을 만들 수 없거나, 두 폴더가 같은 폴더이거나 서로 겹칩니다.)";
                } else if (report.aborted) {
                    trackNote = @"\n\n(삭제 전파 도중 반대쪽 폴더를 확인할 수 없어 나머지는 치우지 않았습니다.)";
                } else if (report.skipped) {
                    trackNote = @"\n\n(폴더 목록을 끝까지 읽지 못해 이번에는 삭제 전파를 건너뛰었습니다.)";
                } else if (report.firstSync) {
                    trackNote = @"\n\n이 대상과의 동기화 기록을 새로 만들었습니다. 이번에는 양쪽을 합치기만 했고, 한쪽에서 지운 항목은 다음 동기화부터 반대쪽에서도 지워집니다.";
                }
                if (prepared == 0 && committed < 0) {
                    trackNote = [trackNote stringByAppendingString:@"\n\n(동기화 기록을 저장하지 못했습니다. 다음 동기화에서는 삭제가 전파되지 않을 수 있습니다.)"];
                }
                title = @"✅ 양방향 동기화 완료";
                detail = [NSString stringWithFormat:@"%@ ⇄ %@ 폴더의 노트가 최신 상태로 동기화되었습니다.%@%@", vaultName, targetName, removedNote, trackNote];
                statusLine = @"✅ 동기화 완료";
            } else {
                title = @"⚠️ 동기화에 실패했습니다";
                detail = [NSString stringWithFormat:@"%@ 단계에서 멈췄습니다.\n%@\n\n대상: %@%@", stage, (problem ? problem : TGRsyncFailureText(code)), targetPath, removedNote];
                statusLine = @"⚠️ 동기화 실패";
            }
        }

        /* 4) 결과는 메인 스레드로 돌아와서 알립니다 (화면과 알림창은 메인 스레드에서만 다룹니다) */
        dispatch_async(dispatch_get_main_queue(), ^{
            syncInProgress = NO;
            if (ranRsync && webView) {
                /* 가져온 노트가 목록에 보이도록 보관함을 다시 읽습니다 */
                [webView stringByEvaluatingJavaScriptFromString:@"if (window.TypeGrapherApp && window.TypeGrapherApp.reloadVault) { window.TypeGrapherApp.reloadVault(); }"];
            }
            [self showSyncStatus:statusLine];
            NSAlert *done = [[[NSAlert alloc] init] autorelease];
            [done setMessageText:title];
            [done setInformativeText:detail];
            [done runModal];
        });
        [pool drain];
    });
}

- (void)setupMenus {
    NSMenu *menubar = [[[NSMenu alloc] init] autorelease];
    NSMenuItem *appMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [menubar addItem:appMenuItem];
    [NSApp setMainMenu:menubar];

    NSMenu *appMenu = [[[NSMenu alloc] init] autorelease];
    [appMenu addItemWithTitle:@"TypeGrapher 정보" action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"종료 (Quit)" action:@selector(terminate:) keyEquivalent:@"q"];
    [appMenuItem setSubmenu:appMenu];

    NSMenuItem *fileMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [menubar addItem:fileMenuItem];
    NSMenu *fileMenu = [[[NSMenu alloc] initWithTitle:@"파일"] autorelease];
    [fileMenu addItemWithTitle:@"새 노트 하단 추가" action:@selector(menuNewNote:) keyEquivalent:@"n"];
    [fileMenu addItemWithTitle:@"오늘 일기 열기/하단 생성 (YYYY년 MM월 DD일 (요일))" action:@selector(menuDailyNote:) keyEquivalent:@"d"];
    [fileMenu addItemWithTitle:@"폴더 하단 추가 (선택된 폴더 내부 또는 루트)..." action:@selector(menuNewSubfolder:) keyEquivalent:@"N"];
    [fileMenu addItemWithTitle:@"폴더 및 파일 자동 정렬..." action:@selector(menuAutoSort:) keyEquivalent:@"S"];

    NSString *backspaceKey = [NSString stringWithFormat:@"%C", (unichar)0x08];
    NSMenuItem *delItem = [[[NSMenuItem alloc] initWithTitle:@"선택된 파일 또는 폴더 삭제" action:@selector(menuDeleteNote:) keyEquivalent:backspaceKey] autorelease];
    [delItem setKeyEquivalentModifierMask:NSCommandKeyMask];
    [fileMenu addItem:delItem];

    [fileMenu addItem:[NSMenuItem separatorItem]];
    [fileMenu addItemWithTitle:@"지금 재생 중인 BGM 스탬프 각인" action:@selector(menuStampBGM:) keyEquivalent:@"m"];
    [fileMenu addItemWithTitle:@"월간 집필 천공 카드 히트맵 보기..." action:@selector(menuOpenStats:) keyEquivalent:@"g"];
    [fileMenu addItemWithTitle:@"문서 인쇄..." action:@selector(menuPrintNote:) keyEquivalent:@"p"];
    [fileMenu addItemWithTitle:@"PDF 로 내보내기..." action:@selector(menuExportPDF:) keyEquivalent:@""];
    [fileMenu addItem:[NSMenuItem separatorItem]];
    [fileMenu addItemWithTitle:@"보관함 루트 폴더 변경..." action:@selector(menuChangeVault:) keyEquivalent:@"o"];
    [fileMenu addItemWithTitle:@"보관함 목록 새로고침" action:@selector(menuReloadVault:) keyEquivalent:@"r"];
    [fileMenu addItemWithTitle:@"다크 / 라이트 테마 전환" action:@selector(menuToggleTheme:) keyEquivalent:@"t"];
    [fileMenuItem setSubmenu:fileMenu];

    NSMenuItem *editMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [menubar addItem:editMenuItem];
    NSMenu *editMenu = [[[NSMenu alloc] initWithTitle:@"편집"] autorelease];
    [editMenu addItemWithTitle:@"실행 취소" action:@selector(undo:) keyEquivalent:@"z"];
    [editMenu addItemWithTitle:@"다시 실행" action:@selector(redo:) keyEquivalent:@"Z"];
    [editMenu addItem:[NSMenuItem separatorItem]];
    [editMenu addItemWithTitle:@"오려두기" action:@selector(cut:) keyEquivalent:@"x"];
    [editMenu addItemWithTitle:@"복사하기" action:@selector(copy:) keyEquivalent:@"c"];
    [editMenu addItemWithTitle:@"붙여넣기" action:@selector(paste:) keyEquivalent:@"v"];
    [editMenu addItemWithTitle:@"전체 선택" action:@selector(selectAll:) keyEquivalent:@"a"];
    [editMenuItem setSubmenu:editMenu];
}

- (void)menuNewNote:(id)sender { [webView stringByEvaluatingJavaScriptFromString:@"window.TypeGrapherApp.newNote();"]; }
- (void)menuDailyNote:(id)sender { [webView stringByEvaluatingJavaScriptFromString:@"window.TypeGrapherApp.dailyNote();"]; }
- (void)menuNewSubfolder:(id)sender { [webView stringByEvaluatingJavaScriptFromString:@"window.TypeGrapherApp.newSubfolder();"]; }
- (void)menuAutoSort:(id)sender { [webView stringByEvaluatingJavaScriptFromString:@"window.TypeGrapherApp.autoSort();"]; }
- (void)menuDeleteNote:(id)sender { [webView stringByEvaluatingJavaScriptFromString:@"window.TypeGrapherApp.deleteNote();"]; }
- (void)menuStampBGM:(id)sender { [webView stringByEvaluatingJavaScriptFromString:@"window.TypeGrapherApp.stampBGM();"]; }
- (void)menuOpenStats:(id)sender { [webView stringByEvaluatingJavaScriptFromString:@"window.TypeGrapherApp.openStats();"]; }
- (void)menuPrintNote:(id)sender { [webView stringByEvaluatingJavaScriptFromString:@"window.TypeGrapherApp.printNote();"]; }
- (void)menuExportPDF:(id)sender { [webView stringByEvaluatingJavaScriptFromString:@"window.TypeGrapherApp.exportPDF();"]; }
- (void)menuChangeVault:(id)sender { [webView stringByEvaluatingJavaScriptFromString:@"window.TypeGrapherApp.changeVault();"]; }
- (void)menuReloadVault:(id)sender { [webView stringByEvaluatingJavaScriptFromString:@"window.TypeGrapherApp.reloadVault();"]; }
- (void)menuToggleTheme:(id)sender { [webView stringByEvaluatingJavaScriptFromString:@"window.TypeGrapherApp.toggleTheme();"]; }

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self setupMenus];

    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;
    window = [[NSWindow alloc] initWithContentRect:NSMakeRect(60, 60, 1180, 740)
                                         styleMask:style
                                           backing:NSBackingStoreBuffered
                                             defer:NO];
    [window setTitle:@"TypeGrapher"];
    [window setMinSize:NSMakeSize(720, 480)];
    [window setDelegate:self];

    NSView *content = [window contentView];
    webView = [[WebView alloc] initWithFrame:[content bounds] frameName:@"TypeGrapherMainFrame" groupName:@"TypeGrapherGroup"];
    [webView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [webView setFrameLoadDelegate:self];
#if TG_PDF_ENGINE
    /* 인쇄할 때 배경(원고지 줄, 인용 · 코드 바탕색)도 함께 찍히게 한다 */
    [[webView preferences] setShouldPrintBackgrounds:YES];
#endif

    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"typegrapher" ofType:@"html"];
    NSURL *htmlURL = [NSURL fileURLWithPath:htmlPath];
    /* NSURLRequest 는 OS 버전에 따라 들어 있는 라이브러리가 달라서(예전: Foundation, 지금: CFNetwork) 실행 중에 찾는다 */
    [[webView mainFrame] loadRequest:[NSClassFromString(@"NSURLRequest") requestWithURL:htmlURL]];

    [content addSubview:webView];
    [window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

int main(int argc, const char * argv[]) {
    /* 빌드 직후 자가 점검: 빌더가 "--tg-selftest" 를 붙여 실행한다. 여기까지 왔다는 것은 이 Mac 에서 실행 파일이
       '열리는 단계'(시스템 라이브러리 · 심벌 연결)를 통과했다는 뜻이므로, 창을 띄우지 않고 바로 끝낸다. */
    if (argc > 1 && strcmp(argv[1], "--tg-selftest") == 0) {
        puts("TG_SELFTEST_OK");
        return 0;
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSApplication *app = [NSApplication sharedApplication];
    [app setActivationPolicy:0];
    TypeGrapherController *controller = [[[TypeGrapherController alloc] init] autorelease];
    [app setDelegate:controller];
    [app run];
    [pool drain];
    return 0;
}
'''

src_file = os.path.join(res_dir, "main.m")
with open(src_file, "w", encoding="utf-8") as f:
    f.write(objc_source)

bin_file = os.path.join(macos_dir, "TypeGrapher")

clang_base = [
    "clang", "-arch", "x86_64", "-mmacosx-version-min=10.7",
    "-fno-objc-arc", "-Wno-deprecated-declarations", "-O2",
]
# ---------------------------------------------------------------------------------------------
# 링크 방식과 자가 점검
#  · 구형 Mac 호환 링크(-flat_namespace): 최신 SDK 는 클래스 · 함수가 '어느 시스템 라이브러리에 들어 있는지'를
#    최신 macOS 기준으로 실행 파일에 적어 넣습니다. 그런데 일부는 예전 OS X 에서 다른 라이브러리에 들어 있어서
#    (예: NSURLRequest 는 예전에는 Foundation, 지금은 CFNetwork) 구형 Mac 에서 "Symbol not found" 로 앱이 열리지
#    않습니다. 이 방식으로 링크하면 위치를 적어 넣지 않고, 실행할 때 그 Mac 에 실제로 있는 곳에서 찾습니다.
#  · 자가 점검: 방금 만든 실행 파일을 이 Mac 에서 '--tg-selftest' 로 한 번 실행해, 열리는 단계(라이브러리 ·
#    심벌 연결)를 통과하는지 확인합니다. 창은 뜨지 않고 바로 끝납니다. 통과하지 못하면 기존 방식으로 다시 링크합니다.
#  · 새 조판 엔진의 컴파일이 실패하면 엔진을 빼고(TG_PDF_ENGINE=0) 빌드합니다 (앱은 그대로 쓸 수 있음).
# ---------------------------------------------------------------------------------------------
def tg_link(engine, flat):
    cmd = clang_base + ["-DTG_PDF_ENGINE=%d" % engine, src_file, "-framework", "Cocoa", "-framework", "WebKit"]
    if flat:
        cmd = cmd + ["-Wl,-flat_namespace"]
    return subprocess.run(cmd + ["-o", bin_file], capture_output=True, text=True)


def tg_selftest():
    try:
        run = subprocess.run([bin_file, "--tg-selftest"], capture_output=True, text=True, timeout=60)
        out = (run.stdout or "") + (run.stderr or "")
        return (run.returncode == 0 and "TG_SELFTEST_OK" in out), ("종료 코드 %s\n%s" % (run.returncode, out[-1500:]))
    except Exception as exc:
        return False, str(exc)


tg_chosen = None        # (engine, flat): 최종으로 쓰는 조합
tg_built = []           # 컴파일 · 링크까지는 된 조합
tg_notes = {}           # 조합별 실패 내용
for tg_engine, tg_flat in [(1, True), (1, False), (0, True), (0, False)]:
    tg_res = tg_link(tg_engine, tg_flat)
    if tg_res.returncode != 0:
        tg_notes[(tg_engine, tg_flat)] = ("build", (tg_res.stderr or "")[-4000:])
        continue
    tg_built.append((tg_engine, tg_flat))
    tg_ok, tg_detail = tg_selftest()
    if tg_ok:
        tg_chosen = (tg_engine, tg_flat)
        break
    tg_notes[(tg_engine, tg_flat)] = ("selftest", tg_detail)

tg_selftest_passed = tg_chosen is not None
if tg_chosen is None:
    if not tg_built:
        print("❌ 컴파일에 실패했습니다. 아래 오류 내용을 알려 주세요:")
        print("-" * 60)
        print(tg_notes.get((0, False), ("", ""))[1] or tg_notes.get((1, False), ("", ""))[1])
        print("-" * 60)
        raise SystemExit(1)
    # 자가 점검을 통과한 조합이 없으면(점검 자체를 실행할 수 없는 환경 등) 기존 방식 링크를 우선해서 고른다
    for tg_pick in [(1, False), (0, False), (1, True), (0, True)]:
        if tg_pick in tg_built:
            tg_chosen = tg_pick
            break
    tg_link(tg_chosen[0], tg_chosen[1])

if tg_chosen[0] == 1:
    print("🖨️ 새 인쇄 · PDF 조판 엔진 포함 빌드 성공")
else:
    print("⚠️ 새 인쇄 · PDF 조판 엔진의 컴파일에 실패해서, 기존 인쇄 방식만 넣고 빌드했습니다.")
    print("   아래 오류 내용을 알려 주시면 고칠 수 있습니다:")
    print("-" * 60)
    print(tg_notes.get((1, False), tg_notes.get((1, True), ("", "")))[1])
    print("-" * 60)

if tg_chosen[1] and tg_selftest_passed:
    print("✅ 구형 Mac 호환 방식으로 링크했고, 이 Mac 에서 실행 점검을 통과했습니다.")
elif tg_selftest_passed:
    print("⚠️ 구형 Mac 호환 방식으로 만든 실행 파일을 쓸 수 없어서 기존 방식으로 링크했습니다.")
    print("   이 Mac 에서는 정상 동작하지만, 구형 Mac 에서는 열리지 않을 수 있습니다. 아래 내용을 알려 주세요:")
    print("-" * 60)
    print("[%s] %s" % tg_notes.get((tg_chosen[0], True), ("?", "")))
    print("-" * 60)
else:
    print("⚠️ 실행 점검을 통과한 빌드가 없어서 기존 방식으로 링크한 것을 사용합니다. 아래 내용을 알려 주세요:")
    print("-" * 60)
    for tg_key in sorted(tg_notes):
        print("[엔진=%d, 호환 링크=%s, %s] %s" % (tg_key[0], tg_key[1], tg_notes[tg_key][0], tg_notes[tg_key][1][-800:]))
    print("-" * 60)

# 실행 파일이 '열리는 순간' 요구하는 시스템 라이브러리 목록을 보여 줍니다.
# 이 목록에 구형 Mac 에 없는 경로가 하나라도 있으면 그 Mac 에서는 앱이 아예 열리지 않습니다.
try:
    otool_out = subprocess.run(["otool", "-L", bin_file], capture_output=True, text=True).stdout
    linked_libs = [ln.strip().split(" (compatibility")[0] for ln in otool_out.splitlines()[1:] if ln.strip()]
except Exception:
    linked_libs = []
if linked_libs:
    print("🔎 실행 파일이 연결한 시스템 라이브러리 (%d개):" % len(linked_libs))
    for lib in linked_libs:
        print("     " + lib)
    too_new = [lib for lib in linked_libs
               if lib.startswith("/System/Library/Frameworks/PDFKit.framework/")
               or lib.startswith("/System/Library/Frameworks/QuickLookUI.framework/")]
    if too_new:
        print("⚠️ 아래 경로는 최신 macOS 에만 있어서, 구형 Mac 에서는 앱이 열리지 않습니다. 이 내용을 알려 주세요:")
        for lib in too_new:
            print("     " + lib)
    elif any(lib.startswith("/System/Library/Frameworks/CoreGraphics.framework/") for lib in linked_libs):
        print("ℹ️ CoreGraphics 가 최상위 경로로 연결되었습니다. OS X 10.8 이상에서는 문제없지만 10.7 에서는 열리지 않을 수 있습니다.")
    else:
        print("✅ 구형 Mac 에서 문제가 되는 경로(PDFKit 등)는 들어 있지 않습니다.")
else:
    print("ℹ️ otool 로 연결 라이브러리를 확인하지 못했습니다 (빌드에는 영향 없음).")
os.chmod(bin_file, 0o755)

# 4. 앱 아이콘 생성 및 번들 리소스 + 파인더 커스텀 아이콘(NSWorkspace) 이중 각인
iconset_dir = "/tmp/TypeGrapher.iconset"
if os.path.exists(iconset_dir):
    shutil.rmtree(iconset_dir)
os.makedirs(iconset_dir, exist_ok=True)
master_png = "/tmp/typegrapher_master_1024.png"

found_user_png = None
search_candidates = [
    os.path.join(downloads, "typewriter-skeuomorphic.png"),
    os.path.join(downloads, "typewriter-skeuomorphic_2.png"),
    os.path.join(desktop, "typewriter-skeuomorphic.png"),
    os.path.join(desktop, "typewriter-skeuomorphic_2.png"),
    os.path.join(documents, "typewriter-skeuomorphic.png"),
    os.path.expanduser("~/typewriter-skeuomorphic.png")
]
for cand in search_candidates:
    if os.path.exists(cand):
        found_user_png = cand
        break

if not found_user_png:
    try:
        md_out = subprocess.check_output(["mdfind", "kMDItemFSName == '*typewriter*skeuomorphic*'"]).decode("utf-8").strip().split("\n")
        for line in md_out:
            if line and os.path.exists(line) and line.lower().endswith(".png"):
                found_user_png = line
                break
    except Exception:
        pass

skeuo_objc = r'''
#import <Cocoa/Cocoa.h>

void drawRoundedRect(NSRect rect, CGFloat radius, NSColor *fill, NSColor *stroke, CGFloat lineWidth) {
    NSBezierPath *p = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius];
    if (fill) { [fill setFill]; [p fill]; }
    if (stroke) { [stroke setStroke]; [p setLineWidth:lineWidth]; [p stroke]; }
}

int main(int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (argc < 3) return 1;
    NSString *outPath = [NSString stringWithUTF8String:argv[1]];
    NSString *appBundlePath = [NSString stringWithUTF8String:argv[2]];
    NSString *existingPng = (argc >= 4) ? [NSString stringWithUTF8String:argv[3]] : @"";

    NSImage *finalImg = nil;
    if ([existingPng length] > 0 && [[NSFileManager defaultManager] fileExistsAtPath:existingPng]) {
        finalImg = [[[NSImage alloc] initWithContentsOfFile:existingPng] autorelease];
    }

    if (!finalImg) {
        NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes:NULL
                          pixelsWide:1024
                          pixelsHigh:1024
                       bitsPerSample:8
                     samplesPerPixel:4
                            hasAlpha:YES
                            isPlanar:NO
                      colorSpaceName:NSCalibratedRGBColorSpace
                         bytesPerRow:0
                        bitsPerPixel:0] autorelease];
        [rep setSize:NSMakeSize(1024, 1024)];

        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];

        NSRect bgRect = NSMakeRect(86, 86, 852, 852);
        NSBezierPath *bgPath = [NSBezierPath bezierPathWithRoundedRect:bgRect xRadius:190 yRadius:190];
        NSGradient *bgGrad = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.93 green:0.90 blue:0.84 alpha:1.0]
                                                            endingColor:[NSColor colorWithCalibratedRed:0.84 green:0.79 blue:0.71 alpha:1.0]] autorelease];
        [bgGrad drawInBezierPath:bgPath angle:-90];

        [NSGraphicsContext saveGraphicsState];
        [bgPath addClip];
        [[NSColor colorWithCalibratedRed:0.76 green:0.71 blue:0.63 alpha:0.65] setStroke];
        for (int y = 130; y < 900; y += 44) {
            NSBezierPath *line = [NSBezierPath bezierPath];
            [line moveToPoint:NSMakePoint(86, y)];
            [line lineToPoint:NSMakePoint(938, y)];
            [line setLineWidth:3.0];
            [line stroke];
        }
        [NSGraphicsContext restoreGraphicsState];
        [[NSColor colorWithCalibratedRed:0.72 green:0.67 blue:0.59 alpha:1.0] setStroke];
        [bgPath setLineWidth:4.0];
        [bgPath stroke];

        NSRect paperRect = NSMakeRect(312, 490, 400, 390);
        NSBezierPath *paperPath = [NSBezierPath bezierPathWithRoundedRect:paperRect xRadius:6 yRadius:6];
        NSGradient *paperGrad = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]
                                                               endingColor:[NSColor colorWithCalibratedRed:0.92 green:0.92 blue:0.92 alpha:1.0]] autorelease];
        [paperGrad drawInBezierPath:paperPath angle:0];

        NSColor *lineColor = [NSColor colorWithCalibratedRed:0.42 green:0.42 blue:0.42 alpha:1.0];
        CGFloat lineWidths[5] = {250, 295, 210, 270, 175};
        for (int i = 0; i < 5; i++) {
            CGFloat ly = 720 - i * 38;
            drawRoundedRect(NSMakeRect(360, ly, lineWidths[i], 12), 6, lineColor, nil, 0);
        }

        NSBezierPath *lever = [NSBezierPath bezierPath];
        [lever moveToPoint:NSMakePoint(210, 565)];
        [lever lineToPoint:NSMakePoint(118, 616)];
        [[NSColor colorWithCalibratedRed:0.75 green:0.76 blue:0.78 alpha:1.0] setStroke];
        [lever setLineWidth:18.0];
        [lever setLineCapStyle:NSRoundLineCapStyle];
        [lever stroke];
        drawRoundedRect(NSMakeRect(98, 602, 34, 34), 17, [NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1.0], nil, 0);

        drawRoundedRect(NSMakeRect(146, 524, 732, 46), 14, [NSColor colorWithCalibratedRed:0.16 green:0.16 blue:0.16 alpha:1.0], nil, 0);
        NSRect rollerRect = NSMakeRect(194, 510, 636, 78);
        NSBezierPath *rollerPath = [NSBezierPath bezierPathWithRoundedRect:rollerRect xRadius:28 yRadius:28];
        NSGradient *rollerGrad = [[[NSGradient alloc] initWithColorsAndLocations:
            [NSColor colorWithCalibratedRed:0.08 green:0.08 blue:0.08 alpha:1.0], 0.0,
            [NSColor colorWithCalibratedRed:0.32 green:0.32 blue:0.32 alpha:1.0], 0.65,
            [NSColor colorWithCalibratedRed:0.12 green:0.12 blue:0.12 alpha:1.0], 1.0, nil] autorelease];
        [rollerGrad drawInBezierPath:rollerPath angle:90];

        NSBezierPath *bodyPath = [NSBezierPath bezierPath];
        [bodyPath moveToPoint:NSMakePoint(220, 148)];
        [bodyPath lineToPoint:NSMakePoint(804, 148)];
        [bodyPath curveToPoint:NSMakePoint(846, 195) controlPoint1:NSMakePoint(832, 148) controlPoint2:NSMakePoint(850, 168)];
        [bodyPath lineToPoint:NSMakePoint(792, 495)];
        [bodyPath curveToPoint:NSMakePoint(748, 528) controlPoint1:NSMakePoint(786, 518) controlPoint2:NSMakePoint(770, 528)];
        [bodyPath lineToPoint:NSMakePoint(276, 528)];
        [bodyPath curveToPoint:NSMakePoint(232, 495) controlPoint1:NSMakePoint(254, 528) controlPoint2:NSMakePoint(238, 518)];
        [bodyPath lineToPoint:NSMakePoint(178, 195)];
        [bodyPath curveToPoint:NSMakePoint(220, 148) controlPoint1:NSMakePoint(174, 168) controlPoint2:NSMakePoint(192, 148)];
        [bodyPath closePath];

        NSGradient *redGrad = [[[NSGradient alloc] initWithColorsAndLocations:
            [NSColor colorWithCalibratedRed:0.65 green:0.08 blue:0.06 alpha:1.0], 0.0,
            [NSColor colorWithCalibratedRed:0.86 green:0.16 blue:0.13 alpha:1.0], 0.45,
            [NSColor colorWithCalibratedRed:0.96 green:0.26 blue:0.21 alpha:1.0], 1.0, nil] autorelease];
        [redGrad drawInBezierPath:bodyPath angle:90];
        [[NSColor colorWithCalibratedRed:0.48 green:0.05 blue:0.04 alpha:1.0] setStroke];
        [bodyPath setLineWidth:6.0];
        [bodyPath stroke];

        NSRect winRect = NSMakeRect(386, 442, 252, 68);
        drawRoundedRect(winRect, 26, [NSColor colorWithCalibratedRed:0.08 green:0.05 blue:0.05 alpha:1.0],
                        [NSColor colorWithCalibratedRed:0.35 green:0.12 blue:0.12 alpha:1.0], 3.0);
        [[NSColor colorWithCalibratedRed:0.78 green:0.80 blue:0.82 alpha:1.0] setStroke];
        for (int i = -4; i <= 4; i++) {
            NSBezierPath *bar = [NSBezierPath bezierPath];
            [bar moveToPoint:NSMakePoint(512 + i * 10, 448)];
            [bar lineToPoint:NSMakePoint(512 + i * 24, 502)];
            [bar setLineWidth:4.5];
            [bar stroke];
        }

        drawRoundedRect(NSMakeRect(438, 404, 148, 22), 5,
                        [NSColor colorWithCalibratedRed:0.82 green:0.83 blue:0.85 alpha:1.0],
                        [NSColor colorWithCalibratedRed:0.45 green:0.45 blue:0.45 alpha:1.0], 2.0);

        NSArray *row1 = [NSArray arrayWithObjects:@"Q",@"W",@"E",@"R",@"T",@"Y",@"U",@"I",@"O",@"P",nil];
        NSArray *row2 = [NSArray arrayWithObjects:@"A",@"S",@"D",@"F",@"G",@"H",@"J",@"K",@"L",@";",nil];
        NSArray *row3 = [NSArray arrayWithObjects:@"Z",@"X",@"C",@"V",@"B",@"N",@"M",@",",@".",nil];
        NSArray *rows = [NSArray arrayWithObjects:row1, row2, row3, nil];
        CGFloat rowY[3] = {338, 276, 214};

        NSMutableParagraphStyle *pStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
        [pStyle setAlignment:NSCenterTextAlignment];
        NSDictionary *txtAttr = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont boldSystemFontOfSize:20.0], NSFontAttributeName,
            [NSColor colorWithCalibratedRed:0.95 green:0.88 blue:0.68 alpha:1.0], NSForegroundColorAttributeName,
            pStyle, NSParagraphStyleAttributeName, nil];

        for (int r = 0; r < 3; r++) {
            NSArray *curRow = [rows objectAtIndex:r];
            NSUInteger kCount = [curRow count];
            CGFloat startX = (r < 2) ? 236.0 : 264.0;
            for (NSUInteger k = 0; k < kCount; k++) {
                CGFloat kx = startX + k * 56.0;
                CGFloat ky = rowY[r];
                NSBezierPath *outerKey = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(kx, ky, 48, 48)];
                [[NSColor colorWithCalibratedRed:0.75 green:0.76 blue:0.78 alpha:1.0] setFill];
                [outerKey fill];

                NSBezierPath *innerKey = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(kx + 4, ky + 4, 40, 40)];
                [[NSColor colorWithCalibratedRed:0.14 green:0.14 blue:0.15 alpha:1.0] setFill];
                [innerKey fill];

                NSString *ch = [curRow objectAtIndex:k];
                [ch drawInRect:NSMakeRect(kx, ky + 10, 48, 28) withAttributes:txtAttr];
            }
        }

        drawRoundedRect(NSMakeRect(334, 162, 356, 38), 16,
                        [NSColor colorWithCalibratedRed:0.12 green:0.12 blue:0.13 alpha:1.0],
                        [NSColor colorWithCalibratedRed:0.72 green:0.73 blue:0.75 alpha:1.0], 4.0);

        [NSGraphicsContext restoreGraphicsState];

        NSData *png = [rep representationUsingType:NSPNGFileType properties:[NSDictionary dictionary]];
        [png writeToFile:outPath atomically:YES];
        finalImg = [[[NSImage alloc] initWithData:png] autorelease];
    } else {
        NSData *tiff = [finalImg TIFFRepresentation];
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:tiff];
        NSData *png = [rep representationUsingType:NSPNGFileType properties:[NSDictionary dictionary]];
        [png writeToFile:outPath atomically:YES];
    }

    if (finalImg && [appBundlePath length] > 0) {
        [[NSWorkspace sharedWorkspace] setIcon:finalImg forFile:appBundlePath options:0];
    }

    [pool drain];
    return 0;
}
'''
with open("/tmp/gen_skeuo_icon.m", "w") as f:
    f.write(skeuo_objc)
subprocess.run(["clang", "-Wno-deprecated-declarations", "/tmp/gen_skeuo_icon.m", "-framework", "Cocoa", "-o", "/tmp/gen_skeuo_icon"], check=True)

# 5. Info.plist 생성 (Music/iTunes 연동 권한 설명 추가)
plist_dict = {
    "CFBundleExecutable": "TypeGrapher",
    "CFBundleIconFile": "TypeGrapher.icns",
    "CFBundleIconName": "TypeGrapher",
    "CFBundleIdentifier": "com.soohyun.typegrapher",
    "CFBundleName": "TypeGrapher",
    "CFBundleDisplayName": "TypeGrapher",
    "CFBundlePackageType": "APPL",
    "CFBundleShortVersionString": "2.8",
    "CFBundleVersion": "11",
    "LSMinimumSystemVersion": "10.7",
    "NSHighResolutionCapable": True,
    "NSDocumentsFolderUsageDescription": "TypeGrapher가 파인더의 [문서 > TypeGrapher] 폴더 안에 마크다운(.md) 일기 및 노트를 저장하기 위해 접근 권한이 필요합니다.",
    "NSAppleEventsUsageDescription": "TypeGrapher가 현재 재생 중인 음악(Music/iTunes) 정보를 일기에 스탬프로 기록하기 위해 권한이 필요합니다."
}
with open(os.path.join(contents_dir, "Info.plist"), "wb") as fp:
    plistlib.dump(plist_dict, fp)

# 6. 아이콘 이미지 생성 후 TypeGrapher.icns 컴파일
subprocess.run(["/tmp/gen_skeuo_icon", master_png, app_path, found_user_png or ""], check=True)

for sz in [16, 32, 128, 256, 512]:
    subprocess.run(["sips", "-s", "format", "png", "-z", str(sz), str(sz), master_png, "--out", os.path.join(iconset_dir, f"icon_{sz}x{sz}.png")], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    subprocess.run(["sips", "-s", "format", "png", "-z", str(sz*2), str(sz*2), master_png, "--out", os.path.join(iconset_dir, f"icon_{sz}x{sz}@2x.png")], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

icns_target = os.path.join(res_dir, "TypeGrapher.icns")
subprocess.run(["iconutil", "-c", "icns", iconset_dir, "-o", icns_target], check=True)

# 7. 코드 서명 후 NSWorkspace 아이콘 리소스 포크 각인
subprocess.run(["xattr", "-cr", app_path], check=False)
subprocess.run(["codesign", "--force", "--deep", "--identifier", "com.soohyun.typegrapher", "--sign", "-", app_path], check=False)
subprocess.run(["/tmp/gen_skeuo_icon", master_png, app_path, found_user_png or ""], check=True)

# 8. 응용 프로그램(/Applications) 폴더 복사 및 캐시 갱신
if os.path.exists(installed_app):
    shutil.rmtree(installed_app)
subprocess.run(["ditto", app_path, installed_app], check=True)
subprocess.run(["/tmp/gen_skeuo_icon", master_png, installed_app, found_user_png or ""], check=True)

lsregister_bin = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if os.path.exists(lsregister_bin):
    subprocess.run([lsregister_bin, "-f", installed_app], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
subprocess.run(["touch", installed_app], check=False)

# 9. DMG 생성
os.symlink("/Applications", os.path.join(stage_dir, "Applications"))
subprocess.run([
    "hdiutil", "create", "-volname", "TypeGrapher",
    "-srcfolder", stage_dir, "-ov", "-format", "UDZO", "-fs", "HFS+", dmg_path
], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

subprocess.run(["/tmp/gen_skeuo_icon", master_png, dmg_path, found_user_png or ""], check=False)

shutil.rmtree(stage_dir)
print("✅ TypeGrapher 2.8 빌드 완료!")
subprocess.run(["open", installed_app])
PYEOF
python3 /tmp/build_typegrapher_v28.py