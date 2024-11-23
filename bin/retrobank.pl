use Dancer2;
use lib './lib';
use RetroBank;
use Template;

# Define route for index page
get '/' => sub {
    my $user = session('user');
    return template 'index.tt', { username => $user };
};

# Define route for login page
get '/login' => sub {
    return template 'login.tt';
};

# Define route for login submission
post '/login' => sub {
    my $username = param('username');
    my $password = param('password');
    
    if (RetroBank::check_user($username, $password)) {
        session user => $username;
        redirect '/dashboard';
    } else {
        return "Invalid login!";
    }
};

# Define route for registration page
get '/register' => sub {
    return template 'register.tt';
};

# Define route for registration submission
post '/register' => sub {
    my $username = param('username');
    my $password = param('password');
    
    RetroBank::register_user($username, $password);
    return "Registration successful! <a href='/login'>Login</a>";
};

# Define route for dashboard (user home page)
get '/dashboard' => sub {
    my $user = session('user');

    if (!$user) {
        redirect '/login';
    }

    # Fetch the user's balance
    my $balance = RetroBank::get_balance($user);

    return template 'dashboard.tt', { username => $user, balance => $balance };
};

# Route to display user balance (under /dashboard)
get '/dashboard/balance' => sub {
    my $user = session('user');
    if (!$user) {
        redirect '/login';
    }
    my $balance = RetroBank::get_balance($user);
    return template 'balance.tt', { username => $user, balance => $balance };
};

# Route to add money (under /dashboard)
post '/dashboard/add_money' => sub {
    my $user = session('user');
    if (!$user) {
        redirect '/login';
    }
    my $amount = param('amount');
    RetroBank::update_balance($user, $amount);
    RetroBank::record_transaction($user, 'Deposit', $amount);
    redirect '/dashboard/balance';
};

# Route to display transaction history (under /dashboard)
get '/dashboard/transactions' => sub {
    my $user = session('user');
    if (!$user) {
        redirect '/login';
    }
    my $transactions = RetroBank::get_transactions($user);
    return template 'transactions.tt', { username => $user, transactions => $transactions };
};

# Start the app
start;
