/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

/*
 * Archivo: citas.js
 * Descripción: Apertura de los modales del módulo de citas (reagendar, cancelar y atender).
 * El cierre de los <dialog> (botón X, "Volver" y clic fuera) lo vincula modal-global.js.
 */

function abrirModalCitas(id) {
    var modal = document.getElementById(id);
    if (!modal) {
        return;
    }
    if (typeof modal.showModal === "function") {
        modal.showModal();
    } else {
        modal.setAttribute("open", "");
    }
}

function asignarValor(id, valor) {
    var el = document.getElementById(id);
    if (el) {
        el.value = valor;
    }
}

function asignarTexto(id, texto) {
    var el = document.getElementById(id);
    if (el) {
        el.textContent = texto;
    }
}

// Reagendar: precarga el folio y la fecha/hora actuales de la cita
function abrirModalReagendar(idCita, fecha, hora) {
    asignarValor("reIdCita", idCita);
    asignarTexto("reIdTexto", idCita);
    asignarValor("reFecha", fecha || "");
    asignarValor("reHora", hora || "");
    abrirModalCitas("modalReagendar");
}

// Cancelar: confirmación antes de mandar el folio al servlet
function abrirModalCancelar(idCita) {
    asignarValor("caIdCita", idCita);
    asignarTexto("caIdTexto", idCita);
    abrirModalCitas("modalCancelar");
}

// Atender (dentista): captura del diagnóstico
function abrirModalAtender(idCita) {
    asignarValor("atIdCita", idCita);
    asignarTexto("atIdTexto", idCita);
    asignarValor("atDiagnostico", "");
    abrirModalCitas("modalAtender");
}

// Fecha mínima = hoy en los campos que lo piden (data-fecha-min), con la hora local del navegador
document.addEventListener("DOMContentLoaded", function () {
    var hoy = new Date();
    var mes = ("0" + (hoy.getMonth() + 1)).slice(-2);
    var dia = ("0" + hoy.getDate()).slice(-2);
    var minimo = hoy.getFullYear() + "-" + mes + "-" + dia;

    document.querySelectorAll("input[data-fecha-min]").forEach(function (input) {
        input.min = minimo;
    });
    
    const btnPdf = document.querySelector(".btn-pdf");
if (btnPdf) {
    btnPdf.addEventListener("click", function (e) {
        const fecha = document.getElementById("fFecha")?.value || "";
        const idDentista = document.getElementById("fDoctor")?.value || "";
        const idPaciente = document.getElementById("fPaciente")?.value || "";

        const baseUrl = this.getAttribute("href").split("&fecha=")[0];
        this.setAttribute("href",
            `${baseUrl}&fecha=${encodeURIComponent(fecha)}&idDentista=${encodeURIComponent(idDentista)}&idPaciente=${encodeURIComponent(idPaciente)}`
        );
    });
}
});
