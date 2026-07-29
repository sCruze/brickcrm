import { Controller } from "@hotwired/stimulus"

// Плавный набор числа в стат-карточках. Уважает prefers-reduced-motion.
export default class extends Controller {
  static values = { to: Number, suffix: { type: String, default: "" } }

  connect() {
    const target = this.toValue
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches || target === 0) {
      this.render(target)
      return
    }

    const duration = 650
    const start = performance.now()
    const step = now => {
      const progress = Math.min((now - start) / duration, 1)
      const eased = 1 - Math.pow(1 - progress, 3)
      this.render(Math.round(target * eased))
      if (progress < 1) requestAnimationFrame(step)
    }
    requestAnimationFrame(step)
  }

  render(value) {
    this.element.textContent = new Intl.NumberFormat("ru-RU").format(value) + this.suffixValue
  }
}
