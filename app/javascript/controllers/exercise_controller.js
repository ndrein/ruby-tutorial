import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["elapsedSeconds"]

  connect() {
    this._startTime = Date.now()
    this._updateElapsed = setInterval(() => this._tick(), 1000)
  }

  disconnect() {
    clearInterval(this._updateElapsed)
  }

  _tick() {
    const elapsed = Math.floor((Date.now() - this._startTime) / 1000)
    if (this.hasElapsedSecondsTarget) {
      this.elapsedSecondsTarget.value = elapsed
    }
  }
}
