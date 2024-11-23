package RetroBank;

use DBI;
use YAML::Tiny;

# Read database configuration
my $config = YAML::Tiny->read('config.yml')->[0];
my $db_config = $config->{database};

# Connect to PostgreSQL database
my $dbh = DBI->connect(
    "dbi:Pg:host=$db_config->{host};port=$db_config->{port};dbname=$db_config->{dbname}",
    $db_config->{user}, $db_config->{password},
    { RaiseError => 1, AutoCommit => 1 }
) or die $DBI::errstr;

# Check user login
sub check_user {
    my ($username, $password) = @_;
    my $sth = $dbh->prepare("SELECT id FROM users WHERE username = ? AND password = ?");
    $sth->execute($username, $password);
    return $sth->fetchrow_array;
}

# Register new user
sub register_user {
    my ($username, $password) = @_;
    my $sth = $dbh->prepare("INSERT INTO users (username, password, balance) VALUES (?, ?, ?)");
    $sth->execute($username, $password, 0);
}

# Get user balance
sub get_balance {
    my ($username) = @_;
    my $sth = $dbh->prepare("SELECT balance FROM users WHERE username = ?");
    $sth->execute($username);
    my ($balance) = $sth->fetchrow_array;
    return $balance;
}

# Update user balance
sub update_balance {
    my ($username, $amount) = @_;
    my $sth = $dbh->prepare("UPDATE users SET balance = balance + ? WHERE username = ?");
    $sth->execute($amount, $username);
}

# Record transaction
sub record_transaction {
    my ($username, $type, $amount) = @_;
    my $sth = $dbh->prepare("INSERT INTO transactions (username, type, amount) VALUES (?, ?, ?)");
    $sth->execute($username, $type, $amount);
}

# Get transaction history
sub get_transactions {
    my ($username) = @_;
    my $sth = $dbh->prepare("SELECT type, amount, created_at FROM transactions WHERE username = ? ORDER BY created_at DESC");
    $sth->execute($username);
    return $sth->fetchall_arrayref({});
}

1;
