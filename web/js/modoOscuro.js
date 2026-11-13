/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener("DOMContentLoaded", function() {
    const btnModo = document.getElementById("btn-modo-oscuro");
    const body = document.body;
    const icono = btnModo ? btnModo.querySelector("span") : null;

    if (!btnModo) return;

    // 1. Revisar si hay preferencia guardada o la del sistema
    const modoGuardado = localStorage.getItem('modoOscuro');
    const prefiereOscuroSistema = window.matchMedia('(prefers-color-scheme: dark)').matches;

    if (modoGuardado === 'activo' || (!modoGuardado && prefiereOscuroSistema)) {
        body.classList.add('dark-mode');
        if (icono) {
            icono.classList.remove('fa-moon-o');
            icono.classList.add('fa-sun-o');
        }
    } else {
        body.classList.remove('dark-mode');
        if (icono) {
            icono.classList.remove('fa-sun-o');
            icono.classList.add('fa-moon-o');
        }
    }

    // 2. Al hacer clic en el botón
    btnModo.addEventListener("click", function() {
        body.classList.toggle('dark-mode');
        
        if (body.classList.contains('dark-mode')) {
            if (icono) {
                icono.classList.remove('fa-moon-o');
                icono.classList.add('fa-sun-o');
            }
            localStorage.setItem('modoOscuro', 'activo');
        } else {
            if (icono) {
                icono.classList.remove('fa-sun-o');
                icono.classList.add('fa-moon-o');
            }
            localStorage.setItem('modoOscuro', 'inactivo');
        }
    });
});