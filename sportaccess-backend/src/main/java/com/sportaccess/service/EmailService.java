package com.sportaccess.service;

import com.sendgrid.Method;
import com.sendgrid.Request;
import com.sendgrid.Response;
import com.sendgrid.SendGrid;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Content;
import com.sendgrid.helpers.mail.objects.Email;
import com.sportaccess.model.Reservation;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.io.IOException;
import java.time.format.DateTimeFormatter;

@Service
public class EmailService {

    private final SendGrid sendGrid;
    private final TemplateEngine templateEngine;

    @Value("${sportaccess.mail.from}")
    private String fromEmail;

    public EmailService(SendGrid sendGrid, TemplateEngine templateEngine) {
        this.sendGrid = sendGrid;
        this.templateEngine = templateEngine;
    }

    public void sendReservationConfirmation(Reservation reservation) {
        // 1. Obtener el email de contacto de la reserva (el que escribió el usuario)
        String emailDestino = reservation.getEmailContacto();

        // 2. Si no hay email de contacto, usar el del usuario registrado como fallback
        if (emailDestino == null || emailDestino.isBlank()) {
            if (reservation.getUser() != null && reservation.getUser().getEmail() != null) {
                emailDestino = reservation.getUser().getEmail();
            } else {
                System.err.println("[EmailService] ERROR: No hay email disponible para la reserva ID=" + reservation.getId());
                return;
            }
        }

        // 3. Validar que no sea un email inventado de Firebase
        if (emailDestino.contains("@firebase.com")) {
            System.err.println("[EmailService] ERROR: Email inválido (generado automáticamente): " + emailDestino);
            return;
        }

        System.out.println("[EmailService] Enviando confirmación a: " + emailDestino);

        Email from = new Email(fromEmail, "SportAccess");
        String subject = "Confirmación de Reserva - SportAccess";
        Email to = new Email(emailDestino);

        Context context = new Context();
        context.setVariable("nombre", reservation.getUser() != null ? reservation.getUser().getNombre() : "Usuario");
        context.setVariable("pista", reservation.getCourt().getNombre());

        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

        context.setVariable("fecha", reservation.getFechaInicio().format(dateFormatter));
        context.setVariable("horaInicio", reservation.getFechaInicio().format(timeFormatter));
        context.setVariable("horaFin", reservation.getFechaFin().format(timeFormatter));
        context.setVariable("qrToken", reservation.getQrToken());

        String htmlContent = templateEngine.process("reservation-confirmation", context);
        Content content = new Content("text/html", htmlContent);
        Mail mail = new Mail(from, subject, to, content);

        Request request = new Request();
        try {
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());

            Response response = sendGrid.api(request);
            int statusCode = response.getStatusCode();

            if (statusCode >= 200 && statusCode < 300) {
                System.out.println("[EmailService] ✅ Correo enviado a " + emailDestino + " | Status: " + statusCode);
            } else {
                // ← ESTE ERA EL PROBLEMA SILENCIOSO: ahora ves el error real de SendGrid
                System.err.println("[EmailService] ❌ SendGrid rechazó el correo | Status: " + statusCode);
                System.err.println("[EmailService] Respuesta SendGrid: " + response.getBody());
            }
        } catch (IOException ex) {
            System.err.println("[EmailService] ❌ Excepción enviando correo: " + ex.getMessage());
        }
    }
}