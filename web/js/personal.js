/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

function mostrarCamposExtra() {
    var selectTipo = document.getElementById("tipo");
    var divDentista = document.getElementById("seccion-dentista");
    var divSecretaria = document.getElementById("seccion-secretaria");

    if (!selectTipo || !divDentista || !divSecretaria) {
        return;
    }

    var tipo = selectTipo.value;

    // Ocultar ambos por defecto al cambiar
    divDentista.style.display = "none";
    divSecretaria.style.display = "none";

    // Mostrar según la opción seleccionada (1 = Admin, 2 = Dentista, 3 = Secretaria)
    if (tipo === "2") {
        divDentista.style.display = "block";
    } else if (tipo === "3") {
        divSecretaria.style.display = "block";
    }
}

function resetModalPassword() {
    var pasoConfirmar = document.getElementById("paso-confirmar-pass");
    var pasoForm = document.getElementById("paso-form-pass");
    var inputPass = document.getElementById("nuevaPassword");

    if (pasoConfirmar) {
        pasoConfirmar.style.display = "block";
    }
    if (pasoForm) {
        pasoForm.style.display = "none";
    }
    if (inputPass) {
        inputPass.required = false;
        inputPass.value = "";
    }
}

function confirmarNuevaPassword() {
    var pasoConfirmar = document.getElementById("paso-confirmar-pass");
    var pasoForm = document.getElementById("paso-form-pass");
    var inputPass = document.getElementById("nuevaPassword");
    var usr = document.getElementById("passUsuario") ? document.getElementById("passUsuario").value : "";
    var formTexto = document.getElementById("passUsuarioFormTexto");

    if (formTexto) {
        formTexto.textContent = usr;
    }
    if (pasoConfirmar) {
        pasoConfirmar.style.display = "none";
    }
    if (pasoForm) {
        pasoForm.style.display = "block";
    }
    if (inputPass) {
        inputPass.required = true;
        inputPass.focus();
    }
}

function abrirModalPassword(usuario) {
    var inputUsuario = document.getElementById("passUsuario");
    var textoUsuario = document.getElementById("passUsuarioTexto");
    var dlg = document.getElementById("modalPassword");

    resetModalPassword();

    if (inputUsuario) {
        inputUsuario.value = usuario;
    }
    if (textoUsuario) {
        textoUsuario.textContent = usuario;
    }
    if (dlg) {
        if (typeof dlg.showModal === "function") {
            if (!dlg.open) {
                dlg.showModal();
            }
        } else {
            dlg.setAttribute("open", "");
        }
    }
}

document.addEventListener("DOMContentLoaded", function () {
    mostrarCamposExtra();

    var dlgRegistro = document.getElementById("modalRegistro");
    if (dlgRegistro && dlgRegistro.hasAttribute("open") && typeof dlgRegistro.showModal === "function") {
        dlgRegistro.removeAttribute("open");
        dlgRegistro.showModal();
        mostrarCamposExtra();
    }
});