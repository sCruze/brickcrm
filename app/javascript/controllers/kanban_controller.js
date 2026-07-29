import { Controller } from "@hotwired/stimulus"

// Drag&drop карточек по колонкам доски. PATCH /leads/:id/move { stage_id }.
// При ошибке сети/прав — перезагрузка страницы, чтобы не разъехаться с сервером.
export default class extends Controller {
  static values = { url: String }

  dragstart(event) {
    const card = event.target.closest("[data-lead-id]")
    if (!card) return
    event.dataTransfer.setData("text/plain", card.dataset.leadId)
    event.dataTransfer.effectAllowed = "move"
    requestAnimationFrame(() => card.classList.add("is-dragging"))
    this.dragged = card
  }

  dragend() {
    this.dragged?.classList.remove("is-dragging")
    this.element.querySelectorAll(".board-col--over").forEach(c => c.classList.remove("board-col--over"))
  }

  dragover(event) {
    const column = event.target.closest("[data-stage-id]")
    if (!column) return
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    column.classList.add("board-col--over")
  }

  dragleave(event) {
    const column = event.target.closest("[data-stage-id]")
    if (column && !column.contains(event.relatedTarget)) column.classList.remove("board-col--over")
  }

  drop(event) {
    const column = event.target.closest("[data-stage-id]")
    if (!column) return
    event.preventDefault()
    column.classList.remove("board-col--over")

    const id = event.dataTransfer.getData("text/plain")
    const card = this.element.querySelector(`[data-lead-id="${id}"]`)
    if (!card) return

    const fromColumn = card.closest("[data-stage-id]")
    column.querySelector("[data-cards]").appendChild(card)
    this.recalc(fromColumn)
    this.recalc(column)

    fetch(this.urlValue.replace(":id", id), {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content,
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify({ stage_id: column.dataset.stageId })
    }).then(response => { if (!response.ok) window.location.reload() })
      .catch(() => window.location.reload())
  }

  recalc(column) {
    if (!column) return
    const cards = column.querySelectorAll("[data-lead-id]")
    const count = column.querySelector("[data-count]")
    if (count) count.textContent = cards.length

    const sumTarget = column.querySelector("[data-sum]")
    if (sumTarget) {
      let sum = 0
      cards.forEach(c => { sum += Number(c.dataset.amount || 0) })
      sumTarget.textContent = sum > 0 ? new Intl.NumberFormat("ru-RU").format(sum) + " ₽" : ""
    }
  }
}
