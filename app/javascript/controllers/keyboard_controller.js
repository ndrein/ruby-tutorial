import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { dashboardUrl: String }

  connect() {
    this._pendingKey = null
    this._handleKeydown = this._onKeydown.bind(this)
    document.addEventListener("keydown", this._handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this._handleKeydown)
  }

  _onKeydown(event) {
    if (this._inputFocused()) return

    const key = event.key

    // g+d sequence: navigate to dashboard
    if (this._pendingKey === "g" && key === "d") {
      this._pendingKey = null
      const url = this.hasDashboardUrlValue ? this.dashboardUrlValue : "/progress"
      window.location.href = url
      return
    }

    if (key === "g") {
      this._pendingKey = "g"
      // Reset pending key after 1.5s if no follow-up
      clearTimeout(this._pendingTimeout)
      this._pendingTimeout = setTimeout(() => { this._pendingKey = null }, 1500)
      return
    }

    this._pendingKey = null

    const form = this.element.querySelector("form")
    if (!form) return

    switch (key) {
      case "Enter":
        form.requestSubmit()
        break
      case "Escape":
        this._skipExercise()
        break
      case "h":
        this._setHardFlag(true)
        form.requestSubmit()
        break
      case "e":
        this._setHardFlag(false)
        form.requestSubmit()
        break
    }
  }

  _inputFocused() {
    const active = document.activeElement
    if (!active) return false
    const tag = active.tagName.toLowerCase()
    return tag === "input" || tag === "textarea" || tag === "select" || active.isContentEditable
  }

  _setHardFlag(value) {
    const hardFlagInput = this.element.querySelector("input[name='hard_flag']")
    if (hardFlagInput) {
      hardFlagInput.value = value ? "true" : "false"
      // Uncheck/check the visible checkbox if present
      if (hardFlagInput.type === "checkbox") {
        hardFlagInput.checked = value
      }
    } else {
      // Inject hidden input if not present
      const hidden = document.createElement("input")
      hidden.type = "hidden"
      hidden.name = "hard_flag"
      hidden.value = value ? "true" : "false"
      const form = this.element.querySelector("form")
      if (form) form.appendChild(hidden)
    }
  }

  _skipExercise() {
    const form = this.element.querySelector("form")
    if (!form) return

    const resultInput = form.querySelector("input[name='answer_result']") || document.createElement("input")
    resultInput.type = "hidden"
    resultInput.name = "answer_result"
    resultInput.value = "skipped"
    form.appendChild(resultInput)

    form.requestSubmit()
  }
}
