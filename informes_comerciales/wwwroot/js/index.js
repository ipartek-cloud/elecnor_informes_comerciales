import { GlobalUI, ApiClient, decodeJwt } from './site.js';
// Script principal asociado a la vista Home/Index.cshtml

document.addEventListener("DOMContentLoaded", function () {

    // Establecer mes por defecto (mes anterior, excepto en enero que se mantiene enero)
    const txtMes = document.getElementById('txtMes');
    if (txtMes) {
        const now = new Date();
        const currentMonth = now.getMonth() + 1; // 1-12
        txtMes.value = currentMonth === 1 ? 1 : currentMonth - 1;
    }

    // Verificar si ya hay credenciales
    const isLogged = !!sessionStorage.getItem('jwt_token');
    initUI(isLogged);

    // Mostrar alerta de bienvenida si se acaba de loguear y se ha recargado la página
    if (isLogged && sessionStorage.getItem('mostrar_bienvenida') === '1') {
        sessionStorage.removeItem('mostrar_bienvenida');
        const nombre = sessionStorage.getItem('jwt_NombreUsuario') || 'Usuario';
        GlobalUI.showAlert(`Bienvenido, ${nombre}.`, 'success', 'Login OK');
    }

    // Bindeo Submit Login
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', async function (e) {
            e.preventDefault();

            let username = document.getElementById('txtUser').value.trim();
            let password = document.getElementById('txtPassword').value;
            const payload = { Username: username, Password: password };

            // Limpiar mensaje de error previo
            const errMsg = document.getElementById('loginErrorMsg');
            errMsg.textContent = '';
            errMsg.classList.add('d-none');

            GlobalUI.showLoading("Autenticando...");

            try {
                const resp = await ApiClient.post('/api/Login', payload, false);

                if (resp.ok) {
                    const data = await resp.json();
                    
                    // Limpieza preventiva del sessionStorage para evitar residuos de cuentas anteriores
                    sessionStorage.clear();
                    sessionStorage.setItem('jwt_token', data.token);

                    // Decodificar y almacenar claims
                    const jwtPayload = decodeJwt(data.token);
                    if (jwtPayload) {
                        sessionStorage.setItem('jwt_Usuario', jwtPayload.nameid);
                        sessionStorage.setItem('jwt_NombreUsuario', jwtPayload.NombreUsuario);
                        sessionStorage.setItem('jwt_Puesto', jwtPayload.Puesto);
                        sessionStorage.setItem('jwt_CodEntidad', jwtPayload.CodEntidad);
                        sessionStorage.setItem('jwt_InformesPermitidos', jwtPayload.InformesPermitidos || '');
                        // Registrar bandera para mostrar la alerta de bienvenida tras la recarga
                        sessionStorage.setItem('mostrar_bienvenida', '1');
                    }

                    // Forzar recarga completa de la página desde el servidor para refrescar estáticos
                    window.location.reload();
                } else {
                    const dataError = await resp.json();
                    errMsg.textContent = dataError.message || "Credenciales incorrectas.";
                    errMsg.classList.remove('d-none');
                }
            } catch (ex) {
                console.error("Error Login", ex);
                errMsg.textContent = "Error de conexión con el servidor.";
                errMsg.classList.remove('d-none');
            } finally {
                GlobalUI.hideLoading();
            }
        });
    }

    // Toggle visibilidad contraseña
    const togglePassword = document.getElementById('togglePassword');
    const passwordInput  = document.getElementById('txtPassword');
    if (togglePassword && passwordInput) {
        togglePassword.addEventListener('click', function () {
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);

            // Cambiar icono
            this.classList.toggle('fa-eye');
            this.classList.toggle('fa-eye-slash');
        });
    }

    // Salir / Logout
    const btnLogout = document.getElementById('btnLogout');
    if (btnLogout) {
        btnLogout.addEventListener('click', async function () {
            const confirmed = await GlobalUI.showConfirm('¿Desea cerrar la sesión?', 'Confirmar');
            if (!confirmed) return;

            sessionStorage.clear();
            window.location.reload();
        });
    }

    // ---- Control visual ----
    function initUI(logged) {
        const modalEl = document.getElementById('formLogin');
        const userInfoNav = document.querySelector('.user-info-header');
        const mainContent = document.getElementById('mainContent');
        const lblNombre = document.getElementById('lblNombreUsuario');

        if (logged) {
            // Ocultar modal si existe
            if (modalEl) {
                const bsModal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                bsModal.hide();
            }

            // Mostrar info usuario en header
            if (userInfoNav) {
                userInfoNav.classList.remove('d-none');
                userInfoNav.classList.add('d-flex');
            }
            if (mainContent) mainContent.classList.remove('d-none');

            if (lblNombre) {
                const nombre = sessionStorage.getItem('jwt_NombreUsuario') || 'Usuario';
                const puesto = sessionStorage.getItem('jwt_Puesto') || '';
                lblNombre.textContent = `${nombre} (${puesto})`;
            }
            
            if (typeof window.aplicarSeguridadPorPuesto === 'function') {
                window.aplicarSeguridadPorPuesto();
            }

            // Restringir pestaña "Opciones de Generación" solo a usuarios autorizados
            const token = sessionStorage.getItem('jwt_token');
            const payload = token ? decodeJwt(token) : null;
            const usuario = (payload?.sub || '').toLowerCase();
            if (!['annruiz', 'ipartek'].includes(usuario)) {
                document.getElementById('opciones-tab')?.closest('.nav-item')?.remove();
                document.getElementById('opciones-pane')?.remove();
            }
        } else {
            // Mostrar modal de login
            if (modalEl) {
                const bsModal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                bsModal.show();
            }

            // Ocultar elementos privados
            if (userInfoNav) {
                userInfoNav.classList.add('d-none');
                userInfoNav.classList.remove('d-flex');
            }
            if (mainContent) mainContent.classList.add('d-none');
        }
    }

    // ---- Manejo del Modal de Informes ----
    const modalInforme = document.getElementById('modalInforme');
    if (modalInforme) {
        modalInforme.addEventListener('hidden.bs.modal', function () {
            // 1. Limpiar CSS inyectado para evitar colisiones de estilos
            if (typeof window.limpiarCssInformes === 'function') {
                window.limpiarCssInformes();
            }
            // 2. Limpiar contenido HTML para liberar memoria y resetear estado visual
            const contenido = document.getElementById('modalInformeContenido');
            if (contenido) {
                contenido.innerHTML = `
                    <div class="d-flex justify-content-center align-items-center h-100">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Cargando...</span>
                        </div>
                    </div>`;
            }
        });
    }

});


