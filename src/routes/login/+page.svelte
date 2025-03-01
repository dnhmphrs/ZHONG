<script>
    import { auth } from '$lib/store/auth';
    import { supabase } from '$lib/backend/supabase';
    import { goto } from '$app/navigation';

    let email = '';
    let password = '';
    let loading = false;
    let error = null;
    let clinicalView = false;
    let errorMessage = null;

    async function handleLogin(event) {
        event.preventDefault();
        try {
            loading = true;
            error = null;
            await auth.signIn(email, password, clinicalView);
        } catch (e) {
            error = e.message;
        } finally {
            loading = false;
        }
    }

    async function handleSignIn() {
        try {
            const { data, error } = await supabase.auth.signInWithPassword({
                email,
                password
            });
            if (error) throw error;
            
            goto('/home');
        } catch (error) {
            console.error('Error:', error.message);
            errorMessage = error.message;
        }
    }
</script>

<div class="login-container">
    <form on:submit={handleLogin} class="login-form">
        <h1>Login</h1>
        
        {#if error}
            <div class="error">{error}</div>
        {/if}

        <div class="form-group">
            <label for="email">Email</label>
            <input
                type="email"
                id="email" 
                bind:value={email}
                required
            />
        </div>
        
        <div class="form-group">
            <label for="password">Password</label>
            <input
                type="password"
                id="password" 
                bind:value={password}
                required
            />
        </div>

        <div class="form-group checkbox">
            <label>
                <input
                    type="checkbox"
                    bind:checked={clinicalView}
                />
                Login as Clinician
            </label>
        </div>

        <button class="primary" type="submit" disabled={loading}>
            {loading ? 'Loading...' : 'Login'}
        </button>
    </form>
</div>

<style>
    .login-container {
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        padding: 1rem;
    }

    .login-form {
        width: 100%;
        max-width: 400px;
        min-width: 240px;
        padding: 2rem;
        border-radius: 8px;
        background: var(--background-light);
        border: 1px solid var(--primary-50);
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }

    .login-form h1 {
        margin-bottom: 1.5rem;
        text-align: center;
    }

    .form-group {
        margin-bottom: 1rem;
    }

    .form-group label {
        display: block;
        margin-bottom: 0.5rem;
    }

    .form-group input {
        width: 100%;
        padding: 0.5rem;
        border: 1px solid #ddd;
        border-radius: 4px;
    }

    button {
        width: 100%;
        padding: 0.75rem;
        border-radius: 4px;
        cursor: pointer;
    }

    button:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .error {
        color: red;
        margin-bottom: 1rem;
    }

    .checkbox {
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }

    .checkbox input[type="checkbox"] {
        width: auto;
    }
</style> 