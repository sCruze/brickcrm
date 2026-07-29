import { Controller } from "@hotwired/stimulus"

// Модалка дня в календаре: список задач этого дня + быстрое создание задачи.
export default class extends Controller {
  static targets = ["dialog", "title", "date", "list", "input"]

  open(event) {
    if (event.target.closest("a")) return   // клик по задаче — обычный переход

    const cell = event.currentTarget
    this.titleTarget.textContent = cell.dataset.label
    if (this.hasDateTarget) this.dateTarget.value = cell.dataset.date

    this.listTarget.innerHTML = ""
    cell.querySelectorAll("[data-task-title]").forEach(link => {
      const item = document.createElement("a")
      item.href = link.href
      item.className = "modal__task"
      item.textContent = link.dataset.taskTitle
      this.listTarget.appendChild(item)
    })
    if (this.listTarget.children.length === 0) {
      const empty = document.createElement("p")
      empty.className = "muted"
      empty.textContent = "Задач на этот день нет."
      this.listTarget.appendChild(empty)
    }

    this.dialogTarget.showModal()
    if (this.hasInputTarget) this.inputTarget.focus()
  }

  backdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  close() {
    this.dialogTarget.close()
  }
}
