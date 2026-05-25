import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ApiController } from './api.controller';
import { PrismaService } from './prisma.service';

@Module({
  imports: [],
  controllers: [AppController, ApiController],
  providers: [AppService, PrismaService],
})
export class AppModule {}
