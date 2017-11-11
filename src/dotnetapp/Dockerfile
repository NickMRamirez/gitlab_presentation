FROM microsoft/aspnetcore:2.0.0
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
WORKDIR /app
COPY output .
ENTRYPOINT ["dotnet", "ectoplasm.dll"]