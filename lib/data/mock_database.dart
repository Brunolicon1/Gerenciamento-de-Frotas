// Arquivo: lib/data/mock_database.dart

// 1. Definição simples dos perfis (Cargos)
enum UserRole {
  admin,      // Administrador
  manager,    // Gestor de Frota
  driver,     // Motorista
  requester,  // Solicitante
  auditor,    // Auditoria
}

// 2. Classe simples de Usuário (Só para funcionar agora)
class AppUser {
  final String id;
  final String name;
  final String login; // O login (ex: 'admin')
  final String password; // A senha (ex: 'admin')
  final UserRole role;

  AppUser({
    required this.id,
    required this.name,
    required this.login,
    required this.password,
    required this.role,
  });
}

// 3. O Banco de Dados Falso
class MockDatabase {

  // Lista de Usuários com Login e Senha iguais
  static final List<AppUser> _users = [
    // ADMINISTRADOR
    AppUser(
        id: '1',
        name: 'Administrador Geral',
        login: 'admin',
        password: 'admin',
        role: UserRole.admin
    ),

    // GESTOR DE FROTA
    AppUser(
        id: '2',
        name: 'Gestor Roberto',
        login: 'gestor',
        password: 'gestor',
        role: UserRole.manager
    ),

    // MOTORISTA
    AppUser(
        id: '3',
        name: 'Mot. Bruno Oliveira',
        login: 'motorista',
        password: 'motorista',
        role: UserRole.driver
    ),

    // SOLICITANTE
    AppUser(
        id: '4',
        name: 'Solicitante Ana',
        login: 'solicitante',
        password: 'solicitante',
        role: UserRole.requester
    ),

    // AUDITORIA
    AppUser(
        id: '5',
        name: 'Auditor Marcos',
        login: 'auditoria',
        password: 'auditoria',
        role: UserRole.auditor
    ),
  ];

  // Variável para saber quem está logado agora
  static AppUser? currentUser;

  // Função de Login (Verifica Usuário E Senha)
  static bool login(String loginInput, String passwordInput) {
    try {
      final user = _users.firstWhere(
              (u) => u.login == loginInput && u.password == passwordInput
      );
      currentUser = user;
      return true; // Sucesso
    } catch (e) {
      currentUser = null;
      return false; // Falha (Senha errada ou usuário não existe)
    }
  }

  // Função de Logout
  static void logout() {
    currentUser = null;
  }
}