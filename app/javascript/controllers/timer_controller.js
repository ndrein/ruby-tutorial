import { Controller } from "@hotwired/stimulus"

const TOTAL_SECONDS = 30

export default class extends Controller {
  static targets = ["display"]
  static values = { submitUrl: String, csrfToken: String }

  connect() {
    this.remaining = TOTAL_SECONDS
    this.updateDisplay()
    this.interval = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  tick() {
    this.remaining -= 1
    this.updateDisplay()

    if (this.remaining <= 0) {
      clearInterval(this.interval)
      this.submitTimeout()
    }
  }

  updateDisplay() {
    const minutes = Math.floor(this.remaining / 60)
    const seconds = this.remaining % 60
    this.displayTarget.textContent = `${minutes}:${String(seconds).padStart(2, "0")}`
  }

  submitTimeout() {
    const form = document.createElement("form")
    form.method = "POST"
    form.action = this.submitUrlValue

    const csrfInput = document.createElement("input")
    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = this.csrfTokenValue

    const answerResultInput = document.createElement("input")
    answerResultInput.type = "hidden"
    answerResultInput.name = "answer_result"
    answerResultInput.value = "timeout"

    const elapsedInput = document.createElement("input")
    elapsedInput.type = "hidden"
    elapsedInput.name = "elapsed_seconds"
    elapsedInput.value = TOTAL_SECONDS

    const answerInput = document.createElement("input")
    answerInput.type = "hidden"
    answerInput.name = "answer"
    answerInput.value = ""

    const hardFlagInput = document.createElement("input")
    hardFlagInput.type = "hidden"
    hardFlagInput.name = "hard_flag"
    hardFlagInput.value = "false"

    form.append(csrfInput, answerResultInput, elapsedInput, answerInput, hardFlagInput)
    document.body.appendChild(form)
    form.submit()
  }
}
