// Arquivo: lib/data/mock_database.dart

class Activity {
  final String id;
  final String title;       // Ex: Entrega Prioritária
  final String description; // Ex: Levar documentos sigilosos
  final String route;       // Ex: CD Logística -> Mercado Central
  final DateTime time;      // Data e Hora
  final String status;      // 'pendente', 'em_andamento', 'concluido'

  // Novos campos para a tela de detalhes
  final String vehicleModel; // Ex: Pajero Dakar
  final String vehiclePlate; // Ex: MXP-1234
  final List<String> team;   // Lista de passageiros/equipe

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.route,
    required this.time,
    required this.status,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.team,
  });
}


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

  static final List<Activity> activities = [
    // VIAGEM 1: A que está "Em Andamento" (Destaque)
    Activity(
      id: '101',
      title: 'Operação Madrugada',
      description: 'Transporte de equipe para operação de vigilância.',
      route: 'Delegacia Central -> Zona Norte',
      time: DateTime.now().add(const Duration(hours: 1)), // Daqui a 1h
      status: 'em_andamento',
      vehicleModel: 'Mitsubishi Pajero Dakar',
      vehiclePlate: 'MXP-9988',
      team: ['Del. Carlos Silva', 'Agente Souza', 'Perito Marcos'],
    ),

    // VIAGEM 2: Pendente
    Activity(
      id: '102',
      title: 'Transporte de Provas',
      description: 'Levar material apreendido para a perícia.',
      route: 'Delegacia -> Instituto de Criminalística',
      time: DateTime.now().add(const Duration(hours: 4)),
      status: 'pendente',
      vehicleModel: 'Renault Duster',
      vehiclePlate: 'TO-1234 (Reservada)',
      team: ['Escrivã Ana'],
    ),
  ];

// Mét0do para pegar viagens de hoje (Simulação)
  static List<Activity> getActivitiesForDate(DateTime date) {
// Na vida real filtraria por usuário também
    return activities;
  }
}