import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UnauthorizedException,
  HttpStatus,
  HttpCode,
} from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { Role } from '@prisma/client';

@Controller('api')
export class ApiController {
  constructor(private readonly prisma: PrismaService) {}

  // 1. Auth Login
  @Post('auth/login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() body: any) {
    const { email, password } = body;
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user || user.password !== password) {
      throw new UnauthorizedException('Email atau password tidak valid.');
    }

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role.toLowerCase(), // frontend expects lowercase: 'operator' | 'superadmin'
        status: user.status,
      },
    };
  }

  // 2. Users (Operator Management)
  @Get('users')
  async getUsers() {
    return this.prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  @Post('users')
  async createUser(@Body() body: any) {
    return this.prisma.user.create({
      data: {
        name: body.name,
        email: body.email,
        password: body.password || 'operator123',
        role: body.role === 'superadmin' ? Role.SUPERADMIN : Role.OPERATOR,
        status: body.status || 'Active',
      },
    });
  }

  @Put('users/:id')
  async updateUser(@Param('id') id: string, @Body() body: any) {
    const updateData: any = {};
    if (body.name !== undefined) updateData.name = body.name;
    if (body.email !== undefined) updateData.email = body.email;
    if (body.password !== undefined) updateData.password = body.password;
    if (body.role !== undefined)
      updateData.role =
        body.role === 'superadmin' ? Role.SUPERADMIN : Role.OPERATOR;
    if (body.status !== undefined) updateData.status = body.status;
    if (body.lastLogin !== undefined) updateData.lastLogin = body.lastLogin;

    return this.prisma.user.update({
      where: { id },
      data: updateData,
    });
  }

  @Delete('users/:id')
  async deleteUser(@Param('id') id: string) {
    return this.prisma.user.delete({
      where: { id },
    });
  }

  // 3. Articles
  @Get('articles')
  async getArticles() {
    return this.prisma.article.findMany({
      include: {
        author: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  @Post('articles')
  async createArticle(@Body() body: any) {
    return this.prisma.article.create({
      data: {
        title: body.title,
        category: body.category,
        date:
          body.date ||
          new Date().toLocaleDateString('id-ID', {
            day: 'numeric',
            month: 'long',
            year: 'numeric',
          }),
        excerpt: body.excerpt,
        cover:
          body.cover ||
          'https://images.unsplash.com/photo-1613441589134-3fc7f95a3e16?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=600',
        content: body.content,
        authorId: body.authorId,
      },
    });
  }

  @Put('articles/:id')
  async updateArticle(@Param('id') id: string, @Body() body: any) {
    return this.prisma.article.update({
      where: { id },
      data: {
        title: body.title,
        category: body.category,
        date: body.date,
        excerpt: body.excerpt,
        cover: body.cover,
        content: body.content,
      },
    });
  }

  @Delete('articles/:id')
  async deleteArticle(@Param('id') id: string) {
    return this.prisma.article.delete({
      where: { id },
    });
  }

  // 4. Seminars
  @Get('seminars')
  async getSeminars() {
    return this.prisma.seminar.findMany({
      include: {
        schedules: true,
        participants: true,
        announcements: true,
        author: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  @Get('seminars/:id')
  async getSeminar(@Param('id') id: string) {
    return this.prisma.seminar.findUnique({
      where: { id },
      include: {
        schedules: true,
        participants: true,
        announcements: true,
      },
    });
  }

  @Post('seminars')
  async createSeminar(@Body() body: any) {
    return this.prisma.seminar.create({
      data: {
        title: body.title,
        category: body.category,
        mode: body.mode,
        status: body.status || 'Pendaftaran Dibuka',
        speaker: body.speaker,
        speakerRole: body.speakerRole,
        speakerAvatar: body.speakerAvatar || 'https://i.pravatar.cc/150?img=11',
        date: body.date,
        time: body.time,
        location: body.location,
        capacity: Number(body.capacity),
        registered: Number(body.registered || 0),
        description: body.description,
        requirements: body.requirements || [],
        organizer: body.organizer,
        organizerLogo: body.organizerLogo || 'https://i.pravatar.cc/80?img=5',
        cover:
          body.cover ||
          'https://images.unsplash.com/photo-1616992510024-f1293eb00e41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
        daftarType: body.daftarType || 'Google Form',
        daftarUrl: body.daftarUrl || '',
        certificateUrl: body.certificateUrl || '',
        authorId: body.authorId || null,
      },
    });
  }

  @Put('seminars/:id')
  async updateSeminar(@Param('id') id: string, @Body() body: any) {
    return this.prisma.seminar.update({
      where: { id },
      data: {
        title: body.title,
        category: body.category,
        mode: body.mode,
        status: body.status,
        speaker: body.speaker,
        speakerRole: body.speakerRole,
        speakerAvatar: body.speakerAvatar,
        date: body.date,
        time: body.time,
        location: body.location,
        capacity:
          body.capacity !== undefined ? Number(body.capacity) : undefined,
        registered:
          body.registered !== undefined ? Number(body.registered) : undefined,
        description: body.description,
        requirements: body.requirements,
        organizer: body.organizer,
        organizerLogo: body.organizerLogo,
        cover: body.cover,
        daftarType: body.daftarType,
        daftarUrl: body.daftarUrl,
        certificateUrl: body.certificateUrl,
      },
    });
  }

  @Delete('seminars/:id')
  async deleteSeminar(@Param('id') id: string) {
    return this.prisma.seminar.delete({
      where: { id },
    });
  }

  // 5. Materials
  @Get('materials')
  async getMaterials() {
    return this.prisma.material.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  @Post('materials')
  async createMaterial(@Body() body: any) {
    return this.prisma.material.create({
      data: {
        title: body.title,
        description: body.description,
        icon: body.icon || '📘',
        type: body.type || 'PDF',
        size: body.size || '1.0 MB',
        url: body.url || '#',
      },
    });
  }

  @Put('materials/:id')
  async updateMaterial(@Param('id') id: string, @Body() body: any) {
    return this.prisma.material.update({
      where: { id },
      data: {
        title: body.title,
        description: body.description,
        icon: body.icon,
        type: body.type,
        size: body.size,
        url: body.url,
      },
    });
  }

  @Delete('materials/:id')
  async deleteMaterial(@Param('id') id: string) {
    return this.prisma.material.delete({
      where: { id },
    });
  }

  // 6. Schedules
  @Get('schedules')
  async getSchedules() {
    return this.prisma.schedule.findMany({
      // @ts-ignore
      include: { author: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  @Post('schedules')
  async createSchedule(@Body() body: any) {
    return this.prisma.schedule.create({
      data: {
        date: body.date,
        month: body.month,
        year: body.year,
        title: body.title,
        location: body.location,
        status: body.status || 'Pendaftaran Dibuka',
        seminarId: body.seminarId || null,
        // @ts-ignore
        authorId: body.authorId || null,
      },
    });
  }

  @Put('schedules/:id')
  async updateSchedule(@Param('id') id: string, @Body() body: any) {
    return this.prisma.schedule.update({
      where: { id },
      data: {
        date: body.date,
        month: body.month,
        year: body.year,
        title: body.title,
        location: body.location,
        status: body.status,
        seminarId: body.seminarId,
      },
    });
  }

  @Delete('schedules/:id')
  async deleteSchedule(@Param('id') id: string) {
    return this.prisma.schedule.delete({
      where: { id },
    });
  }

  // 7. Participants
  @Get('participants')
  async getParticipants() {
    return this.prisma.participant.findMany({
      include: {
        seminar: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  @Post('participants')
  async createParticipant(@Body() body: any) {
    return this.prisma.participant.create({
      data: {
        name: body.name,
        nip: body.nip,
        agency: body.agency,
        seminarTitle: body.seminarTitle,
        date:
          body.date ||
          new Date().toLocaleDateString('id-ID', {
            day: 'numeric',
            month: 'long',
            year: 'numeric',
          }),
        status: body.status || 'Confirmed',
        seminarId: body.seminarId || null,
      },
    });
  }

  @Put('participants/:id')
  async updateParticipant(@Param('id') id: string, @Body() body: any) {
    return this.prisma.participant.update({
      where: { id },
      data: {
        name: body.name,
        nip: body.nip,
        agency: body.agency,
        seminarTitle: body.seminarTitle,
        status: body.status,
        seminarId: body.seminarId,
      },
    });
  }

  @Delete('participants/:id')
  async deleteParticipant(@Param('id') id: string) {
    return this.prisma.participant.delete({
      where: { id },
    });
  }

  // 8. Announcements
  @Get('announcements')
  async getAnnouncements() {
    return this.prisma.announcement.findMany({
      include: {
        seminar: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  @Post('announcements')
  async createAnnouncement(@Body() body: any) {
    return this.prisma.announcement.create({
      data: {
        title: body.title,
        type: body.type,
        content: body.content,
        hasFile: body.hasFile || false,
        fileUrl: body.fileUrl,
        date:
          body.date ||
          new Date().toLocaleDateString('id-ID', {
            day: 'numeric',
            month: 'long',
            year: 'numeric',
          }),
        seminarId: body.seminarId,
      },
    });
  }

  @Delete('announcements/:id')
  async deleteAnnouncement(@Param('id') id: string) {
    return this.prisma.announcement.delete({
      where: { id },
    });
  }

  // 9. Regulations
  @Get('regulations')
  async getRegulations() {
    return this.prisma.regulation.findMany({
      orderBy: { createdAt: 'asc' },
    });
  }

  @Post('regulations')
  async createRegulation(@Body() body: any) {
    return this.prisma.regulation.create({
      data: {
        group: body.group,
        title: body.title,
        url: body.url || '#',
      },
    });
  }

  @Put('regulations/:id')
  async updateRegulation(@Param('id') id: string, @Body() body: any) {
    return this.prisma.regulation.update({
      where: { id },
      data: {
        group: body.group,
        title: body.title,
        url: body.url,
      },
    });
  }

  @Delete('regulations/:id')
  async deleteRegulation(@Param('id') id: string) {
    return this.prisma.regulation.delete({
      where: { id },
    });
  }

  // 10. Evaluations
  @Get('evaluations')
  async getEvaluations() {
    return this.prisma.evaluation.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  @Post('evaluations')
  async createEvaluation(@Body() body: any) {
    return this.prisma.evaluation.create({
      data: {
        activity: body.activity,
        category: body.category,
        period: body.period,
        score: Number(body.score || 0),
        status: body.status || 'Dalam Proses',
      },
    });
  }

  @Put('evaluations/:id')
  async updateEvaluation(@Param('id') id: string, @Body() body: any) {
    return this.prisma.evaluation.update({
      where: { id },
      data: {
        activity: body.activity,
        category: body.category,
        period: body.period,
        score: body.score !== undefined ? Number(body.score) : undefined,
        status: body.status,
      },
    });
  }

  @Delete('evaluations/:id')
  async deleteEvaluation(@Param('id') id: string) {
    return this.prisma.evaluation.delete({
      where: { id },
    });
  }

  // 11. Galleries
  @Get('galleries')
  async getGalleries() {
    // @ts-ignore
    return this.prisma.gallery.findMany({
      include: { author: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  @Post('galleries')
  async createGallery(@Body() body: any) {
    // @ts-ignore
    return this.prisma.gallery.create({
      data: {
        title: body.title,
        description: body.description,
        imageUrl:
          body.imageUrl ||
          'https://images.unsplash.com/photo-1613441589134-3fc7f95a3e16?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=600',
        date:
          body.date ||
          new Date().toLocaleDateString('id-ID', {
            day: 'numeric',
            month: 'long',
            year: 'numeric',
          }),
        authorId: body.authorId || null,
      },
    });
  }

  @Put('galleries/:id')
  async updateGallery(@Param('id') id: string, @Body() body: any) {
    // @ts-ignore
    return this.prisma.gallery.update({
      where: { id },
      data: {
        title: body.title,
        description: body.description,
        imageUrl: body.imageUrl,
        date: body.date,
      },
    });
  }

  @Delete('galleries/:id')
  async deleteGallery(@Param('id') id: string) {
    // @ts-ignore
    return this.prisma.gallery.delete({
      where: { id },
    });
  }

  // 12. Guides (Panduan)
  @Get('guides')
  async getGuides() {
    // @ts-ignore
    return this.prisma.guide.findMany({
      include: { author: true },
      orderBy: { order: 'asc' },
    });
  }

  @Post('guides')
  async createGuide(@Body() body: any) {
    // @ts-ignore
    return this.prisma.guide.create({
      data: {
        title: body.title,
        key: body.key || body.title.toLowerCase().replace(/\s+/g, '-'),
        content: body.content,
        order: Number(body.order || 0),
        authorId: body.authorId || null,
      },
    });
  }

  @Put('guides/:id')
  async updateGuide(@Param('id') id: string, @Body() body: any) {
    // @ts-ignore
    return this.prisma.guide.update({
      where: { id },
      data: {
        title: body.title,
        key: body.key,
        content: body.content,
        order: body.order !== undefined ? Number(body.order) : undefined,
      },
    });
  }

  @Delete('guides/:id')
  async deleteGuide(@Param('id') id: string) {
    // @ts-ignore
    return this.prisma.guide.delete({
      where: { id },
    });
  }
}
