// app/javascript/controllers/appointment_controller.js
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['dateField', 'serviceField', 'timeSlots']

  connect() {
    console.log('Appointment controller connected')
  }

  formSubmitted(event) {
    console.log('Formulário enviado com sucesso')

    // Opcional: redirecionar ou mostrar uma mensagem de sucesso
    const successMessage =
      event.detail.fetchResponse.response.headers.get('X-Message')
    if (successMessage) {
      console.log('Mensagem de sucesso:', successMessage)
      // Aqui você pode atualizar a UI para mostrar a mensagem
    }
  }

  selectDate(event) {
    event.preventDefault()
    const date = event.currentTarget.dataset.date
    this.dateFieldTarget.value = date
    this.updateAvailableTimes()
  }

  dateChanged() {
    console.log('Data alterada:', this.dateFieldTarget.value)
    this.updateAvailableTimes()
  }

  serviceChanged() {
    console.log('Serviço alterado:', this.serviceFieldTarget.value)
    this.updateAvailableTimes()
  }

  updateAvailableTimes() {
    const date = this.dateFieldTarget.value
    const serviceId = this.serviceFieldTarget.value

    console.log('Atualizando horários para:', date, serviceId)

    if (date && serviceId) {
      const url = `/appointments/available_times?date=${date}&service_id=${serviceId}`
      console.log('Requesting:', url)

      fetch(url, {
        headers: {
          Accept: 'text/vnd.turbo-stream.html',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
        .then(response => {
          console.log('Resposta recebida:', response.status)
          return response.text()
        })
        .then(html => {
          console.log('HTML recebido:', html)
          Turbo.renderStreamMessage(html)
        })
        .catch(error => {
          console.error('Erro ao obter horários:', error)
        })
    }
  }
}
