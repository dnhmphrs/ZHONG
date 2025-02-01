<script>
    import { signInUser, signInClinician } from '$lib/backend/api';
    import { goto } from '$app/navigation';

    let email = '';
    let password = '';
    let loading = false;
    let error = null;
    let isClinician = false;

    async function handleLogin() {
        try {
            loading = true;
            error = null;
            
            // Try to sign in based on user type
            const { data, error: authError } = isClinician 
                ? await signInClinician(email, password)
                : await signInUser(email, password);

            if (authError) throw authError;

            // Redirect based on user type
            if (isClinician) {
                goto('/clinician');
            } else {
                goto('/diary');
            }
        } catch (e) {
            error = e.message;
        } finally {
            loading = false;
        }
    }
</script>

<div class="login-container">
    <form on:submit|preventDefault={handleLogin} class="login-form">
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
                    bind:checked={isClinician}
                />
                Login as Clinician
            </label>
        </div>

        <button type="submit" disabled={loading}>
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
    }

    .login-form {
        width: 100%;
        max-width: 400px;
        padding: 2rem;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
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
        background-color: #4a90e2;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }

    button:disabled {
        background-color: #ccc;
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