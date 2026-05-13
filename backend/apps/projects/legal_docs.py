import io
from django.utils import timezone
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from .models import CompanySettings

def generate_pdf(project, doc_type):
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter,
                            rightMargin=72, leftMargin=72,
                            topMargin=72, bottomMargin=18)
    
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(name='Justify', alignment=4))
    styles.add(ParagraphStyle(name='Right', alignment=2))
    
    company = CompanySettings.load()
    
    Story = []
    
    if doc_type == 'inicio':
        # Header
        Story.append(Paragraph(f"<b>Contrato No.:</b> {project.code}", styles["Right"]))
        Story.append(Paragraph(f"<b>Fecha:</b> {timezone.now().strftime('%d/%m/%Y')}", styles["Right"]))
        Story.append(Paragraph("<b>Lugar:</b> ____________, México", styles["Right"]))
        Story.append(Spacer(1, 24))
        
        # Partes
        dev_rep = project.developer_representative or company.representative_name or "Edgar Degante Aguilar"
        company_name = company.name or "Maewallis Corp"
        
        Story.append(Paragraph("<b>Partes</b>", styles["Heading2"]))
        Story.append(Paragraph(
            f"<b>De una parte, {company_name}</b>, en su carácter de proveedor de servicios de consultoría "
            "informática, desarrollo e implementación de sistemas de información, representada en este acto por "
            f"<b>{dev_rep}</b>, a quien en lo sucesivo se le denominará <b>\"EL DESARROLLADOR\"</b>.", 
            styles["Justify"]
        ))
        Story.append(Spacer(1, 12))
        
        cliente_nombre = project.client_name or (project.sponsor.get_full_name() if project.sponsor else "[Nombre de la Empresa o Cliente]")
        cliente_rep = project.client_representative or "[Nombre del representante legal o apoderado]"
        
        Story.append(Paragraph(
            f"<b>Y de la otra, {cliente_nombre}</b>, representada por <b>{cliente_rep}</b>, "
            f"a quien en lo sucesivo se le denominará <b>\"EL CLIENTE\"</b>.", 
            styles["Justify"]
        ))
        Story.append(Spacer(1, 12))
        
        Story.append(Paragraph(
            "Ambas partes reconocen su capacidad legal para obligarse y convienen celebrar el presente "
            "<b>CONTRATO DE DESARROLLO ÁGIL DE SOFTWARE</b>, al tenor de las siguientes declaraciones y cláusulas.", 
            styles["Justify"]
        ))
        Story.append(Spacer(1, 24))
        
        # Declaraciones
        Story.append(Paragraph("<b>Declaraciones</b>", styles["Heading2"]))
        Story.append(Paragraph("<b>Declara EL DESARROLLADOR</b>", styles["Heading3"]))
        Story.append(Paragraph("• Que es una entidad con capacidad técnica, operativa y profesional para prestar servicios de desarrollo de software y consultoría tecnológica.", styles["Justify"]))
        Story.append(Paragraph("• Que cuenta con personal calificado para ejecutar proyectos bajo enfoques iterativos e incrementales, incluyendo marcos de trabajo como Scrum o Kanban.", styles["Justify"]))
        Story.append(Paragraph("• Que dispone de metodologías para documentar entregables, gestionar cambios y controlar la calidad del software entregado.", styles["Justify"]))
        Story.append(Spacer(1, 12))
        
        Story.append(Paragraph("<b>Declara EL CLIENTE</b>", styles["Heading3"]))
        Story.append(Paragraph("• Que requiere el desarrollo de una solución tecnológica adaptable a prioridades cambiantes y validación continua de valor de negocio.", styles["Justify"]))
        Story.append(Paragraph("• Que designará responsables con facultades para priorizar requerimientos, revisar entregables y aprobar incrementos de producto durante el proyecto.", styles["Justify"]))
        Story.append(Paragraph("• Que cuenta con interés legítimo en contratar servicios especializados de desarrollo ágil conforme a los términos de este instrumento.", styles["Justify"]))
        Story.append(Spacer(1, 24))
        
        # Cláusulas
        Story.append(Paragraph("<b>Cláusulas</b>", styles["Heading2"]))
        
        clausulas = [
            ("Primera. Objeto del contrato", f"EL DESARROLLADOR se obliga a prestar a EL CLIENTE servicios de análisis, diseño, construcción, pruebas, integración, documentación e implementación de una solución de software denominada <b>{project.name}</b>, mediante un esquema de desarrollo ágil, iterativo e incremental.<br/><br/>El producto a desarrollar deberá orientarse a los objetivos de negocio, alcance funcional inicial, restricciones técnicas, integraciones, requisitos no funcionales y criterios de valor definidos en el Anexo A (Visión del Producto y Alcance Inicial)."),
            ("Segunda. Naturaleza ágil del servicio", "Las partes reconocen que el proyecto será ejecutado bajo un enfoque ágil, por lo que el detalle funcional podrá evolucionar durante el desarrollo conforme a prioridades de negocio, backlog del producto, retroalimentación de usuarios y capacidad del equipo.<br/><br/>En consecuencia, este contrato regula una colaboración continua basada en entregas parciales, validación frecuente de incrementos y gestión formal de cambios, sin que ello implique indefinición absoluta del alcance."),
            ("Tercera. Definiciones operativas", "Para efectos del presente contrato, se entenderá por:<br/>• <b>Product Backlog:</b> lista priorizada de requerimientos, historias de usuario, mejoras, incidencias y tareas del producto.<br/>• <b>Sprint o Iteración:</b> período fijo de trabajo en el que se construye un incremento potencialmente utilizable del software.<br/>• <b>Incremento:</b> resultado funcional entregado al cierre de una iteración y sujeto a revisión por EL CLIENTE.<br/>• <b>Definition of Done:</b> criterios mínimos técnicos y funcionales que debe cumplir un elemento para considerarse terminado.<br/>• <b>Orden de Cambio:</b> documento formal mediante el cual se aprueban ajustes relevantes en alcance, costo, plazo o prioridades contractuales."),
            ("Cuarta. Documentos contractuales", "Forman parte integral del presente contrato, en el siguiente orden de prelación:<br/>1. El cuerpo principal del contrato.<br/>2. Anexo A: Visión del Producto y Alcance Inicial.<br/>3. Anexo B: Backlog inicial priorizado.<br/>4. Anexo C: Definición de Hecho (Definition of Done) y criterios de aceptación.<br/>5. Anexo D: Plan de entregas, calendario de sprints y gobernanza.<br/>6. Anexo E: Tarifas, esquema económico y reglas de facturación.<br/>7. Anexo F: Política de seguridad, confidencialidad y tratamiento de información."),
            ("Quinta. Roles y responsabilidades", "<b>Responsabilidades de EL CLIENTE</b><br/>• Nombrar un Product Owner o responsable funcional.<br/>• Proveer información, accesos y reglas de negocio.<br/>• Participar en reuniones de planificación y revisión.<br/>• Revisar oportunamente los incrementos.<br/><br/><b>Responsabilidades de EL DESARROLLADOR</b><br/>• Asignar un equipo competente.<br/>• Desarrollar el software conforme a estándares.<br/>• Mantener actualizada la documentación técnica mínima.<br/>• Informar riesgos y dependencias."),
            ("Sexta. Equipo de trabajo y dedicación", "Las partes podrán acordar la composición inicial del equipo de desarrollo, incluyendo perfiles como Scrum Master o líder de proyecto, desarrolladores, QA, UX/UI, DevOps o analista funcional, según la naturaleza del proyecto.<br/><br/>Salvo pacto en contrario, EL DESARROLLADOR podrá realizar sustituciones razonables de personal por causas operativas, siempre que preserve el nivel de competencia y continuidad del servicio."),
            ("Séptima. Metodología de ejecución", "El desarrollo se realizará en iteraciones, con ceremonias o eventos de seguimiento que podrán incluir planificación de sprint, sesiones de refinamiento, reuniones breves de avance, revisión de sprint y retrospectiva.<br/><br/>Cada iteración concluirá con la entrega de uno o más incrementos funcionales, acompañados de evidencia mínima de avance."),
            ("Octava. Alcance y backlog inicial", "El alcance inicial del proyecto se describe en términos de objetivos, épicas, módulos, procesos, integraciones, restricciones y prioridades de negocio, sin perjuicio de que el contenido detallado del backlog pueda ajustarse durante el proyecto.<br/><br/>Las partes reconocen que en un proyecto ágil la prioridad puede cambiar sin alterar necesariamente el presupuesto total, siempre que se mantenga la capacidad acordada o el número de iteraciones contratadas."),
            ("Novena. Gestión de cambios", "Los cambios de prioridad ordinarios dentro del backlog podrán realizarse durante las sesiones de refinamiento o planificación, siempre que no afecten de manera sustancial el costo total, la capacidad comprometida o la fecha objetivo de entrega.<br/><br/>Cualquier cambio que implique ampliar alcance, modificar arquitectura base, incorporar integraciones no previstas, alterar plazos globales o incrementar dedicación del equipo deberá documentarse mediante una Orden de Cambio aprobada por ambas partes."),
            ("Décima. Entregables", "EL DESARROLLADOR entregará, según aplique al proyecto:<br/>• Incrementos funcionales del software al cierre de cada sprint.<br/>• Código fuente en repositorio controlado.<br/>• Scripts, configuraciones y componentes necesarios para despliegue.<br/>• Documentación técnica mínima viable.<br/>• Manuales de usuario, si se pactan expresamente."),
            ("Décima primera. Criterios de aceptación", "Cada historia de usuario, tarea o incremento deberá cumplir la Definition of Done y los criterios de aceptación previamente definidos para ser presentado a revisión.<br/><br/>EL CLIENTE contará con un plazo de [3 a 10 días hábiles] posteriores a cada revisión para aceptar el incremento o formular observaciones."),
            ("Décima segunda. Precio y esquema económico", "Las partes podrán adoptar cualquiera de las siguientes modalidades económicas:<br/>• Bolsa de horas o capacidad por sprint.<br/>• Precio por iteración.<br/>• Modelo híbrido.<br/>El detalle aplicable al presente proyecto se establecerá en el Anexo E."),
            ("Décima tercera. Facturación y pagos", "EL DESARROLLADOR emitirá las facturas conforme al esquema pactado.<br/><br/>EL CLIENTE deberá pagar cada factura dentro de los [número] días naturales siguientes a su recepción. El retraso en los pagos podrá facultar a EL DESARROLLADOR para suspender temporalmente trabajos no críticos."),
            ("Décima cuarta. Colaboración y gobernanza", "Las partes mantendrán un modelo de colaboración activa, con canales definidos para toma de decisiones, seguimiento de impedimentos, escalación de riesgos y aprobación de cambios relevantes."),
            ("Décima quinta. Herramientas y repositorios", "El proyecto podrá administrarse mediante herramientas colaborativas para backlog, incidencias, documentación, control de versiones, pruebas y despliegue continuo, según acuerden las partes.<br/><br/>Salvo estipulación en contrario, EL CLIENTE tendrá acceso de lectura al repositorio de código."),
            ("Décima sexta. Propiedad intelectual", "La regulación de la propiedad intelectual deberá distinguir entre: a) componentes preexistentes de EL DESARROLLADOR, b) componentes de terceros sujetos a licencia, y c) desarrollos específicos creados para EL CLIENTE.<br/><br/>Salvo pacto distinto, los desarrollos específicos pagados por EL CLIENTE serán cedidos o licenciados en los términos del anexo correspondiente."),
            ("Décima séptima. Licencias de terceros y open source", "Cuando el proyecto utilice librerías, frameworks o componentes de terceros, su uso quedará sujeto a las condiciones de las licencias respectivas.<br/><br/>EL DESARROLLADOR informará, cuando sea relevante, qué componentes de terceros integran la solución."),
            ("Décima octava. Confidencialidad", "Toda información técnica, operativa, comercial, financiera o estratégica intercambiada entre las partes tendrá carácter confidencial y no podrá divulgarse a terceros sin autorización previa y por escrito, salvo obligación legal."),
            ("Décima novena. Protección de datos y seguridad", "Si el proyecto involucra datos personales, accesos a sistemas críticos o información sensible, las partes deberán pactar medidas mínimas de seguridad, controles de acceso, respaldo, segregación de ambientes y protocolos de respuesta ante incidentes."),
            ("Vigésima. Garantía", "EL DESARROLLADOR otorgará una garantía limitada por un plazo de [30 a 90 días] a partir de la aceptación de cada release o de la puesta en producción, exclusivamente para corregir defectos reproducibles atribuibles al desarrollo realizado y contrarios a las especificaciones o criterios de aceptación acordados."),
            ("Vigésima primera. Niveles de servicio posteriores", "El soporte evolutivo, mantenimiento correctivo posterior a la garantía, monitoreo, operación continua o niveles de servicio en producción no se entenderán incluidos, salvo que se pacten expresamente en un anexo o contrato complementario."),
            ("Vigésima segunda. Limitación de responsabilidad", "La responsabilidad total de EL DESARROLLADOR por reclamaciones derivadas del presente contrato podrá limitarse al monto efectivamente pagado por EL CLIENTE durante los [3, 6 o 12 meses] previos al hecho generador, salvo dolo, mala fe o supuestos no limitables por ley."),
            ("Vigésima tercera. Suspensión y dependencias", "Cuando EL CLIENTE no entregue información crítica, no atienda validaciones indispensables o incumpla pagos vencidos, EL DESARROLLADOR podrá reprogramar iteraciones, suspender actividades afectadas o ajustar el cronograma, sin responsabilidad por demoras imputables a tales causas."),
            ("Vigésima cuarta. Terminación anticipada", "El contrato podrá darse por terminado anticipadamente por:<br/>• Mutuo acuerdo por escrito.<br/>• Incumplimiento grave de alguna de las partes.<br/>• Imposibilidad material o jurídica.<br/>• Conveniencia del negocio."),
            ("Vigésima quinta. Entrega al cierre o terminación", "En caso de terminación, EL DESARROLLADOR entregará a EL CLIENTE, conforme al grado de avance pagado, los incrementos desarrollados, código disponible, documentación existente y materiales transferibles que formen parte del proyecto."),
            ("Vigésima sexta. No captación de personal", "Durante la vigencia del contrato y por [6 a 12 meses] posteriores a su terminación, ninguna parte podrá contratar directamente personal clave asignado por la otra al proyecto sin autorización escrita, salvo pacto distinto."),
            ("Vigésima séptima. Fuerza mayor", "Ninguna de las partes será responsable por incumplimientos derivados de eventos de fuerza mayor o caso fortuito que impidan temporal o definitivamente la ejecución de sus obligaciones, siempre que se notifique oportunamente a la otra parte."),
            ("Vigésima octava. Ley aplicable y jurisdicción", "El presente contrato se regirá por las leyes de los Estados Unidos Mexicanos. Para la interpretación y cumplimiento del mismo, las partes se someten a la jurisdicción de los tribunales competentes de la Ciudad de México, renunciando a cualquier otro fuero que pudiera corresponderles por razón de sus domicilios presentes o futuros.")
        ]
        
        for titulo, contenido in clausulas:
            Story.append(Paragraph(f"<b>{titulo}</b>", styles["Heading3"]))
            Story.append(Paragraph(contenido, styles["Justify"]))
            Story.append(Spacer(1, 12))
            
        Story.append(Spacer(1, 24))
        
        # Firmas
        Story.append(Paragraph("<b>Firmas</b>", styles["Heading2"]))
        Story.append(Paragraph("Leído que fue el presente contrato y enteradas las partes de su contenido y alcance legal, lo firman por duplicado en la fecha y lugar indicados al inicio.", styles["Justify"]))
        Story.append(Spacer(1, 48))
        
        Story.append(Paragraph("<b>EL DESARROLLADOR</b>", styles["Normal"]))
        Story.append(Paragraph(company_name, styles["Normal"]))
        Story.append(Paragraph(f"Nombre: {dev_rep}", styles["Normal"]))
        Story.append(Paragraph("Cargo: Representante Legal", styles["Normal"]))
        Story.append(Paragraph("Firma: ___________________________", styles["Normal"]))
        
        Story.append(Spacer(1, 36))
        
        Story.append(Paragraph("<b>EL CLIENTE</b>", styles["Normal"]))
        Story.append(Paragraph(cliente_nombre, styles["Normal"]))
        Story.append(Paragraph(f"Nombre: {cliente_rep}", styles["Normal"]))
        Story.append(Paragraph("Cargo: Representante Legal", styles["Normal"]))
        Story.append(Paragraph("Firma: ___________________________", styles["Normal"]))
        
        Story.append(Spacer(1, 24))
        
        # Anexos
        Story.append(Paragraph("<b>Anexos sugeridos</b>", styles["Heading2"]))
        anexos = [
            "<b>Anexo A.</b> Visión del producto, objetivos de negocio y alcance inicial.",
            "<b>Anexo B.</b> Backlog inicial con épicas, historias de usuario y prioridades.",
            "<b>Anexo C.</b> Definition of Done, criterios de aceptación y estrategia de pruebas.",
            "<b>Anexo D.</b> Calendario de sprints, gobernanza, reuniones y responsables.",
            "<b>Anexo E.</b> Tarifas, capacidad comprometida, forma de facturación y pagos.",
            "<b>Anexo F.</b> Orden de cambio tipo.",
            "<b>Anexo G.</b> Acuerdo de confidencialidad y seguridad de la información."
        ]
        for anexo in anexos:
            Story.append(Paragraph(f"• {anexo}", styles["Justify"]))
            
    elif doc_type == 'modificacion':
        Story.append(Paragraph("<b>DOCUMENTO DE MODIFICACIÓN DE PROYECTO</b>", styles["Heading1"]))
        Story.append(Spacer(1, 12))
        Story.append(Paragraph(f"<b>Proyecto:</b> {project.name}", styles["Normal"]))
        Story.append(Paragraph(f"<b>Código:</b> {project.code}", styles["Normal"]))
        Story.append(Paragraph(f"<b>Fecha de Generación:</b> {timezone.now().strftime('%Y-%m-%d')}", styles["Normal"]))
        Story.append(Spacer(1, 24))
        Story.append(Paragraph("Sección de modificaciones (A completar por el director del proyecto).", styles["Normal"]))
        
    elif doc_type == 'bitacora':
        Story.append(Paragraph("<b>BITÁCORA DEL PROYECTO</b>", styles["Heading1"]))
        Story.append(Spacer(1, 12))
        Story.append(Paragraph(f"<b>Proyecto:</b> {project.name}", styles["Normal"]))
        Story.append(Paragraph(f"<b>Código:</b> {project.code}", styles["Normal"]))
        Story.append(Spacer(1, 24))
        Story.append(Paragraph("<b>Eventos Registrados (Cambios recientes):</b>", styles["Heading2"]))
        
        for change in project.changes.all()[:15]:
            Story.append(Paragraph(f"• {change.request_date}: {change.title} ({change.status})", styles["Normal"]))
            Story.append(Spacer(1, 6))

    doc.build(Story)
    buffer.seek(0)
    return buffer
