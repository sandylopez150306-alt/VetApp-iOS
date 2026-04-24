import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func solicitarPermiso() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Notificaciones: \(granted ? "Permitidas" : "Denegadas")")
        }
    }
    
    func programarRecordatorio(citaId: String, mascotaNombre: String,
                               tipoServicio: String, fecha: Date) {
        let content = UNMutableNotificationContent()
        content.title = "🐾 Recordatorio de cita"
        content.body = "Mañana tienes cita de \(tipoServicio) para \(mascotaNombre). ¡No lo olvides!"
        content.sound = .default
        
        // Disparar 24 horas antes
        let fechaRecordatorio = fecha.addingTimeInterval(-86400)
        let componentes = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fechaRecordatorio)
        let trigger = UNCalendarNotificationTrigger(dateMatching: componentes, repeats: false)
        
        let request = UNNotificationRequest(identifier: citaId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelarRecordatorio(citaId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [citaId])
    }
}
